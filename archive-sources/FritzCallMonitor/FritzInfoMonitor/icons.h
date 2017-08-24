
#ifndef __icons_h__
#define __icons_h__

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

class CIcons
{
	public:
		CIcons();
		~CIcons();
		static CIcons* getInstance();

		unsigned char * getIcon_ni();
		unsigned char * getIcon_phone1();
		unsigned char * getIcon_phone2();
		unsigned char * getIcon_phone3();
		//unsigned char * getIcon_up();
		//unsigned char * getIcon_down();
		//unsigned char * getIcon_plus();
		//unsigned char * getIcon_minus();
		//unsigned char * getIcon_power_button();
		unsigned char * getIcon_help();
		//unsigned char * getIcon_info();
		//unsigned char * getIcon_mute_small();
		unsigned char * getIcon_left();
		unsigned char * getIcon_right();
		//unsigned char * getIcon_lock();
		//unsigned char * getIcon_dbox();
		//unsigned char * getIcon_lame();
		unsigned char * getIcon_ok();
		//unsigned char * getIcon_home();
		unsigned char * getIcon_1();
		//unsigned char * getIcon_2();
		//unsigned char * getIcon_3();
	private:
};

#endif// __icons_h__
