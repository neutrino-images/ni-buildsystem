#
# makefile to build plugins
#
# -----------------------------------------------------------------------------

TARGET_DIR ?= $(DESTDIR)

plugins-all: $(D)/neutrino \
	getrc \
	input \
	logomask \
	msgbox \
	tuxcal \
	tuxcom \
	tuxmail \
	tuxwetter \
	cooliTSclimax \
	emmrd \
	FritzCallMonitor \
	FritzInfoMonitor \
	FritzInfoMonitor_setup \
	vinfo \
	EPGscan \
	pr-auto-timer \
	logo-addon \
	smarthomeinfo \
	mountpointmanagement \
	epgfilter \
	netzkino \
	mtv \
	autoreboot \
	dropbox_uploader \
	userbouquets \
	add-locale \
	favorites2bin \
	LocalTV \
	webradio \
	webtv \
	neutrino-mediathek \
	openvpn-setup \
	oscammon \
	lcd4linux-all \
	doscam-webif-skin \
	shellexec

plugins-hd1: # nothing to do

plugins-hd2:
  ifneq ($(BOXMODEL), kronos_v2)
	make links
  endif

plugins-hd51: \
	links \
	stb-startup \
	imgbackup-hd51 \
	showiframe

# -----------------------------------------------------------------------------

channellogos: $(SOURCE_DIR)/$(NI_LOGO-STUFF) $(SHAREICONS)
	rm -rf $(SHAREICONS)/logo
	mkdir -p $(SHAREICONS)/logo
	install -m 0644 $(SOURCE_DIR)/$(NI_LOGO-STUFF)/logos/* $(SHAREICONS)/logo
	pushd $(SOURCE_DIR)/$(NI_LOGO-STUFF)/ && \
	./logo_linker.sh complete.db $(SHAREICONS)/logo

# -----------------------------------------------------------------------------

lcd4linux-all: $(D)/lcd4linux | $(TARGET_DIR)
	cp -a $(IMAGEFILES)/lcd4linux/* $(TARGET_DIR)/

# -----------------------------------------------------------------------------

emmrd: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(BIN)/emmrd
$(BIN)/emmrd: $(BIN) $(SHAREICONS) $(VARCONFIG) $(ETCINITD)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/emmrd && \
	$(TARGET)-g++ -Wall $(TARGET_CFLAGS) $(TARGET_LDFLAGS) $(CORTEX-STRINGS) -o $@ emmrd.cpp && \
	install -m 0755 emmrd.init $(ETCINITD)/emmrd && \
	install -m 0644 hint_emmrd.png $(SHAREICONS)/
	cd $(ETCINITD) && \
		ln -sf emmrd S99emmrd && \
		ln -sf emmrd K01emmrd

# -----------------------------------------------------------------------------

FritzCallMonitor: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(BIN)/FritzCallMonitor
$(BIN)/FritzCallMonitor: $(D)/openssl $(D)/libcurl $(BIN) $(VARCONFIG) $(ETCINITD) $(SHAREICONS)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/FritzCallMonitor && \
	$(TARGET)-gcc -Wall $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		\
		-lstdc++ -lcrypto -pthread -lcurl \
		\
		connect.cpp \
		FritzCallMonitor.cpp \
		\
		-o $@ && \
	install -m 0644 FritzCallMonitor.addr $(VARCONFIG)/ && \
	install -m 0644 FritzCallMonitor.cfg $(VARCONFIG)/ && \
	install -m 0755 fritzcallmonitor.init $(ETCINITD)/fritzcallmonitor && \
	install -m 0644 hint_FritzCallMonitor.png $(SHAREICONS)/
	cd $(ETCINITD) && \
		ln -sf fritzcallmonitor S99fritzcallmonitor && \
		ln -sf fritzcallmonitor K01fritzcallmonitor

# -----------------------------------------------------------------------------

FritzInfoMonitor: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(LIBPLUGINS)/FritzInfoMonitor.so
$(LIBPLUGINS)/FritzInfoMonitor.so: $(D)/freetype $(D)/openssl $(D)/libcurl $(LIBPLUGINS)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/FritzInfoMonitor && \
	$(TARGET)-gcc -Wall $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-I$(N_OBJDIR) -I$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/include \
		-I$(TARGET_INCLUDE_DIR)/freetype2 \
		\
		-lfreetype -lz -lstdc++ -lcrypto -lcurl \
		\
		connect.cpp \
		framebuffer.cpp \
		FritzInfoMonitor.cpp \
		icons.cpp \
		parser.cpp \
		phonebook.cpp \
		rc.cpp \
		submenu.cpp \
		\
		-o $@ && \
	install -m 0644 FritzInfoMonitor.cfg $(LIBPLUGINS)/ && \
	install -m 0644 FritzInfoMonitor_hint.png $(LIBPLUGINS)/

FritzInfoMonitor_setup: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(LIBPLUGINS)
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/FritzInfoMonitor/FritzInfoMonitor_setup.lua $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/FritzInfoMonitor/FritzInfoMonitor_setup.cfg $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/FritzInfoMonitor/FritzInfoMonitor_setup_hint.png $(LIBPLUGINS)/

# -----------------------------------------------------------------------------

vinfo: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(BIN)/vinfo
$(BIN)/vinfo: $(BIN)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/vinfo && \
	$(TARGET)-gcc $(TARGET_CFLAGS) -o $@ vinfo.c md5.c

# -----------------------------------------------------------------------------

EPGscan: $(LIBPLUGINS) $(VARCONFIG)
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/$@/$@.sh $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/$@/$@.cfg $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/$@/$@_hint.png $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/$@/$@.conf $(VARCONFIG)/
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/$@/$@_setup.lua $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/$@/$@_setup.cfg $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/$@/$@_setup_hint.png $(LIBPLUGINS)/

# -----------------------------------------------------------------------------

pr-auto-timer: $(LIBPLUGINS) $(VARCONFIG)
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/auto-record-cleaner $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/auto-record-cleaner.conf.template $(VARCONFIG)/auto-record-cleaner.conf
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/auto-record-cleaner.rules.template $(VARCONFIG)/auto-record-cleaner.rules
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/pr-auto-timer.sh $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/pr-auto-timer.cfg $(LIBPLUGINS)/
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/pr-auto-timer $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/pr-auto-timer_hint.png $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/pr-auto-timer.conf.template $(VARCONFIG)/pr-auto-timer.conf
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/pr-auto-timer.rules.template $(VARCONFIG)/pr-auto-timer.rules

# -----------------------------------------------------------------------------

imgbackup-hd51: $(LIBPLUGINS)
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/$@.sh $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/$@.cfg $(LIBPLUGINS)/

# -----------------------------------------------------------------------------

autoreboot: $(LIBPLUGINS)
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/$@.sh $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/$@.cfg $(LIBPLUGINS)/

# -----------------------------------------------------------------------------

logo-addon: $(SOURCE_DIR)/$(NI_LOGO-STUFF) $(LIBPLUGINS)
	install -m 0755 $(SOURCE_DIR)/$(NI_LOGO-STUFF)/logo-addon/*.sh $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_LOGO-STUFF)/logo-addon/*.cfg $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_LOGO-STUFF)/logo-addon/*.png $(LIBPLUGINS)/

# -----------------------------------------------------------------------------

smarthomeinfo: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(LIBPLUGINS) $(VARCONFIG)
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/$@.so $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/$@.cfg $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/$@_hint.png $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/$@.conf $(VARCONFIG)/

# -----------------------------------------------------------------------------

doscam-webif-skin:
	mkdir -p $(TARGET_DIR)/share/doscam/tpl/
	install -m 0644 $(IMAGEFILES)/$@/*.tpl $(TARGET_DIR)/share/doscam/tpl/
	mkdir -p $(TARGET_DIR)/share/doscam/skin/
	install -m 0644 $(IMAGEFILES)/$@/*.css $(TARGET_DIR)/share/doscam/skin

# -----------------------------------------------------------------------------

mountpointmanagement: $(LIBPLUGINS)
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/$@.sh $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/$@.cfg $(LIBPLUGINS)/

# -----------------------------------------------------------------------------

epgfilter: $(LIBPLUGINS)
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/$@/$@.sri $(LIBPLUGINS)/
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/$@/$@.lua $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/$@/$@.cfg $(LIBPLUGINS)/
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/$@/$@_hint.png $(LIBPLUGINS)/

# -----------------------------------------------------------------------------

dropbox_uploader: $(BIN)
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-sh/plugins/$@/*.sh $(BIN)/

# -----------------------------------------------------------------------------

openvpn-setup: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(LIBPLUGINS) $(ETCINITD)
	cp -a $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/$@/$@* $(LIBPLUGINS)/
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/$@/ovpn.init $(ETCINITD)/ovpn

# -----------------------------------------------------------------------------

neutrino-mediathek: $(LIBPLUGINS)
	$(REMOVE)/$@
	git clone https://github.com/neutrino-mediathek/mediathek.git $(BUILD_TMP)/$@
	$(CHDIR)/$@; \
		cp -a plugins/* $(LIBPLUGINS)/; \
		cp -a share $(TARGET_DIR)
	$(REMOVE)/$@

# -----------------------------------------------------------------------------

add-locale \
LocalTV \
userbouquets \
stb-startup \
netzkino \
mtv \
favorites2bin: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(LIBPLUGINS)
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/$@/* $(LIBPLUGINS)/

# -----------------------------------------------------------------------------

webradio: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(SHAREWEBRADIO)
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/webradio/* $(SHAREWEBRADIO)/

webtv: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(SHAREWEBTV)
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/scripts-lua/plugins/webtv/* $(SHAREWEBTV)/

# -----------------------------------------------------------------------------

getrc: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(BIN)/getrc
$(BIN)/getrc: $(BIN)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/getrc && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-I$(N_OBJDIR) -I$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/include \
		\
		getrc.c \
		io.c \
		\
		-o $@

# -----------------------------------------------------------------------------

input: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(BIN)/input
$(BIN)/input: $(D)/freetype $(BIN)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/input && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-I$(N_OBJDIR) -I$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/include \
		-I$(TARGET_INCLUDE_DIR)/freetype2 \
		\
		-lfreetype -lz -lpng \
		\
		fb_display.c \
		gfx.c \
		input.c \
		inputd.c \
		io.c \
		png_helper.cpp \
		pngw.cpp \
		resize.c \
		text.c \
		\
		-o $@

# -----------------------------------------------------------------------------

logomask: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(BIN)/logomask $(LIBPLUGINS)/logoset.so $(LIBPLUGINS)/logomask.so
$(BIN)/logomask: $(BIN)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/logomask && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-I$(N_OBJDIR) -I$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/include \
		\
		gfx.c \
		logomask.c \
		\
		-o $@ && \
	install -m 0755 logomask.sh $(BIN)/
 
$(LIBPLUGINS)/logoset.so: $(D)/freetype $(LIBPLUGINS)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/logomask && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-I$(N_OBJDIR) -I$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/include \
		-I$(TARGET_INCLUDE_DIR)/freetype2 \
		\
		-lfreetype -lz \
		\
		gfx.c \
		io.c \
		logoset.c \
		text.c \
		\
		-o $@ && \
	install -m 0644 logoset.cfg $(LIBPLUGINS)/ && \
	install -m 0644 logoset_hint.png $(LIBPLUGINS)/

$(LIBPLUGINS)/logomask.so: $(LIBPLUGINS) $(BIN)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/logomask && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-I$(N_OBJDIR) -I$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/include \
		\
		starter_logomask.c \
		\
		-o $@ && \
	install -m 0644 logomask.cfg $(LIBPLUGINS)/ && \
	install -m 0644 logomask_hint.png $(LIBPLUGINS)/

# -----------------------------------------------------------------------------

msgbox: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(BIN)/msgbox
$(BIN)/msgbox: $(D)/freetype $(BIN)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/msgbox && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-I$(N_OBJDIR) -I$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/include \
		-I$(TARGET_INCLUDE_DIR)/freetype2 \
		\
		-lfreetype -lz -lpng \
		\
		fb_display.c \
		gfx.c \
		io.c \
		msgbox.c \
		png_helper.cpp \
		pngw.cpp \
		resize.c \
		text.c \
		txtform.c \
		\
		-o $@

# -----------------------------------------------------------------------------

tuxcal: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(BIN)/tuxcald $(LIBPLUGINS)/tuxcal.so
$(BIN)/tuxcald: $(D)/freetype $(BIN) $(ETCINITD) $(VARCONFIG)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/tuxcal/daemon && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-I$(N_OBJDIR) -I$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/include \
		-I$(TARGET_INCLUDE_DIR)/freetype2 \
		\
		-lfreetype -lz -lpthread \
		\
		tuxcald.c \
		\
		-o $@ && \
	install -m 0755 tuxcald $(ETCINITD)/
	cd $(ETCINITD) && \
		ln -sf tuxcald S99tuxcald && \
		ln -sf tuxcald K01tuxcald
	install -d $(VARCONFIG)/tuxcal
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/tuxcal/tuxcal.conf $(VARCONFIG)/tuxcal/
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/tuxcal/tuxcal.notify $(VARCONFIG)/tuxcal/

$(LIBPLUGINS)/tuxcal.so: $(LIBPLUGINS)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/tuxcal && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-I$(N_OBJDIR) -I$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/include \
		-I$(TARGET_INCLUDE_DIR)/freetype2 \
		\
		-lfreetype -lz \
		\
		tuxcal.c \
		\
		-o $@ && \
	install -m 0644 tuxcal.cfg $(LIBPLUGINS)/ && \
	install -m 0644 tuxcal_hint.png $(LIBPLUGINS)/

# -----------------------------------------------------------------------------

tuxcom: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(LIBPLUGINS)/tuxcom.so
$(LIBPLUGINS)/tuxcom.so: $(D)/freetype $(LIBPLUGINS)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/tuxcom && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-I$(N_OBJDIR) -I$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/include \
		-I$(TARGET_INCLUDE_DIR)/freetype2 \
		\
		-lfreetype -lz \
		\
		tuxcom.c \
		\
		-o $@ && \
	install -m 0644 tuxcom.cfg $(LIBPLUGINS)/ && \
	install -m 0644 tuxcom_hint.png $(LIBPLUGINS)/

# -----------------------------------------------------------------------------

tuxmail: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(BIN)/tuxmaild $(LIBPLUGINS)/tuxmail.so
$(BIN)/tuxmaild: $(D)/freetype $(D)/openssl $(BIN) $(ETCINITD) $(VARCONFIG)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/tuxmail/daemon && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-I$(N_OBJDIR) -I$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/include \
		-I$(TARGET_INCLUDE_DIR)/freetype2 \
		\
		-lfreetype -lz -lcrypto -lssl -lpthread \
		\
		tuxmaild.c \
		\
		-o $@ && \
	install -m 0755 tuxmaild $(ETCINITD)/
	cd $(ETCINITD) && \
		ln -sf tuxmaild S99tuxmaild && \
		ln -sf tuxmaild K01tuxmaild
	install -d $(VARCONFIG)/tuxmail
	install -m 0644 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/tuxmail/tuxmail.conf $(VARCONFIG)/tuxmail/
	install -m 0755 $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/tuxmail/tuxmail.onreadmail $(VARCONFIG)/tuxmail/

$(LIBPLUGINS)/tuxmail.so: $(LIBPLUGINS)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/tuxmail && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-I$(N_OBJDIR) -I$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/include \
		-I$(TARGET_INCLUDE_DIR)/freetype2 \
		\
		-lfreetype -lz \
		\
		tuxmail.c \
		\
		-o $@ && \
	install -m 0644 tuxmail.cfg $(LIBPLUGINS)/ && \
	install -m 0644 tuxmail_hint.png $(LIBPLUGINS)/

# -----------------------------------------------------------------------------

tuxwetter: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(LIBPLUGINS)/tuxwetter.so
$(LIBPLUGINS)/tuxwetter.so: $(D)/freetype $(D)/libcurl $(D)/giflib $(D)/libjpeg $(LIBPLUGINS) $(VARCONFIG)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/tuxwetter && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-I$(N_OBJDIR) -I$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/include \
		-I$(TARGET_INCLUDE_DIR)/freetype2 \
		\
		-lfreetype -lz -lcrypto -lssl -lcurl -ljpeg -lpng -lgif \
		\
		-DWWEATHER \
		\
		fb_display.c \
		gfx.c \
		gif.c \
		gifdecomp.c \
		http.c \
		io.c \
		jpeg.c \
		parser.c \
		php.c \
		png_helper.cpp \
		pngw.cpp \
		resize.c \
		text.c \
		tuxwetter.c \
		\
		-o $@; \
	mkdir -p $(VARCONFIG)/tuxwetter/ && \
	install -m 0644 tuxwetter.mcfg $(VARCONFIG)/tuxwetter/ && \
	key=4cf30427c97b3bc5; \
	sed -i "s|^LicenseKey=.*|LicenseKey=$$key|" $(VARCONFIG)/tuxwetter/tuxwetter.mcfg && \
	install -m 0644 tuxwetter.conf $(VARCONFIG)/tuxwetter/ && \
	install -m 0644 tuxwetter.png $(VARCONFIG)/tuxwetter/ && \
	install -m 0644 convert.list $(VARCONFIG)/tuxwetter/ && \
	install -m 0644 tuxwetter.cfg $(LIBPLUGINS)/ && \
	install -m 0644 tuxwetter_hint.png $(LIBPLUGINS)/ && \
	ln -sf /lib/tuxbox/plugins/tuxwetter.so $(BIN)/tuxwetter

# -----------------------------------------------------------------------------

cooliTSclimax: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(BIN)/cooliTSclimax
$(BIN)/cooliTSclimax: $(D)/ffmpeg $(BIN)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/cooliTSclimax && \
	$(TARGET)-g++ $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-lpthread -lavformat -lavcodec -lavutil \
		\
		-D__STDC_CONSTANT_MACROS \
		\
		cooliTSclimax.cpp \
		\
		-o $@

# -----------------------------------------------------------------------------

oscammon: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(D)/zlib $(D)/freetype $(D)/openssl $(LIBPLUGINS)/oscammon.so
$(LIBPLUGINS)/oscammon.so: $(LIBPLUGINS) $(VARCONFIG)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/oscammon && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-I$(N_OBJDIR) -I$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/include \
		-I$(TARGET_INCLUDE_DIR)/freetype2 \
		\
		-lfreetype -lz -lcrypto \
		\
		oscammon.c \
		\
		-o $@ && \
	install -m 0644 oscammon.conf $(VARCONFIG)/ && \
	install -m 0644 oscammon.cfg $(LIBPLUGINS)/ && \
	install -m 0644 oscammon_hint.png $(LIBPLUGINS)/

# -----------------------------------------------------------------------------

showiframe: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(BIN)/showiframe
$(BIN)/showiframe: $(BIN)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/showiframe && \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		\
		showiframe.c \
		\
		-o $@ && \
	install -m 0755 showiframe.sh $(BIN)/

# -----------------------------------------------------------------------------

shellexec: $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS) $(LIBPLUGINS)/shellexec.so
$(LIBPLUGINS)/shellexec.so: $(D)/freetype $(LIBPLUGINS) $(SHAREFLEX) $(VARCONFIG) $(BIN)
	pushd $(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/shellexec; \
	$(TARGET)-gcc $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-I$(N_OBJDIR) -I$(SOURCE_DIR)/$(NI_NEUTRINO-PLUGINS)/include \
		-I$(TARGET_INCLUDE_DIR)/freetype2 \
		\
		-lfreetype -lz -lpng \
		\
		fb_display.c \
		gfx.c \
		io.c \
		png_helper.cpp \
		pngw.cpp \
		resize.c \
		shellexec.c \
		text.c \
		\
		-o $@ && \
	install -m 0644 shellexec.conf $(VARCONFIG)/ && \
	install -m 0644 shellexec.cfg $(LIBPLUGINS)/ && \
	install -m 0644 shellexec_hint.png $(LIBPLUGINS)/ && \
	install -m 0644 flex_plugins.conf $(SHAREFLEX)/ && \
	install -m 0644 flex_user.conf $(SHAREFLEX)/
	mv -f $(LIBPLUGINS)/shellexec.so  $(LIBPLUGINS)/00_shellexec.so
	mv -f $(LIBPLUGINS)/shellexec.cfg $(LIBPLUGINS)/00_shellexec.cfg
	mv -f $(LIBPLUGINS)/shellexec_hint.png $(LIBPLUGINS)/00_shellexec_hint.png
	ln -sf /lib/tuxbox/plugins/00_shellexec.so $(BIN)/shellexec

# -----------------------------------------------------------------------------

LINKS_PATCH  = links-$(LINKS_VER).patch
LINKS_PATCH += links-$(LINKS_VER)-ac-prog-cxx.patch
LINKS_PATCH += links-$(LINKS_VER)-input-$(BOXTYPE).patch

$(D)/links: $(D)/libpng $(D)/libjpeg $(D)/openssl $(ARCHIVE)/links-$(LINKS_VER).tar.bz2 $(LIBPLUGINS) | $(TARGET_DIR)
	$(REMOVE)/links-$(LINKS_VER)
	$(UNTAR)/links-$(LINKS_VER).tar.bz2
	$(CHDIR)/links-$(LINKS_VER)/intl; \
		sed -i -e 's|^T_SAVE_HTML_OPTIONS,.*|T_SAVE_HTML_OPTIONS, "HTML-Optionen speichern",|' german.lng; \
		echo "english" > index.txt; \
		echo "german" >> index.txt; \
		./gen-intl
	$(CHDIR)/links-$(LINKS_VER); \
		$(call apply_patches,$(LINKS_PATCH)); \
		autoreconf -vfi; \
		$(CONFIGURE) \
			--prefix= \
			--mandir=$(BUILD_TMP)/.remove \
			--enable-graphics \
			--with-fb \
			--with-libjpeg \
			--with-ssl=$(TARGET_DIR) \
			--without-atheos \
			--without-directfb \
			--without-libtiff \
			--without-lzma \
			--without-pmshell \
			--without-svgalib \
			--without-x \
			; \
		$(MAKE); \
		$(MAKE) install DESTDIR=$(TARGET_DIR)
	mv -f $(BIN)/links $(LIBPLUGINS)/links.so
	cp -a $(IMAGEFILES)/links/* $(TARGET_DIR)/
	$(REMOVE)/links-$(LINKS_VER)
	$(TOUCH)
