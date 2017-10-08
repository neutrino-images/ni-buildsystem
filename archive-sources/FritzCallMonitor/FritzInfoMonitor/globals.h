
#ifndef __globals_h__
#define __globals_h__

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

//settings
#define KBLCKFILE "/tmp/keyboard.lck"
#define NEUTRINOCONF "/var/tuxbox/config/neutrino.conf"
#define CONFIGFILE "/var/tuxbox/config/FritzCallMonitor.cfg"

#define BASENAME "FIM"
#define VERSION "V4.4"
#define COPYR "2011 (c) FlatTV"

/* rc codes */
#define	RC_0		'0'
#define	RC_1		'1'
#define	RC_2		'2'
#define	RC_3		'3'
#define	RC_4		'4'
#define	RC_5		'5'
#define	RC_6		'6'
#define	RC_7		'7'
#define	RC_8		'8'
#define	RC_9		'9'

#define	RC_RIGHT	0x0191
#define	RC_LEFT		0x0192
#define	RC_UP		0x0193
#define	RC_DOWN		0x0194
#define	RC_PLUS		0x0195
#define	RC_MINUS	0x0196

#define	RC_OK		0x0D
#define	RC_STANDBY	0x1C
#define RC_ESC		RC_HOME

#define	RC_HOME		0x01B1
#define	RC_MUTE		0x01B2
#define	RC_HELP		0x01B3
#define	RC_DBOX		0x01B4
#define	RC_INFO		RC_HELP

#define	RC_GREEN	0x01A1
#define	RC_YELLOW	0x01A2
#define	RC_RED		0x01A3
#define	RC_BLUE		0x01A4

#define RC_PAUSE	RC_HELP
#define RC_ALTGR	0x12
#define RC_BS		0x7F
#define RC_POS1		RC_HOME
#define RC_END		0x13
#define RC_INS		0x10
#define RC_ENTF		0x11
#define RC_STRG		0x00
#define RC_LSHIFT	0x0E
#define RC_RSHIFT	0x0E
#define RC_ALT		0x0F
#define RC_NUM		RC_DBOX
#define RC_ROLLEN	0x00
#define RC_F5		RC_DBOX
#define RC_F6		RC_HELP
#define RC_F7		RC_MUTE
#define RC_F8		0x01C8
#define RC_F9		0x01C9
#define RC_F10		0x01CA
#define RC_RET		0x0D
#define RC_RET1		0x01CC
#define RC_CAPSLOCK	0x01CD
#define RC_ON		0x01CE

#define RC_F1		RC_RED
#define RC_F2		RC_GREEN
#define RC_F3		RC_YELLOW
#define RC_F4		RC_BLUE
#define RC_PAGEUP	104
#define RC_PAGEDOWN	109

//framebuffer
enum {	FILL, GRID};
enum {	LEFT, CENTER, RIGHT};
enum {	SMALL, NORMAL, BIG};

//parser
enum {	TRANSP	,BLACK	,RED	   ,GREEN,
	BROWN	,BLUE	,MAGENTA   ,CYAN,
	GREY	,B_GREY	,B_RED	   ,B_GREEN,
	YELLOW	,B_BLUE ,B_MAGENTA ,B_CYAN,
	WHITE	,CMH	,CMHT	   ,CMC,
	CMCT 	,ORANGE	,SKIN0	   ,SKIN1
};

enum MENU
{
	MENU,
	PHONEBOOK,
	CALLER_DETAILS,
	DIAL,
	RECONNECT,
	REFRESHCALL,
	ADDADR,
	RSEARCH,
	ADDRESSBOOK
};

enum MESSAGE
{
	ERR_CONNECT,
	ERR_LOGIN,
	INFO,
	INFO_ADDADR,
	INFO_DIALTEST,
	INFO_DIAL,
	INFO_PHONEBOOK,
	INFO_RSEARCH,
	INFO_RECONNECT,
	LOAD
};

#endif //__globals_h__
