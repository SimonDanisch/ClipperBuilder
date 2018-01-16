using BinaryBuilder

# These are the platforms built inside the wizard
platforms = [
    BinaryProvider.Linux(:i686, :glibc),
    BinaryProvider.Linux(:x86_64, :glibc),
    BinaryProvider.Linux(:aarch64, :glibc),
    BinaryProvider.Linux(:armv7l, :glibc),
    BinaryProvider.Linux(:powerpc64le, :glibc),
    BinaryProvider.MacOS(),
    BinaryProvider.Windows(:i686),
    BinaryProvider.Windows(:x86_64)
]


# If the user passed in a platform (or a few, comma-separated) on the
# command-line, use that instead of our default platforms
if length(ARGS) > 0
    platforms = platform_key.(split(ARGS[1], ","))
end
info("Building for $(join(triplet.(platforms), ", "))")

# Collection of sources required to build Clipper
sources = [
    "https://github.com/Voxel8/Clipper.jl.git" =>
    "1bf969d44b1e81c7a4be3ba09020a11d2e4a305b",
]

script = raw"""
cd $WORKSPACE/srcdir
cd Clipper.jl/src/
g++ -c -fPIC -std=c++11 clipper.cpp cclipper.cpp
if [[ ${target} == *-mingw32 ]]; then     mkdir ${DESTDIR}/bin;     g++ -shared -o ${DESTDIR}/bin/cclipper.dll clipper.o cclipper.o; else     mkdir ${DESTDIR}/lib;     if [[ ${target} == *-darwin* ]]; then         g++ -shared -o ${DESTDIR}/lib/cclipper.dylib clipper.o cclipper.o;     else         g++ -shared -o ${DESTDIR}/lib/cclipper.so clipper.o cclipper.o;     fi; fi
exit

"""

products = prefix -> [
    LibraryProduct(prefix,"cclipper")
]


# Build the given platforms using the given sources
hashes = autobuild(pwd(), "Clipper", platforms, sources, script, products)
