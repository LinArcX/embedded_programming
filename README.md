# embedded_programming
A simple c program to watch specific port and forward message to client.

# Tools
OS: Void linux
Compiler: gcc
Editor: neovim

# Build
Firstly you should install these dependencies:

- make
- cmake
- pkg-config
- sqlite-devel
- [iniparser](https://github.com/ndevilla/iniparser)

Then clone and build the project:

```
git clone https://github.com/LinArcX/embedded_programming
cd embedded_programming
cd output/cmake/
cmake -DCMAKE_BUILD_TYPE=Release ../..
make -j8
```

And finally, run it:
`../release/embedded_programming`

## License
![License](https://img.shields.io/github/license/LinArcX/embedded_programming.svg)

prepare: 10:00 - 13:00
