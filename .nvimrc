lua << EOF
local app = "myserver"
local notify_title = nil

function on_event(job_id, data, event)
  if event == "stderr" then
     if #data == 2 then
      require("notify").notify(data, "ERROR", {title = notify_title})
    end
  end
  if event == "exit" then
    if data then
      require("notify").notify("SUCCESS", "INFO", {title = notify_title})
      vim.cmd(':source $MYVIMRC')
    end
  end
end

function async_task(command)
  local job_id = vim.fn.jobstart(command,
    { on_stderr = on_event,
      on_stdout = on_event,
      on_exit = on_event,
      stdout_buffered = true,
      stderr_buffered = true,
    })
end

function detect_arch(path)
  local rows = {}
  local file = io.open(path, "rb")
  if not file then return nil end

  for line in io.lines(path) do
    for word in line:gmatch("%w+") do
      table.insert(rows, word)
    end
  end

  file:close()
  return rows;
end

local arch = detect_arch("arch.txt");
if arch[2] == "debug" then
  vim.api.nvim_set_keymap('n', '<F5>', ':lua require\'dap\'.continue()<CR>', {noremap = true})
else
  vim.api.nvim_set_keymap('n', '<F5>', ':lua run()<CR>', {noremap = true})
end
vim.api.nvim_set_keymap('n', '<A-o>', ':FSHere<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-b>', ':lua build()<CR>', {noremap = true})
vim.api.nvim_set_keymap('n', '<C-e>', ':lua clean()<CR>', {noremap = true})

local dap = require('dap')
local main_program =  string.format("${workspaceFolder}/output/%s/%s/%s", arch[1], arch[2], app)

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

table.insert(require('command_palette').CpMenu,
  {"Project",
    { 'extract variable', ":call ExtractVariable()" },
    { 'extract method', ":call ExtractMethod()" },
    { "libc help", ':call LibcSH()' },
    { "libc help(under cursor)", ':call LibcSHUC()' },
    { 'switch header/source (A-o)', ':FSHere()' },
    { 'clean (C-e)', ':lua clean()' },
    { 'run (F5)', ':lua run()' },
    { 'build (C-b)', ':lua build()' },
  })

function build()
  notify_title = "BUILD"
  local cmd_clean = "rm -rf compile_commands.json"
  local cmd_cd = "cd output/cmake"
  local cmd_cmake = nil
  local cmd_make = "make -j8"
  local cmd_link = "cd ../..; ln -s output/cmake/compile_commands.json ."

  if arch[1] == "x86" then
    if arch[2] == "debug" then
      cmd_cmake = string.format("%s; cmake %s -DCMAKE_BUILD_TYPE=%s ../..", cmd_cd, "-DCMAKE_CXX_FLAGS=-m32", "DEBUG")
    elseif arch[2] == "release" then
      cmd_cmake = string.format("%s; cmake %s -DCMAKE_BUILD_TYPE=%s ../..", cmd_cd, "-DCMAKE_CXX_FLAGS=-m32", "RELEASE")
    end
  elseif arch[1] == "x64" then
    if arch[2] == "debug" then
      cmd_cmake = string.format("%s; cmake %s -DCMAKE_BUILD_TYPE=%s ../..", cmd_cd, "", "DEBUG")
    elseif arch[2] == "release" then
      cmd_cmake = string.format("%s; cmake %s -DCMAKE_BUILD_TYPE=%s ../..", cmd_cd, "", "RELEASE")
    end
  end

  local build_command = string.format("%s; %s; %s; %s", cmd_clean, cmd_cmake, cmd_make, cmd_link)
  local function_command =  string.format(":lua async_task(\"%s\")", build_command)
  vim.cmd(function_command)
end

function run()
  vim.cmd(string.format(":call HTerminal(0.4, 200, \"./output/%s/%s/%s\")", arch[1], arch[2], app))
end

function clean()
  notify_title = "CLEAN"
  local clean_command = string.format("rm -rf ./output/cmake/* compile_commands.json ./output/%s/%s/*;", arch[1], arch[2])
  local function_command =  string.format(":lua async_task(\"%s\")", clean_command)
  vim.cmd(function_command)
end
EOF
