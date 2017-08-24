
#ifndef __FritzInfoMonitor_h__
#define __FritzInfoMonitor_h__

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

class CFIM
{
	public:
		CFIM();
		~CFIM();
		static CFIM* getInstance();

		int run(int argc, char *argv[]);

	private:
		CConnect * cconnect;
		CParser  * cpars;
		Cfb 	 * cfb;
		Crc	 * crc;
		CIcons	 * cicons;

		enum MAINMENU_INIT
		{
			REPAINT,
			LOGIN,
			CINFO,
		};

		int startx, starty, sx, ex, sy, ey;

		void	Cleanup(void);
		void	DoExec(int function);

		// grafische Funktionen
		void	Mainmenu(int init);
		void	ShowMessage(int message, int popup);
		void	ShowMenu(int menu);

		int startitem, perpage, repaint, callsel, rs_result, dialtest;
};

#endif// __FritzInfoMonitor_h__
