local nvim_settings =  {}

local Menu = require("nui.menu")
local event = require("nui.utils.autocmd").event

local application_name = "myserver"
local project_settings = "project_settings.txt"

local build_type_debug="debug"
local build_type_release="release"

local arch_type_x86="x86"
local arch_type_x64="x64"

local has_error = false
local notify_timeout = 500
local notification_data = {}
local notification_title_done
local notification_title_in_progress
local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }
local project_settings_items

function nvim_settings.fetch_settings(path)
  local rows = {}
  local file = io.open(path, "rb")
  if not file then return nil end

  for line in io.lines(path) do
    for word in line:gmatch("%w+") do
      table.insert(rows, word)
    end
  end

  file:close()
  project_settings_items =  rows
end

function nvim_settings.setup_keys()
  if project_settings_items[2] == build_type_debug then
    vim.api.nvim_set_keymap('n', '<F5>', ':lua require\'dap\'.continue()<CR>', {noremap = true})
  else
    vim.api.nvim_set_keymap('n', '<F5>', ':lua nvim_settings.run()<CR>', {noremap = true})
  end
  vim.api.nvim_set_keymap('n', '<A-o>', ':FSHere<CR>', {noremap = true})
  vim.api.nvim_set_keymap('n', '<C-b>', ':lua nvim_settings.build()<CR>', {noremap = true})
  vim.api.nvim_set_keymap('n', '<C-e>', ':lua nvim_settings.clean()<CR>', {noremap = true})
end

function nvim_settings.setup_dap()
  local main_program = string.format("${workspaceFolder}/output/%s/%s/%s",
  project_settings_items[1],
  project_settings_items[2], application_name)

  local dap = require('dap')
  dap.configurations.c = {
    {
      args = {},
      type = "lldb",
      name = "Launch",
      request = "launch",
      program = main_program,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      runInTerminal = false,
    },
  }
end

function nvim_settings.setup_command_palette()
  table.insert(require('command_palette').CpMenu,
    {"project",
      { 'extract variable', ":call ExtractVariable()" },
      { 'extract method', ":call ExtractMethod()" },
      { "libc help", ':call LibcSH()' },
      { "libc help(under cursor)", ':call LibcSHUC()' },
      { 'switch header/source (A-o)', ':FSHere()' },
      { 'set arch type', ':lua nvim_settings.select_type("Architecture", { \'x86\', \'x64\' }, 1)' },
      { 'set build type', ':lua nvim_settings.select_type("BuildType", { \'debug\', \'release\' }, 2)' },
      { 'clean (C-e)', ':lua nvim_settings.clean()' },
      { 'run (F5)', ':lua nvim_settings.run()' },
      { 'build (C-b)', ':lua nvim_settings.build()' },
    })
end

function nvim_settings.init()
  nvim_settings.fetch_settings(project_settings);
  nvim_settings.setup_keys()
  nvim_settings.setup_dap()
  nvim_settings.setup_command_palette()
end

function nvim_settings.on_menu_item_selected(item, new_title, index)
  local file = io.open(project_settings, 'r')
  local content = {}
  for line in file:lines() do
      table.insert (content, line)
  end
  io.close(file)

  content[index] = item.text

  file = io.open(project_settings, 'w')
  for index, value in ipairs(content) do
      file:write(value..'\n')
  end
  io.close(file)

  local notification_title =  string.format("%s selected", item.text)

  require("notify").notify(notification_title, "INFO",
    { title = new_title, timeout = notification_title_done })
end

function nvim_settings.select_type(new_title, types, index)
  local new_lines = {}
  for i, my_type in ipairs(types) do
    new_lines[i] = Menu.item(my_type)
  end

  local menu = Menu({
    position = { row = "5%", col = "50%" },
    size = { width = 40, height = 2 },
    relative = "editor",
    border = {
      highlight = "MyHighlightGroup",
      style = "single",
      text = {
        top = new_title,
        top_align = "center",
      },
    },
    win_options = { winblend = 10, winhighlight = "Normal:Normal" },
  },
  {
    lines = new_lines,
    max_width = 20,
    keymap = {
      focus_next  = { "j", "<Down>", "<Tab>" },
      focus_prev  = { "k", "<Up>", "<S-Tab>" },
      close       = { "<Esc>", "<C-c>" },
      submit      = { "<CR>", "<Space>" },
    },
    on_submit = function(item)
      nvim_settings.on_menu_item_selected(item, new_title, index)
    end,
  })

  menu:mount()
  menu:on(event.BufLeave, menu.menu_props.on_close, { once = true })
end

local function update_spinner(notification_data, title)
   local new_spinner = (notification_data.spinner + 1) % #spinner_frames
   notification_data.spinner = new_spinner

   notification_data.notification = require("notify").notify(title, nil, {
     hide_from_history = true,
     icon = spinner_frames[new_spinner],
     replace = notification_data.notification,
   })

   vim.defer_fn(function()
     update_spinner(notification_data, nil)
   end, 100)
end

local function on_event(job_id, data, event)
  local lines = {""}
  if event == "stderr" then
    local error_lines = ""
    vim.list_extend(lines, data)

    for i=1, #lines
    do
      error_lines = error_lines .. "\n" .. lines[i]
    end

    if(lines[3] ~= nil) then
      vim.b._cexpr_lines = error_lines
      vim.cmd [[ :cexpr b:_cexpr_lines ]]
      vim.cmd [[ :copen ]]
      has_error = true

      require("notify").dismiss(true)

      require("notify").notify("Something went wrong!", "ERROR",
        { title = notification_title_done, timeout = notify_timeout })
    end
  end
  if event == "exit" then
    if data then
      if(not has_error) then
        update_spinner(notification_data, "SUCCESS")

        require("notify").dismiss()

        local successfull_message =  string.format("%s was successful :)", notification_title_done)
        require("notify").notify(successfull_message, "INFO",
          { title = notification_title_done, timeout = notify_timeout })
        vim.cmd(':source $MYVIMRC')
      end
    end
    has_error = false
  end
end

function nvim_settings.async_task(command)
  notification_data.notification = require("notify").notify(notification_title_in_progress, "info", {
    title = "",
    icon = spinner_frames[1],
    timeout = false,
    hide_from_history = false,
  })
  notification_data.spinner = 1
  update_spinner(notification_data, nil)

  vim.fn.jobstart(command,
    { on_stderr = on_event,
      on_stdout = on_event,
      on_exit = on_event,
      stdout_buffered = true,
      stderr_buffered = true,
    })
end

function nvim_settings.build()
  notification_title_done = "Build"
  notification_title_in_progress = "Building..."

  local cmd_clean = "rm -rf compile_commands.json"
  local cmd_cd = "cd output/cmake"
  local cmd_cmake = nil
  local cmd_make = "make -j8"
  local cmd_link = "cd ../..; ln -s output/cmake/compile_commands.json ."

  if project_settings_items[1] == arch_type_x86 then
    if project_settings_items[2] == build_type_debug then
      cmd_cmake = string.format("%s; cmake %s -DCMAKE_BUILD_TYPE=%s ../..", cmd_cd, "-DCMAKE_CXX_FLAGS=-m32", "DEBUG")
    elseif project_settings_items[2] == build_type_release then
      cmd_cmake = string.format("%s; cmake %s -DCMAKE_BUILD_TYPE=%s ../..", cmd_cd, "-DCMAKE_CXX_FLAGS=-m32", "RELEASE")
    end
  elseif project_settings_items[1] == arch_type_x64 then
    if project_settings_items[2] == build_type_debug then
      cmd_cmake = string.format("%s; cmake %s -DCMAKE_BUILD_TYPE=%s ../..", cmd_cd, "", "DEBUG")
    elseif project_settings_items[2] == build_type_release then
      cmd_cmake = string.format("%s; cmake %s -DCMAKE_BUILD_TYPE=%s ../..", cmd_cd, "", "RELEASE")
    end
  end

  local build_command = string.format("%s; %s; %s; %s", cmd_clean, cmd_cmake, cmd_make, cmd_link)
  local function_command =  string.format(":lua nvim_settings.async_task(\"%s\")", build_command)
  vim.cmd(function_command)
end

function nvim_settings.run()
  vim.cmd(string.format(":call HTerminal(0.4, 200, \"./output/%s/%s/%s\")", project_settings_items[1], project_settings_items[2], application_name))
end

function nvim_settings.clean()
  notification_title_done = "Clean"
  notification_title_in_progress = "Cleaning..."

  local clean_command = string.format("rm -rf ./output/cmake/* compile_commands.json ./output/%s/%s/*;",
    project_settings_items[1],
    project_settings_items[2])

  local function_command =  string.format(":silent; lua nvim_settings.async_task(\"%s\")", clean_command)
  vim.cmd(function_command)
end

return nvim_settings
