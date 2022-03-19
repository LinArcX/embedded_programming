# embedded_programming
A client/server program that uses socket-programming to send/receive message between each other.

# Tools
- OS: Void linux
- Compiler: gcc
- Editor: neovim

# Build
This program consists of two parts:
1. server: written in c.
2. client: written in python.

To build the server, you should first install these dependencies:

- make
- cmake
- pkg-config
- sqlite-devel
- [iniparser](https://github.com/ndevilla/iniparser)

Then clone and build:

```
git clone https://github.com/LinArcX/embedded_programming
cd embedded_programming
mkdir -p output/cmake output/debug output/release
cd output/cmake/
cmake -DCMAKE_BUILD_TYPE=Release ../..
make -j8
```

And finally run it:

`../release/myserver`

# Test
There is a python script file that you can use as client part:

`python3 test/client.py`

## License
![License](https://img.shields.io/github/license/LinArcX/embedded_programming.svg)
