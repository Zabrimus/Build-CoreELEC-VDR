#/bin/bash

BRANCH=exp-vdr-opt

RUNNER_BUILDDIR=build.CoreELEC-Amlogic-ng.arm-19
RUNNER_CACHE=exp-vdr-opt-build
RUNNER_SOURCES=exp-vdr-opt-sources

# checkout / pull
if [ ! -d CoreELEC ]; then
   git clone https://github.com/Zabrimus/CoreELEC.git
   cd CoreELEC
else
   cd CoreELEC
   git pull
fi

git checkout ${BRANCH}

# restore build-cache
if [ -d ../../build-cache/${RUNNER_CACHE} ]; then
   ln -s ../../build-cache/${RUNNER_CACHE} ${RUNNER_BUILDDIR}
fi

if [ -d ../../build-cache/${RUNNER_SOURCES} ]; then
   ln -s ../../build-cache/${RUNNER_SOURCES} sources
fi

# build
rm -f target/*
make

# Extract VDR archive
mkdir -p mnt
squashfuse target/*system mnt
mkdir -p vdr-tar
cp -a mnt/opt vdr-tar

# Cleanup
rm vdr-tar/opt/.opt
rm vdr-tar/opt/vdr/bin/{createcats,cxxtools-config,gdk-*,iconv,pango*,rsvg-convert,tntnet-config,update-mime-database}
rm -Rf vdr-tar/opt/vdr/include
rm -Rf vdr-tar/opt/vdr/lib/pkgconfig
rm -Rf vdr-tar/opt/vdr/share/{doc,mime,pkgconfig,tntnet}

find vdr-tar/opt/vdr/share/locale/ -not -name "vdr*" -and -not -type d -exec rm {} \;
find vdr-tar -type d -empty -delete

# build final archive
tar -czhf target/coreelec-vdr.tar.gz -C vdr-tar .
umount mnt
rmdir mnt
rm -Rf vdr-tar

# rm VDR and all dependencies in build directory
rm -Rf ${RUNNER_BUILDDIR}/build/_*
rm -Rf ${RUNNER_BUILDDIR}/install_pkg/_*

# save build cache
mkdir -p ../../build-cache

if [ ! -d ../../build-cache/${RUNNER_CACHE} ]; then
   mv ${RUNNER_BUILDDIR} ../../build-cache/${RUNNER_CACHE}
else
   rm ${RUNNER_BUILDDIR}
fi

if [ ! -d ../../build-cache/${RUNNER_SOURCES} ]; then
   mv sources ../../build-cache/${RUNNER_SOURCES}
else
   rm sources
fi

