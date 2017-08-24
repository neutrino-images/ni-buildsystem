
#include <sstream>
#include <fcntl.h>
#include <unistd.h>

#include "parser.h"
#include "connect.h"
#include "framebuffer.h"
#include "rc.h"
#include "icons.h"
#include "submenu.h"
#include "phonebook.h"
#include "globals.h"

#include "FritzInfoMonitor.h"

CFIM* CFIM::getInstance()
{
	static CFIM* instance = NULL;
	if(!instance)
		instance = new CFIM();
	return instance;
}

CFIM::CFIM()
{
	cpars	 = CParser::getInstance();
	cconnect = CConnect::getInstance();
	cfb	 = Cfb::getInstance();
	crc	 = Crc::getInstance();
	cicons	 = CIcons::getInstance();

	startitem=0, perpage=MAXCALLER, repaint=1, callsel=0, rs_result=0, dialtest=1;

	cfb->init();

	cfb->getDimensions(&ex, &sx, &ey, &sy);
	cfb->getStartDimensions(&startx, &starty);
};

CFIM::~CFIM()
{
	Cleanup();
}

/******************************************************************************
 * Mainmenu
 ******************************************************************************/
void CFIM::Mainmenu(int init)
{
	printf("[%s] - %s(%d)\n",BASENAME, __FUNCTION__, init);
	int bspace = 40;
	int lrspace = 30;
	int vsx = bspace + lrspace;
	int vsy = 80;
	int breite = ex-sx - bspace;
	int tiefe = ey-sy - bspace;
	int zeilenabstand = cfb->getYScreeninfo() < 600 ? 25 : 28;
	std::ostringstream txt;

	int sp1 = vsx+30;
	int le1 = 140;	//Datum
	int sp2 = sp1+le1+18;
	int le2 = 180;	//Name
	int sp3 = sp2+le2+18;
	int le3 = 180;	//Rufnummer
	int sp4 = sp3+le3+18;
	int le4 = 180;	//Telefoniegerät
	int sp5 = sp4+le4+18;
	int le5 = 140;	//Eigene Nummer
	int sp6 = sp5+le5+18;
	int le6 = 60;	//Dauer

	// Grafikausgabe
	cfb->RenderBox(bspace, 0, breite, tiefe, FILL, CMC);
	cfb->RenderBox(bspace, 0, breite, 40, FILL, CMH);

	cfb->PaintIcon(cicons->getIcon_ni(),((breite+bspace)/2)-(120/2)-35,8);
	cfb->RenderString("FRITZ! Info", ((breite+bspace)/2)-(120/2) ,30, 120, CENTER, BIG, CMHT);

	// Footer
	cfb->RenderBox(bspace, tiefe, breite, tiefe+30, FILL, CMH);

	cfb->RenderCircle( vsx, tiefe+6, RED);
	cfb->RenderString("Menü", sp1, tiefe+20, 100, LEFT, SMALL, GREY);

	cfb->PaintIcon(cicons->getIcon_right(), sp2, tiefe);
	if(startitem > 0)
		cfb->PaintIcon(cicons->getIcon_left(), sp2+20, tiefe);
	cfb->RenderString("Anrufliste", startitem > 0 ? sp2+20+30 : sp2+30, tiefe+20, 150, LEFT, SMALL, GREY);

	cfb->PaintIcon(cicons->getIcon_help(), sp3, tiefe);
	cfb->RenderString("Info", sp3+30, tiefe+20, 100, LEFT, SMALL, GREY);

	if(init == LOGIN)
	{
		vsy += zeilenabstand;
		cfb->RenderString("Sende Login ...", vsx, vsy, 200, LEFT, NORMAL, CMCT);
	}
	else if(!init || init == CINFO)
	{
		txt.str("");
		txt << "Firmware: " << cpars->getNspver();
		cfb->RenderString(txt.str().c_str(), breite-200-lrspace, vsy-7, 200, RIGHT, SMALL, GREY);

		vsy += zeilenabstand;
		cfb->RenderString("Komfortinfo", vsx ,vsy, 200, LEFT, NORMAL, CMHT);
		vsy += zeilenabstand+7;

		txt.str("");
		txt << "Anrufbeantworter: " << (atoi(cpars->getTam0_active().c_str())?"Aktiv, ":"Inaktiv, ") << (atoi(cpars->getTam0_NumNewMessages().c_str())) << " neue Nachrichten";
		cfb->RenderString(txt.str().c_str(), vsx, vsy, breite-vsx-lrspace, LEFT, NORMAL, CMCT);
		vsy += zeilenabstand;

		char str[30];
		switch(atoi(cpars->getDdns_state().c_str()))
		{
			case  0: strcpy(str,"Fehler")			;break;
			case  3: strcpy(str,"Anmeldung")		;break;
			case  5: strcpy(str,"Angemeldet")		;break;//Erfolgreich angemeldet
			case 97: strcpy(str,"Account deaktiviert")	;break;
			case 98: strcpy(str,"Internet nicht verbunden")	;break;
			case 99: strcpy(str,"Unbekannt")		;break;
			default: strcpy(str,"Anmeldung läuf")		;break;
		}

		string ddns_domain = cpars->getDdns_domain();
		int ddns_state = atoi(cpars->getDdns_state().c_str());

		txt.str("");
		txt << "Dynamic DNS: " <<  str << (ddns_domain.empty() ? " " : ", ") << (ddns_state ==0 ? cpars->getPppoe_ip() : ddns_domain);
		cfb->RenderString(txt.str().c_str(), vsx, vsy, breite-vsx-lrspace, LEFT, NORMAL, CMCT);
		vsy += zeilenabstand;
	}

	if(!init)
	{
		int i=0;
		vsy += zeilenabstand;
		int csy = vsy;

		if(breite > (sp4+le4)) cfb->RenderString("Telefoniegerät", sp4, vsy, le4, LEFT, NORMAL, CMHT);
		if(breite > (sp5+le5)) cfb->RenderString("Eigene Nummer", sp5, vsy, le5, LEFT, NORMAL, CMHT);
		if(breite > (sp6+le6)) cfb->RenderString("Dauer", sp6, vsy, le6, LEFT, NORMAL, CMHT);

		vsy += 7;

		if(callsel > perpage-1)
			callsel=0;
		else if(callsel < 0)
			callsel=perpage-1;

		unsigned mystart = vsy+zeilenabstand;
		unsigned vsi = zeilenabstand;
		for (i=0; i < MAXCALLER; i++)
		{
			vsy += zeilenabstand;

			//selected;
			if(callsel==i)
				cfb->RenderBox(bspace, mystart+((callsel-1)*vsi+2), breite, mystart+(callsel*vsi+5), FILL, CMHT);

			cfb->PaintIcon(atoi(cpars->caller[i].call_type)==1?cicons->getIcon_phone1():atoi(cpars->caller[i].call_type)==2?cicons->getIcon_phone2():cicons->getIcon_phone3(),vsx,vsy-23);

			cfb->RenderString(cpars->caller[i].call_date, sp1, vsy, le1, LEFT, NORMAL, callsel==i?CMC:CMCT);

			if(strlen(cpars->caller[i].call_name)==0 && strlen(cpars->caller[i].call_numr)!=0) {
				if(cpars->search_AddrBook(cpars->caller[i].call_numr)) {
					strcpy(cpars->caller[i].call_name,cpars->address.name);
					cpars->init_address();
				}
				else
					strcpy(cpars->caller[i].call_name,"nicht gefunden");
			}
			if(strlen(cpars->caller[i].call_numr)==0)
				strcpy(cpars->caller[i].call_name,"unbekannt");

			cfb->RenderString(cconnect->UTF8toISO(cpars->caller[i].call_name)/*txt*/, sp2, vsy, le2, LEFT, NORMAL, callsel==i?CMC:CMCT);
			cfb->RenderString((strlen(cpars->caller[i].call_numr)==0 ? "keine Rufnummer" : cpars->caller[i].call_numr), sp3, vsy, le3, LEFT, NORMAL, callsel==i?CMC:CMCT);

			if(breite > (sp4+le4))
			{
				cfb->RenderString(cpars->caller[i].port_name, sp4, vsy, le4, LEFT, NORMAL, callsel==i?CMC:CMCT);
			}
			if(breite > (sp5+le5))
			{
				cfb->RenderString(cpars->caller[i].port_rout, sp5, vsy, le5, LEFT, NORMAL, callsel==i?CMC:CMCT);
			}
			if(breite > (sp6+le6))
			{
				cfb->RenderString(cpars->caller[i].call_time, sp6, vsy, le6, LEFT, NORMAL, callsel==i?CMC:CMCT);
			}

			if(vsy >= tiefe-50)
			{
				// RenderString("----", sp1, vsy, le1, LEFT, NORMAL, CMHT);
				perpage = i+1;
				break;
			}
		}

		txt.str("");
		txt << "Anrufe " << startitem+1 << " bis " << startitem+perpage;
		cfb->RenderString(txt.str().c_str(), vsx, csy, 300, LEFT, NORMAL, CMHT);

	}
	else if (init==2)
	{
		vsy += zeilenabstand;
		cfb->RenderString("Anrufe", vsx, vsy, 700, LEFT, NORMAL, CMHT);
		vsy += 7;
		vsy += zeilenabstand;
		cfb->RenderString("Hole Daten von der FRITZ!Box ...", vsx, vsy, 306, LEFT, NORMAL, CMCT);
	}

	cfb->FBPaint();
}

/******************************************************************************
 * ShowMessage
 ******************************************************************************/
void CFIM::ShowMessage(int message, int popup)
{

	CSubMenu::getInstance()->ShowMessage(message, popup);

	if(!popup)
	{
		unsigned short rccode;
		while(((rccode=crc->getrc())!=RC_HOME) && (rccode!=RC_OK));

		if(message == INFO) {
			Mainmenu(REPAINT);
		}
		else if(message == INFO_DIALTEST) {
			Mainmenu(REPAINT);
		}
		else {
			Cleanup();
			exit(1);
		}
	}
}

/******************************************************************************
 * ShowMenu (submenu)
 ******************************************************************************/
void CFIM::ShowMenu(int menu)
{
	printf("[%s] - %s(%d)\n",BASENAME, __FUNCTION__, menu);
	//show menu
	switch(menu)
	{
		case MENU:
		case PHONEBOOK:
			CSubMenu::getInstance()->ShowSubMenu(menu);
			break;
		case DIAL:
			CSubMenu::getInstance()->DialMenu(dialtest);
			break;
		case CALLER_DETAILS:
			CSubMenu::getInstance()->CallerMenu(rs_result, callsel);
			break;
	}

	//get rc code
	unsigned short rccode;
	do
	{
		switch((rccode = crc->getrc()))
		{
			case RC_UP:
				CSubMenu::getInstance()->subMenu[menu].sel--;
				ShowMenu(menu);
				rccode=RC_HOME;
				break;
			case RC_DOWN:
				CSubMenu::getInstance()->subMenu[menu].sel++;
				ShowMenu(menu);
				rccode=RC_HOME;
				break;
			case RC_OK:
				DoExec(menu);
				break;
			case RC_HOME:
				switch(menu)
				{
					case MENU:
						Mainmenu(REPAINT);
						break;
					case DIAL:
					case PHONEBOOK:
						cfb->FBClear();
						ShowMenu(MENU);
						break;
				}
				break;
			case RC_RED:
				switch(menu)
				{
					case MENU:
						cfb->FBClear();
						ShowMenu(PHONEBOOK);
						break;
					case CALLER_DETAILS:
						dialtest=0;
						ShowMenu(DIAL);
						break;
				}
				rccode=RC_HOME;
				break;
			case RC_GREEN:
				cfb->FBClear();
				ShowMenu(DIAL);
				rccode=RC_HOME;
				break;
			case RC_YELLOW:
				switch(menu)
				{
					case CALLER_DETAILS:
						if(rs_result)
							DoExec(ADDADR);
						break;
					case MENU:
						DoExec(RECONNECT);
						break;
				}
				rccode=RC_HOME;
				break;
			case RC_BLUE:
				switch(menu)
				{
					case MENU:
						DoExec(REFRESHCALL);
						break;
					case CALLER_DETAILS:
						DoExec(RSEARCH);
						break;
				}
				rccode=RC_HOME;
				break;
			case RC_1:
				DoExec(ADDRESSBOOK);
				rccode=RC_HOME;
				break;
		}
	}
	while(rccode!=RC_HOME && rccode!=RC_OK);
}

/******************************************************************************
 * DoExec
 ******************************************************************************/
void CFIM::DoExec(int function)
{
	printf("[%s] - %s(%d)\n",BASENAME, __FUNCTION__, function);
	std::ostringstream txt;
	int queryLogic = cconnect->getQueryLogic();
	const char* sid = cconnect->getSid();

	switch(function)
	{
		/*0*/
		case MENU:
			switch(CSubMenu::getInstance()->subMenu[MENU].sel)
			{
				//select from submenu
				case 0:
					cfb->FBClear();
					ShowMenu(PHONEBOOK);
					break;
				case 1:
					cfb->FBClear();
					ShowMenu(DIAL);
					break;
				case 2:
					DoExec(RECONNECT);
					break;
				case 3:
					DoExec(REFRESHCALL);
					break;
				case 4:
					DoExec(ADDRESSBOOK);
					break;
			}
			break;
		/*1*/
		case PHONEBOOK:
			ShowMessage(INFO_PHONEBOOK,1);
			cconnect->get_login(cpars->getFritzPW());
			cconnect->get_phonebooks(sid,CSubMenu::getInstance()->subMenu[PHONEBOOK].sel);
			if(queryLogic==1)
				cconnect->send_logout(sid);
			cfb->FBClear();
			ShowMenu(PHONEBOOK);
			break;
		/*2*/
		case CALLER_DETAILS:
			// nothing to do, SubMenu only
			break;
		/*3*/
		case DIAL:
			cconnect->get_login(cpars->getFritzPW());
			if(dialtest) {
				txt.str("");
				txt << "**" << cpars->dialport[CSubMenu::getInstance()->subMenu[DIAL].sel].port;
				cconnect->dial(sid,50,txt.str().c_str());
				ShowMessage(INFO_DIALTEST,0);
				cconnect->hangup(sid, cpars->dialport[CSubMenu::getInstance()->subMenu[DIAL].sel].port);
			}
			else {
				cfb->FBClear();
				ShowMessage(INFO_DIAL,1);
				txt.str("");
				txt << cpars->getDialprefix() << cpars->caller[callsel].call_numr;
				cconnect->dial(sid,cpars->dialport[CSubMenu::getInstance()->subMenu[DIAL].sel].port, txt.str().c_str());
				sleep(3);
				dialtest=1;
			}
			if(queryLogic==1)
				cconnect->send_logout(sid);
			break;
		/*4*/
		case RECONNECT:
			cconnect->get_login(cpars->getFritzPW());
			cconnect->reconnect(sid);
			ShowMessage(INFO_RECONNECT,0);
			if(queryLogic==1)
				cconnect->send_logout(sid);
			break;
		/*5*/
		case REFRESHCALL:
			startitem = 0;
			perpage = MAXCALLER;
			ShowMessage(LOAD,1);
			cconnect->get_login(cpars->getFritzPW());
			cconnect->send_query_info(sid);
			Mainmenu(CINFO);
			cconnect->send_refresh(sid);
			cconnect->send_query_caller(sid, startitem, MAXCALLER);
			Mainmenu(REPAINT);
			if(queryLogic==1)
				cconnect->send_logout(sid);
			break;
		/*6*/
		case ADDADR:
			cpars->add_AddrBook(cpars->caller[callsel].call_numr);
			ShowMessage(INFO_ADDADR,1);
			sleep(3);
			break;
		/*7*/
		case RSEARCH:
			if((rs_result = cconnect->rsearch(cpars->caller[callsel].call_numr))) {
				ShowMenu(CALLER_DETAILS);
				strcpy(cpars->caller[callsel].call_name,cpars->address.name);
				cpars->init_address();
				rs_result=0;
			}
			else {
				ShowMessage(INFO_RSEARCH,1);
				sleep(3);
			}
			Mainmenu(REPAINT);
			break;
		/*8*/
		case ADDRESSBOOK:
			CPhoneBook::getInstance()->run();
			Mainmenu(REPAINT);
			break;
	}
}

 /******************************************************************************
 * Cleanup
 ******************************************************************************/
void CFIM::Cleanup (void)
{
	cfb->Cleanup();
	crc->Cleanup();

	unlink(cpars->getListfile());

	printf("[%s] - bye\n",BASENAME);
}

/******************************************************************************
 * plugin_exec
 ******************************************************************************/
int main(int argc, char *argv[])
{
	return CFIM::getInstance()->run(argc, argv);
}

//void plugin_exec(PluginParam *par)
int CFIM::run(int argc, char *argv[])
{
	printf("[%s] - Version %s\n",  BASENAME, VERSION);
	if(cpars->ReadConfig(CONFIGFILE)) {
		Cleanup();
		exit(1);
	}

	//reinit after reading configfile
	cconnect->setDebug(cpars->getDebug());

	cpars->ReadColors(NEUTRINOCONF);

	// lock keyboard-conversions, this is done by the plugin itself
	//fclose(fopen(KBLCKFILE,"w"));

	Mainmenu(LOGIN);
	int query = cconnect->get_login(cpars->getFritzPW());
	if(!query) {
		printf("[%s] - ERROR get_login\n",  BASENAME);
		ShowMessage(ERR_LOGIN,0);
		Cleanup();
		exit(1);
	}

	const char* sid = cconnect->getSid();
	int queryLogic = cconnect->getQueryLogic();

	cconnect->send_query_info(sid);

	Mainmenu(CINFO);

	cconnect->send_refresh(sid);

	cconnect->send_query_caller(sid, 0, MAXCALLER);

	Mainmenu(REPAINT);

	if(query==1)
		cconnect->send_logout(sid);

	unsigned short rccode;
	do
	{
		switch((rccode = crc->getrc()))
		{
			case RC_HELP:
				ShowMessage(INFO,0);
				break;
			case RC_RED:
				cfb->FBClear();
				ShowMenu(MENU);
				break;
			case RC_LEFT:
				if(startitem == 0)
					break;
				startitem -= perpage;
				if(startitem<0)
					startitem=0;
				callsel=0;
				ShowMessage(LOAD,1);
				cconnect->get_login(cpars->getFritzPW());
				cconnect->send_query_caller(sid, startitem, perpage);
				Mainmenu(REPAINT);
				if(queryLogic==1)
					cconnect->send_logout(sid);
				break;
			case RC_RIGHT:
				startitem += perpage;
				callsel=0;
				ShowMessage(LOAD,1);
				cconnect->get_login(cpars->getFritzPW());
				cconnect->send_query_caller(sid, startitem,perpage);
				Mainmenu(REPAINT);
				if(queryLogic==1)
					cconnect->send_logout(sid);
				break;
			case RC_DOWN:
				callsel++;
				Mainmenu(REPAINT);
				break;
			case RC_UP:
				callsel--;
				Mainmenu(REPAINT);
				break;
			case RC_OK:
				cpars->search_AddrBook(cpars->caller[callsel].call_numr);
				ShowMenu(CALLER_DETAILS);
				cpars->init_address();
				Mainmenu(REPAINT);
				break;
		}
	}
	while(rccode != RC_HOME);
	Cleanup();
	return 0;
}
