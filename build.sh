#/bin/bash

# checkout / pull
if [ ! -d CoreELEC ]; then
   git clone https://github.com/Zabrimus/CoreELEC.git
   cd CoreELEC
else
   cd CoreELEC
   git pull
fi

git checkout exp-vdr-opt

# build
cd CoreELEC/
rm target/*
make

# Extract VDR archive
mkdir -p mnt
squashfuse target/*system mnt
mkdir -p vdr-tar
cp -a mnt/opt vdr-tar

# Cleanup
rm   vdr-tar/opt/.opt
rm   vdr-tar/opt/vdr/bin/{createcats,cxxtools-config,gdk-*,iconv,pango*,rsvg-convert,tntnet-config,update-mime-database}
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
