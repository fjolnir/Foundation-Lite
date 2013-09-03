# Foundation Lite

**NOTE:** This is still super *super* early in development. (To see what has been implemented you can read `Foundation.h`, the uncommented classes are implemented. Although not all are finished)

Foundation lite is a limited subset of Cocoa's Foundation framework, intented for use on Linux (x86_64).

It deliberately only implements only the absolute core components of Foundation with the goal of making it feasible to deploy Objective-C on Linux servers. 

Most of the types implemented are simple wrappers around Apple's own CoreFoundation Lite (hence Foundation Lite), meaning that these are no half-assed implementation I whipped up in my spare time, and should have roughly the same performance characteristics as those on MacOS, and will be updated with each release of it.

## Dependencies:

* clang 3.2+ (Latest recommended): http://clang.llvm.org/
* CFLite: https://github.com/fjolnir/CoreFoundation-Lite-Linux
* libBlocksRuntime: http://compiler-rt.llvm.org/
* ICU4C 4.4+: http://site.icu-project.org/
* libobjc2 http://svn.gna.org/svn/gnustep/libs/libobjc2/

### Installing dependencies on Debian (And  derivatives)

Install the latest version of clang using one of the sources on [http://llvm.org/apt](http://llvm.org/apt)

    sudo echo "<repo url>" >>  /etc/apt/sources.list
    wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | sudo apt-key add -
    sudo apt-get update
    
    sudo apt-get install clang-3.4
    sudo apt-get install libblocksruntime-dev
    sudo apt-get install libicu-dev
    
    svn co http://svn.gna.org/svn/gnustep/libs/libobjc2/
    mkdir libobjc2/build
    pushd libobjc2/build
    cmake .. -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
    make
    sudo make install
    popd
    
    git clone https://github.com/fjolnir/CoreFoundation-Lite-Linux.git cflite
    pushd cflite
    sudo make -f MakefileLinux install
    popd

And then simply execute `make` in your Foundation-Lite directory to try it out. (There's no `make install` yet because it is not mature enough to warrant installing)

## Contributing:

The easiest way to begin contributing is to help increase the test coverage. The test format is very simple and anyone with Objective-C experience should be able to learn it just by glancing at the files in `testcases/`

And of course I welcome implementations of any NS* classes that I have not gotten around to yet!