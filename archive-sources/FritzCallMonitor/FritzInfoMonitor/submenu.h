
#ifndef __submenu_h__
#define __submenu_h__

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include "icons.h"

#include <vector>
using namespace std;

class CSubMenu
{
	public:
		CSubMenu();
		~CSubMenu();
		static CSubMenu* getInstance();

		void	ShowMessage(int message, int popup);
		void	ShowSubMenu(int menu);
		void	CallerMenu(int rs_result, int callsel);
		void	DialMenu(int dialtest);

		struct S_SUBMENU {
			int sel;
			int mwidth;
			int mitems;
		};
		vector<S_SUBMENU> subMenu;

	private:
		CParser  * cpars;
		CConnect * cconnect;
		Cfb 	 * cfb;
		CIcons	 * cicons;

//		int callsel, rs_result, dialtest;
		int bspace, lrspace, xwidth, yheight;
		int xcenter, ycenter;
		int ld, so;
};

#endif// __submenu_h__
