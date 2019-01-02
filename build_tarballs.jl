# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "Clipper"
version = v"6.4.2"

# Collection of sources required to build Clipper
sources = [
    "https://github.com/SimonDanisch/ClipperBuilder.git" =>
    "9ea1878235d518d5e14bce35a94924a34bab8b68",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd ClipperBuilder/
${CXX} -c -fPIC -std=c++11 clipper.cpp cclipper.cpp
libdir="lib"
if [[ ${target} == *-mingw32 ]]; then     libdir="bin"; else     libdir="lib"; fi
mkdir ${prefix}/${libdir}
${CXX} -shared -o ${prefix}/${libdir}/cclipper.${dlext} clipper.o cclipper.o;
exit
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, :glibc),
    Linux(:x86_64, :glibc),
    Linux(:aarch64, :glibc),
    Linux(:armv7l, :glibc, :eabihf),
    Linux(:powerpc64le, :glibc),
    Linux(:i686, :musl),
    Linux(:x86_64, :musl),
    Linux(:aarch64, :musl),
    Linux(:armv7l, :musl, :eabihf),
    MacOS(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]
#    FreeBSD(:x86_64),

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "cclipper", :cclipper)
]

# Dependencies that must be installed before this package can be built
dependencies = [

]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
