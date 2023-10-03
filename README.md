# NI \o/ - Neutrino-Images Buildsystem #

## Für die Einrichtung unter Debian sind folgende Pakete nötig
```bash
apt-get install \
git subversion mercurial cvs automake build-essential ccache patch tar \
texinfo autopoint libtool libtool-bin python curl gzip lzma \
gperf gettext help2man bc libglib2.0-dev libncurses5-dev libncursesw5-dev \
liblzo2-dev uuid-dev libssl-dev libltdl-dev libcurl4-openssl-dev intltool zip

```

## 1) Buildsystem initialisieren
```bash
git clone https://github.com/neutrino-images/ni-buildsystem.git
cd ni-buildsystem
```

## 2) Archivverzeichnis erstellen
```bash
mkdir -p $HOME/archives
ln -s $HOME/archives download
```

## 3) Buildsystem konfigurieren
```bash
make local-files
```
config.local auf die eigenen Bedürfnisse anpassen. BOXMODEL **muss** gesetzt werden!

## 4) Buildumgebung prüfen
```bash
make toolcheck
```

## 5) Buildsystem initialisieren und Toolchain bauen
```bash
make init
```

## 6) Image(s) bauen
```bash
make image
make images
```

## 7) Aktualisieren und aufräumen
```bash
make update
make clean
```
