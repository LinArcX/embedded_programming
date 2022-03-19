nnoremap <silent> <A-o> :FSHere<CR>

lua << EOF
table.insert(require('command_palette').CpMenu,
  {"Project",
    { 'extract variable', ":call ExtractVariable()" },
    { 'extract method', ":call ExtractMethod()" },
    { "libc help", ':call LibcSH()' },
    { "libc help(under cursor)", ':call LibcSHUC()' },
    { 'clean project', ':AsyncRun rm -r output/cmake/* output/debug/* output/release/* compile_commands.json;' },
    { 'run(release)', ':AsyncRun ./output/release/embedded_programming' },
    { 'build(release)', ':AsyncRun cd output/cmake; cmake -DCMAKE_BUILD_TYPE=RELEASE ../..; make -j8; cd ../../; ln -s output/cmake/compile_commands.json .;' },
    { 'run(debug)', ':AsyncRun ./output/debug/embedded_programming' },
    { 'build(debug)', ':AsyncRun cd output/cmake; cmake -DCMAKE_BUILD_TYPE=DEBUG ../..; make -j8; cd ../../; ln -s output/cmake/compile_commands.json .;' },
  })

local dap = require('dap')
dap.configurations.c = {
  {
    args = {},
    type = "lldb",
    name = "Launch",
    request = "launch",
    program = "${workspaceFolder}/output/debug/embedded_programming",
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    runInTerminal = false,
  },
}
EOF
