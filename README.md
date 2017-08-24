**Voraussetzung für die Nutzung des Buildsystems ist ein Bitbucket Account**
**Der Bitbucket Account muss einen SSH-Key hinterlegt haben**

**Für die Einrichtung unter Debian sind folgende Pakete nötig**
```
#!bash
apt-get install \
git subversion cvs automake build-essential ccache cmake patch bison flex texinfo autopoint \
libtool libtool-bin python curl gawk gzip bzip2 lzma gperf gettext help2man bc \
libglib2.0-dev libncurses5-dev libncursesw5-dev liblzo2-dev uuid-dev libssl-dev libcurl4-openssl-dev
```

# 1) Buildsystem initialisieren #
```
#!bash
git clone git@bitbucket.org:neutrino-images/ni-buildsystem.git
cd ni-buildsystem
```

# 2) Archivverzeichnis erstellen #
```
#!bash
mkdir -p $HOME/src/Archive
ln -s $HOME/src/Archive download
```

# 3) Buildsystem konfigurieren #
```
#!bash
make local-files BOXSERIES=hd2
```
config.local auf die eigenen Bedürfnisse anpassen

# 4) Toolchain bauen #
```
#!bash
make init
```

# 5) Image(s) bauen #
```
#!bash
make ni-image
make ni-images
```

# 6) Aktualisieren und aufräumen #
```
#!bash
make update-all
make clean
```
