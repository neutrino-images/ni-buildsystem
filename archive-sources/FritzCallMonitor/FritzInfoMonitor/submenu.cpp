
#include <fstream>
#include <iostream>
#include <sstream>

#include "parser.h"
#include "connect.h"
#include "framebuffer.h"
#include "icons.h"
#include "globals.h"

#include "submenu.h"

CSubMenu* CSubMenu::getInstance()
{
	static CSubMenu* instance = NULL;
	if(!instance)
		instance = new CSubMenu();
	return instance;
}

CSubMenu::CSubMenu()
{
	cpars	= CParser::getInstance();
	cfb	= Cfb::getInstance();
	cicons	= CIcons::getInstance();

	int ex, sx, ey, sy;
	cfb->getDimensions(&ex, &sx, &ey, &sy);
	int vyres = cfb->getYScreeninfo();

	bspace	= 40;
	lrspace	= 30;
	xwidth	= ex-sx-bspace;
	yheight	= ey-sy-bspace;
	xcenter	= (xwidth/2)+(bspace/2);
	ycenter	= (yheight/2)+(bspace/2);

	ld = vyres < 600 ? 35 : 35;	//line distance
	so = 5;				//shadow offset

	S_SUBMENU entry;

	/*MENU*/
	entry.sel	= 0;
	entry.mwidth	= 400;
	entry.mitems	= 5;
	subMenu.push_back(entry);

	/*PHONEBOOK*/
	entry.sel	= 0;
	entry.mwidth	= 320;
	entry.mitems	= 4;
	subMenu.push_back(entry);

	/*CALLER_DETAILS*/
	entry.sel	= 0;
	entry.mwidth	= 400;
	entry.mitems	= 4;
	subMenu.push_back(entry);

	/*DIAL*/
	entry.sel	= 0;
	entry.mwidth	= 420;
	entry.mitems	= (int)(sizeof(CParser::getInstance()->dialport)/sizeof(CParser::getInstance()->dialport[0]));
	subMenu.push_back(entry);
};

CSubMenu::~CSubMenu()
{
}

/******************************************************************************
 * ShowMenu (submenu)
 ******************************************************************************/
void CSubMenu::ShowSubMenu(int menu)
{
	printf("[%s] - %s %s(%d)\n",BASENAME, __FILE__, __FUNCTION__, menu);

	int mitems	= subMenu[menu].mitems;
	int mwidth	= subMenu[menu].mwidth;
	int selected	= subMenu[menu].sel;

	int vsx		= ycenter - ((mitems/2)*ld);
	int mhw		= mwidth/2;
	int i		= 0;
	int mlrspace	= 0;
	std::ostringstream msg;

	// Grafic
	cfb->RenderBox(xcenter+mhw, vsx-ld+so, xcenter+mhw+so, vsx+(ld*mitems)+(ld/2), FILL, BLACK);
	cfb->RenderBox(xcenter-mhw+so, vsx+(ld*mitems), xcenter+mhw+so, vsx+(ld*mitems)+(ld/2)+so, FILL, BLACK);

	cfb->RenderBox(xcenter-mhw, vsx-ld, xcenter+mhw, vsx+(ld*mitems), FILL, CMH);
	cfb->RenderBox(xcenter-mhw, vsx, xcenter+mhw, vsx+(ld*mitems)+(ld/2), FILL, CMC);

	switch(menu)
	{
		case MENU:

			cfb->RenderString("FRITZ! Info-Menü", xcenter-mhw, vsx-(ld/3), (xcenter+mhw)-(xcenter-mhw), CENTER, NORMAL, CMHT);

			// selected
			if(selected < 0)
				selected = mitems -1;
			else if (selected > (mitems -1))
				selected = 0;

			subMenu[menu].sel = selected;
			cfb->RenderBox(xcenter-mhw, vsx+(ld/3)+(selected*ld), xcenter+mhw, vsx+(ld/4)+((selected+1)*ld), FILL, CMHT);

			i = 0;
			mlrspace = lrspace + 10;
			cfb->RenderCircle( xcenter-mhw+(mlrspace/3), vsx+((i+1)*ld)-15, RED);
			cfb->RenderString("Telefonbuch der FRITZ!Box übernehmen", xcenter-mhw+mlrspace, vsx+((i+1)*ld), (xcenter+mhw)-(xcenter-mhw), LEFT, NORMAL, selected==i?CMC:CMCT);

			i++;
			cfb->RenderCircle( xcenter-mhw+(mlrspace/3), vsx+((i+1)*ld)-15, GREEN);
			cfb->RenderString("Wählhilfe", xcenter-mhw+mlrspace, vsx+((i+1)*ld), (xcenter+mhw)-(xcenter-mhw), LEFT, NORMAL, selected==i?CMC:CMCT);

			i++;
			cfb->RenderCircle( xcenter-mhw+(mlrspace/3), vsx+((i+1)*ld)-15, YELLOW);
			cfb->RenderString("Internet trennen und neu verbinden", xcenter-mhw+mlrspace, vsx+((i+1)*ld), (xcenter+mhw)-(xcenter-mhw), LEFT, NORMAL, selected==i?CMC:CMCT);

			i++;
			cfb->RenderCircle( xcenter-mhw+(mlrspace/3), vsx+((i+1)*ld)-15, BLUE);
			cfb->RenderString("Anrufliste aktualisieren", xcenter-mhw+mlrspace, vsx+((i+1)*ld), (xcenter+mhw)-(xcenter-mhw), LEFT, NORMAL, selected==i?CMC:CMCT);

			i++;
			cfb->PaintIcon(cicons->getIcon_1(), xcenter-mhw+(mlrspace/3)-5, vsx+((i+1)*ld)-15-5);
			cfb->RenderString("Adressbuch öffnen", xcenter-mhw+mlrspace, vsx+((i+1)*ld), (xcenter+mhw)-(xcenter-mhw), LEFT, NORMAL, selected==i?CMC:CMCT);

			break;
		case PHONEBOOK:
			cfb->RenderString("Telefonbuch Menü", xcenter-mhw, vsx-(ld/3), (xcenter+mhw)-(xcenter-mhw), CENTER, NORMAL, CMHT);

			// selected
			if(selected < 0)
				selected = mitems -1;
			else if (selected > (mitems -1))
				selected = 0;

			subMenu[menu].sel = selected;
			cfb->RenderBox(xcenter-mhw, vsx+(ld/3)+(selected*ld), xcenter+mhw, vsx+(ld/4)+((selected+1)*ld), FILL, CMHT);

			for(i=0; i<mitems; i++)
			{
				int icon=0;
				switch(i)
				{
					case 0: icon = RED;	break;
					case 1: icon = GREEN;	break;
					case 2: icon = YELLOW;	break;
					case 3: icon = BLUE;	break;
				}
				cfb->RenderCircle( xcenter-mhw+(lrspace/3), vsx+((i+1)*ld)-15, icon);
				msg.str("");
				msg << "Telefonbuch Nr." << i+1 << " übernehmen";
				cfb->RenderString(msg.str().c_str(), xcenter-mhw+lrspace, vsx+((i+1)*ld), (xcenter+mhw)-(xcenter-mhw-lrspace), LEFT, NORMAL, selected==i?CMC:CMCT);
			}
			break;
	}

	cfb->FBPaint();
}

void CSubMenu::DialMenu(int dialtest)
{
	printf("[%s] - %s %s(%d)\n",BASENAME, __FILE__, __FUNCTION__, dialtest);

	int mitems	= subMenu[DIAL].mitems;
	int mwidth	= subMenu[DIAL].mwidth;
	int selected	= subMenu[DIAL].sel;

	int vsx		= ycenter - ((mitems/2)*ld);
	int mhw		= mwidth/2;

	std::ostringstream msg;

	// Grafic
	cfb->RenderBox(xcenter+mhw, vsx-ld+so, xcenter+mhw+so, vsx+(ld*mitems)+(ld/2), FILL, BLACK);
	cfb->RenderBox(xcenter-mhw+so, vsx+(ld*mitems), xcenter+mhw+so, vsx+(ld*mitems)+(ld/2)+so, FILL, BLACK);

	cfb->RenderBox(xcenter-mhw, vsx-ld, xcenter+mhw, vsx+(ld*mitems), FILL, CMH);
	cfb->RenderBox(xcenter-mhw, vsx, xcenter+mhw, vsx+(ld*mitems)+(ld/2), FILL, CMC);

	cfb->RenderString("Wählhilfe Menü", xcenter-mhw, vsx-(ld/3), (xcenter+mhw)-(xcenter-mhw), CENTER, NORMAL, CMHT);

	// selected
	if(selected < 0)
		selected = mitems -1;
	else if (selected > (mitems -1))
		selected = 0;

	subMenu[DIAL].sel = selected;
	cfb->RenderBox(xcenter-mhw, vsx+(ld/3)+(selected*ld), xcenter+mhw, vsx+(ld/4)+((selected+1)*ld), FILL, CMHT);

	for(int i=0; i<mitems; i++)
	{
		cfb->RenderString(CParser::getInstance()->dialport[i].port_name, xcenter-mhw+lrspace, vsx+(i*ld)+ld, (xcenter+mhw)-(xcenter-mhw-30), LEFT, NORMAL, selected==i?CMC:CMCT);
		msg.str("");
		msg << "(Intern **" << CParser::getInstance()->dialport[i].port << ')';
		cfb->RenderString(msg.str().c_str(), xcenter-mhw+260, vsx+(i*ld)+ld, (xcenter+mhw)-(xcenter-mhw-lrspace), LEFT, NORMAL, selected==i?CMC:CMCT);
	}

	//footer
	if(dialtest)
	{
		cfb->RenderBox(xcenter-mhw+so, vsx+(ld*mitems)+(ld/2), xcenter+mhw+so, vsx+(ld*mitems)+(ld/2)+23+so, FILL, BLACK); //shadow
		cfb->RenderBox(xcenter-mhw, vsx+(ld*mitems)+(ld/2), xcenter+mhw, vsx+(ld*mitems)+(ld/2)+23, FILL, CMH);

		cfb->PaintIcon(cicons->getIcon_ok(), xcenter-mhw+30, vsx+(ld*mitems)+(ld/2));
		cfb->RenderString("Testen", xcenter-mhw+60, vsx+(ld*mitems)+(ld/2)+20, (xcenter+mhw)-(xcenter-mhw-30), LEFT, SMALL, GREY);
	}

	cfb->FBPaint();
}

void CSubMenu::CallerMenu(int rs_result, int callsel)
{
	printf("[%s] - %s %s(%d,%d)\n",BASENAME, __FILE__, __FUNCTION__, rs_result, callsel);

	int mitems	= subMenu[CALLER_DETAILS].mitems;
	int mwidth	= subMenu[CALLER_DETAILS].mwidth;
	//int selected	= subMenu[CALLER_DETAILS].sel;

	int vsx		= ycenter - ((mitems/2)*ld);
	int mhw		= mwidth/2;

	std::ostringstream msg;

	// Grafic
	cfb->RenderBox(xcenter+mhw, vsx-ld+so, xcenter+mhw+so, vsx+(ld*mitems)+(ld/2), FILL, BLACK);
	cfb->RenderBox(xcenter-mhw+so, vsx+(ld*mitems), xcenter+mhw+so, vsx+(ld*mitems)+(ld/2)+so, FILL, BLACK);

	cfb->RenderBox(xcenter-mhw, vsx-ld, xcenter+mhw, vsx+(ld*mitems), FILL, CMH);
	cfb->RenderBox(xcenter-mhw, vsx, xcenter+mhw, vsx+(ld*mitems)+(ld/2), FILL, CMC);

	cfb->RenderString(rs_result?"GoYellow":"Details", xcenter-mhw, vsx-(ld/3), (xcenter+mhw)-(xcenter-mhw), CENTER, NORMAL, CMHT);
	int i=0;

	cfb->RenderString(cpars->caller[callsel].call_numr, xcenter-mhw+lrspace, vsx+(i*ld)+ld, (xcenter+mhw)-(xcenter-mhw), LEFT, NORMAL, CMCT);
	i++;

	cfb->RenderString((cpars->address.name[0]=='\0'?"Name unbekannt":cconnect->UTF8toISO(cpars->address.name)), xcenter-mhw+lrspace, vsx+(i*ld)+ld, (xcenter+mhw)-(xcenter-mhw), LEFT, NORMAL, CMCT);
	i++;

	cfb->RenderString((cpars->address.street[0]=='\0'?"Straße unbekannt":cconnect->UTF8toISO(cpars->address.street)), xcenter-mhw+lrspace, vsx+(i*ld)+ld, (xcenter+mhw)-(xcenter-mhw), LEFT, NORMAL, cpars->address.street[0]=='\0'?GREY:CMCT);
	i++;

	msg.str("");
	msg << (cpars->address.code[0]=='\0' ? "Ort unbekannt" : cpars->address.code) << ' ' << cconnect->UTF8toISO(cpars->address.locality);
	cfb->RenderString(msg.str().c_str(), xcenter-mhw+lrspace, vsx+(i*ld)+ld, (xcenter+mhw)-(xcenter-mhw), LEFT, NORMAL, cpars->address.code[0]=='\0'?GREY:CMCT);

	//footer
	if(strlen(cpars->caller[callsel].call_numr)!=0)
	{
		cfb->RenderBox(xcenter-mhw+so, vsx+(ld*mitems)+(ld/2), xcenter+mhw+so, vsx+(ld*mitems)+(ld/2)+23+so, FILL, BLACK); //shadow
		cfb->RenderBox(xcenter-mhw, vsx+(ld*mitems)+(ld/2), xcenter+mhw, vsx+(ld*mitems)+(ld/2)+23, FILL, CMH);

		cfb->RenderCircle( xcenter-mhw+(lrspace/3), vsx+(ld*mitems)+(ld/2)+5, RED);
		cfb->RenderString("Anrufen", xcenter-mhw+30, vsx+(ld*mitems)+(ld/2)+20, (xcenter+mhw)-(xcenter-mhw-30), LEFT, SMALL, GREY);

		cfb->RenderCircle( xcenter-mhw+110, vsx+(ld*mitems)+(ld/2)+5, BLUE);
		cfb->RenderString("Rückwärtssuche", xcenter-mhw+30+110, vsx+(ld*mitems)+(ld/2)+20, (xcenter+mhw)-(xcenter-mhw-30), LEFT, SMALL, GREY);

		if(rs_result)
		{
			cfb->RenderCircle( xcenter-mhw+270, vsx+(ld*mitems)+(ld/2)+5, YELLOW);
			cfb->RenderString("Speichern", xcenter-mhw+30+270, vsx+(ld*mitems)+(ld/2)+20, (xcenter+mhw)-(xcenter-mhw-30), LEFT, SMALL, GREY);
		}

	}

	cfb->FBPaint();
}

void CSubMenu::ShowMessage(int message, int popup)
{
	printf("[%s] - %s %s(%d,%d)\n",BASENAME, __FILE__, __FUNCTION__, message, popup);

	int mitte	= xcenter;
	int so		= 5;
	std::ostringstream msg;

	//shadow
	cfb->RenderBox(mitte+190, 178+so, mitte+200+so, 340, FILL, BLACK);
	cfb->RenderBox(mitte-200+so, 300, mitte+200+so, 340+so, FILL, BLACK);

	cfb->RenderBox(mitte-200, 178, mitte+200, 220, FILL, CMH);
	cfb->RenderBox(mitte-200, 220, mitte+200, 340, FILL, CMC);

	switch(message)
	{
		case INFO:
			cfb->RenderString("Versionsinfo", mitte-180, 210, (mitte+180)-(mitte-180), CENTER, NORMAL, CMHT);
			msg.str("");
			msg << "FritzInfoMonitor " << VERSION;
			cfb->RenderString(msg.str().c_str(), mitte-180, 255, (mitte+180)-(mitte-180), CENTER, NORMAL, CMCT);
			cfb->RenderString(COPYR, mitte-180, 290, (mitte+180)-(mitte-180), CENTER, NORMAL, CMCT);
			break;
		case INFO_ADDADR:
			cfb->RenderString("Information", mitte-180, 210, (mitte+180)-(mitte-180), CENTER, NORMAL, CMHT);
			cfb->RenderString("Eintrag wurde hinzugefügt", mitte-180, 270, (mitte+180)-(mitte-180), CENTER, NORMAL, CMCT);
			break;
		case INFO_DIAL:
			cfb->RenderString("Wählhilfe", mitte-180, 210, (mitte+180)-(mitte-180), CENTER, NORMAL, CMHT);
			cfb->RenderString("Bitte den Hörer abnehmen, oder warten", mitte-180, 255, (mitte+180)-(mitte-180), CENTER, NORMAL, CMCT);
			cfb->RenderString("Sie, bis das Telefon klingelt.", mitte-180, 290, (mitte+180)-(mitte-180), CENTER, NORMAL, CMCT);
			break;
		case INFO_DIALTEST:
			cfb->RenderString("Wählhilfe", mitte-180, 210, (mitte+180)-(mitte-180), CENTER, NORMAL, CMHT);
			cfb->RenderString("Das Telefon sollte jetzt klingeln", mitte-180, 270, (mitte+180)-(mitte-180), CENTER, NORMAL, CMCT);
			break;
		case INFO_PHONEBOOK:
			cfb->RenderString("Information", mitte-180, 210, (mitte+180)-(mitte-180), CENTER, NORMAL, CMHT);
			msg.str("");
			msg << "Telefonbuch " << subMenu[PHONEBOOK].sel+1 << " wird übertragen";
			cfb->RenderString(msg.str().c_str(), mitte-180, 270, (mitte+180)-(mitte-180), CENTER, NORMAL, CMCT);
			break;
		case INFO_RSEARCH:
			cfb->RenderString("GoYellow", mitte-180, 210, (mitte+180)-(mitte-180), CENTER, NORMAL, CMHT);
			cfb->RenderString("Leider haben wir nichts gefunden!", mitte-180, 270, (mitte+180)-(mitte-180), CENTER, NORMAL, CMCT);
			break;
		case INFO_RECONNECT :
			cfb->RenderString("Information", mitte-180, 210, (mitte+180)-(mitte-180), CENTER, NORMAL, CMHT);
			cfb->RenderString("Neustart der Internetverbindung", mitte-180, 270, (mitte+180)-(mitte-180), CENTER, NORMAL, CMCT);
			break;
		case ERR_LOGIN:
			cfb->RenderString("Fehler!", mitte-180, 210, (mitte+180)-(mitte-180), CENTER, NORMAL, CMHT);
			cfb->RenderString("Fehler bei der Anmeldung", mitte-180, 255, (mitte+180)-(mitte-180), CENTER, NORMAL, CMCT);
			cfb->RenderString("Login nicht erfolgreich", mitte-180, 290, (mitte+180)-(mitte-180), CENTER, NORMAL, CMCT);
			break;
		case ERR_CONNECT:
			cfb->RenderString("Fehler!", mitte-180, 210, (mitte+180)-(mitte-180), CENTER, NORMAL, CMHT);
			cfb->RenderString("Die Box ist nicht erreichbar", mitte-180, 255, (mitte+180)-(mitte-180), CENTER, NORMAL, CMCT);
			cfb->RenderString(cpars->getFritzAdr(), mitte-180, 290, (mitte+180)-(mitte-180), CENTER, NORMAL, CMCT);
			break;
		case LOAD:
			cfb->RenderString("Information", mitte-180, 210, (mitte+180)-(mitte-180), CENTER, NORMAL, CMHT);
			cfb->RenderString("Hole Daten von der FRITZ!Box ...", mitte-180, 270, (mitte+180)-(mitte-180), CENTER, NORMAL, CMCT);
			break;
	}

	if(!popup)
	{
		cfb->RenderBox(mitte-50, 305, mitte+50, 330, FILL, CMHT);
		cfb->RenderString("zurück", mitte-10, 325, 60, LEFT, SMALL, CMC);
		cfb->PaintIcon(cicons->getIcon_ok(), mitte-40 ,305);
	}

	cfb->FBPaint();
}
