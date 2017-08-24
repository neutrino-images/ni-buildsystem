
#include <fstream>
#include <iostream>
#include <sstream>

#include <algorithm>
#include <iterator>

#include "parser.h"
#include "connect.h"
#include "framebuffer.h"
#include "rc.h"
#include "submenu.h"
#include "globals.h"

#include "phonebook.h"



const char *liste[] = {"AZ","AB","CD","EF","GH","IJK","LM","NO","PQR","STU","VWXYZ"};

// create outstream operator
ostream& operator<< (ostream& out, const CPhoneBook::S_ADDRESS& d)
{
	return	out	<< d.number << ',' << d.name << ',' << d.street << ','
			<< d.code << ',' << d.locality << ',';
}

void CPhoneBook::toUpper(string& s)
{
	for(string::iterator p = s.begin(); p != s.end();++p)
		*p = toupper(*p) ;
}

bool CPhoneBook::sortByKey(const S_ADDRESS& a, const S_ADDRESS& b)
{
	string na = a.name;
	string nb = b.name;

	toUpper(na) ;
	toUpper(nb) ; 

	return na < nb;
}


CPhoneBook* CPhoneBook::getInstance()
{
	static CPhoneBook* instance = NULL;
	if(!instance)
		instance = new CPhoneBook();
	return instance;
}

CPhoneBook::CPhoneBook()
{
	cconnect = CConnect::getInstance();
	cpars	 = CParser::getInstance();
	cfb	 = Cfb::getInstance();
	crc	 = Crc::getInstance();

	selList	= 0;
	selData	= -1;
	lastData= 0;
	perpage = 0;
}

CPhoneBook::~CPhoneBook()
{

}

void CPhoneBook::run()
{
	// Get data
	getData(CParser::getInstance()->getAddressbook(), liste[selList]);

	menu();

	unsigned short rccode;

	do
	{
		switch((rccode = crc->getrc()))
		{
			case RC_RIGHT:
				selList++;
				if(selList > ((int)(sizeof(liste)/sizeof(liste[0])))-1) {
					selList = 0;
				}
				selData=-1;
				getData(CParser::getInstance()->getAddressbook(), liste[selList]);
				menu();
				break;
			case RC_LEFT:
				selList--;
				if(selList < 0) {
					  selList = ((int)(sizeof(liste)/sizeof(liste[0])))-1;
				}
				selData=-1;
				getData(CParser::getInstance()->getAddressbook(), liste[selList]);
				menu();
				break;
			case RC_DOWN:
				selData++;
				if(selData >= (int)content.size()) {
					selData = 0;
				}
				menu();
				break;
			case RC_UP:
				selData--;
				if(selData < -1) {
					selData = (int)content.size()-1;
				}
				menu();
				break;
			case RC_OK:
				if(selData != -1) {
					dialMenu();
					rccode=RC_HOME;
				}
				break;
			case RC_PAGEDOWN:
				selData += (selData == -1 ? perpage+1 : perpage);
				selData = (selData / perpage) * perpage; // select first item on the site
				if(selData >= (int)content.size()) {
					selData = -1;
				}
				menu();
				break;
			case RC_PAGEUP:
				selData -= perpage;
				selData = (selData / perpage) * perpage; // select first item on the site
				if(selData < -1) {
					selData = (int)content.size()-1;
				}
				menu();
				break;
		}
	}
	while(rccode != RC_HOME);
}

void CPhoneBook::menu()
{
	int ex, sx, ey, sy;
	cfb->getDimensions(&ex, &sx, &ey, &sy);
	int vyres = cfb->getYScreeninfo();

	int bspace	= 40;
	int lrspace	= 30;
	int xwidth	= ex-sx-bspace;
	int yheight	= ey-sy-bspace;
	int ld		= vyres < 600 ? 25 : 28; //line distance
	int slim	= ex-sx < 1100 ? 1:0;
	int vsx		= bspace + lrspace;
	int vsy		= 80;

	ostringstream txt;

	int sp1 = vsx;
	int le1 = slim?180:250;	//name
	int sp2 = sp1+le1+18;
	int le2 = 180;		//number
	int sp3 = sp2+le2+18;
	int le3 = slim?130:250;	//street
	int sp4 = sp3+le3+18;
	int le4 = 70;		//code
	int sp5 = sp4+le4+18;
	int le5 = 180;		//locality

	int hvsp = 0;
	int hle  = 30;
	int hitm = (int)(sizeof(liste)/sizeof(liste[0]));
	int hsp  = (xwidth-(2*lrspace)-(2*hle)) / (hitm-1);

	// Grafic
	cfb->RenderBox(bspace, 0, xwidth, yheight, FILL, CMC);
	cfb->RenderBox(bspace, 0, xwidth, 40, FILL, CMH);
	//cfb->PaintIcon(icon_ng,((xwidth+bspace)/2)-(120/2)-35,8);
	cfb->RenderString("Adressbuch", ((xwidth+bspace)/2)-(130/2) ,30, 130, CENTER, BIG, CMHT);

	// Body headline
	for (int i=0; i < hitm; i++)
	{
		txt.str("");

		if(selList == i)
			cfb->RenderBox(vsx-3+hvsp, vsy-20, vsx-3+hvsp+hle, vsy+3, selData == -1?FILL:GRID, CMHT);

		txt << liste[i][0] << '-' << liste[i][strlen(liste[i])-1];
		cfb->RenderString(txt.str().c_str(), vsx+hvsp ,vsy, hle, LEFT, SMALL, (selList == i && selData == -1)?CMC:GREY);

		hvsp += hsp;
	}

	// Body data
	vsy += ld+10;

	int start = 0;
	if(perpage) {
		start = (selData / perpage) * perpage;
	}

	for (int i = start; i < (int)content.size() ; i++)
	{
		if(i == selData)
			cfb->RenderBox(bspace, vsy-ld+3, xwidth, vsy+3, FILL, CMHT);

		cfb->RenderString(cconnect->UTF8toISO((char *)content[i].name.c_str()),
			sp1, vsy, le1, LEFT, NORMAL, selData==i?CMC:CMCT);

		cfb->RenderString(content[i].number.c_str(),
			sp2, vsy, le2, LEFT, NORMAL, selData==i?CMC:CMCT);

		cfb->RenderString(cconnect->UTF8toISO((char *)content[i].street.c_str()),
			sp3, vsy, le3, LEFT, NORMAL, selData==i?CMC:CMCT);

		if(xwidth > (sp4+le4)) 
			cfb->RenderString(content[i].code.c_str(),
				sp4, vsy, le4, LEFT, NORMAL, selData==i?CMC:CMCT);

		if(xwidth > (sp5+le5))
			cfb->RenderString(cconnect->UTF8toISO((char *)content[i].locality.c_str()),
				sp5, vsy, le5, LEFT, NORMAL, selData==i?CMC:CMCT);
		vsy += ld;

		if(vsy >= yheight-ld)
		{
			//cfb->RenderString("----", sp1, vsy, le1, LEFT, NORMAL, CMHT);
			if(perpage == 0) {
				perpage = i+1;
				cout << "perpage = " << perpage << endl;
			}
			break;
		}
		lastData = i;
	}

	// Footer
	txt.str("");
	txt << "Seite " << getSites(lastData+1) << " von " << getSites(content.size());
	cfb->RenderBox(bspace, yheight, xwidth, yheight+30, FILL, CMH);
	cfb->RenderString(txt.str().c_str(), ((xwidth+bspace)/2)-(130/2) ,yheight+20, 130, CENTER, SMALL, GREY);
	

	cfb->FBPaint();
}

void CPhoneBook::dialMenu()
{
	int dialtest = 0;
	ostringstream txt;

	CSubMenu::getInstance()->DialMenu(dialtest);

	unsigned short rccode;
	do
	{
		switch((rccode = crc->getrc()))
		{
			case RC_UP:
				CSubMenu::getInstance()->subMenu[DIAL].sel--;
				CSubMenu::getInstance()->DialMenu(dialtest);
				break;
			case RC_DOWN:
				CSubMenu::getInstance()->subMenu[DIAL].sel++;
				CSubMenu::getInstance()->DialMenu(dialtest);
				break;
			case RC_OK:
				cconnect->get_login(cpars->getFritzPW());

				cfb->FBClear();
				txt.str("");
				txt << cpars->getDialprefix() << content[selData].number;
				CSubMenu::getInstance()->ShowMessage(INFO_DIAL,1);
				cconnect->dial(cconnect->getSid(),cpars->dialport[CSubMenu::getInstance()->subMenu[DIAL].sel].port, txt.str().c_str());

				cout << '[' << BASENAME << "] - " << __FILE__ << " dialport: " << cpars->dialport[CSubMenu::getInstance()->subMenu[DIAL].sel].port
				     << " number  : " << content[selData].number << endl;

				if(cconnect->getQueryLogic()==1)
					cconnect->send_logout(cconnect->getSid());
				break;
		}
	}
	while(rccode!=RC_HOME);

	run();
}

int CPhoneBook::getData(const char *fname, const char *list)
{
	memset(&content, 0, sizeof(content));

	ifstream fh(fname);

	if ( fh.is_open() )
	{
		string line;
 
		while (getline(fh,line))
		{
			S_ADDRESS entry;

			istringstream in(line);

			if(getline(in, entry.number,		'|') && //in >> entry.number && in.get() == '|' &&
				getline(in, entry.name,		'|') &&
				getline(in, entry.street,	'|') &&
				getline(in, entry.code,		'|') &&
				getline(in, entry.locality,	'|') )
			{
				if(strcmp(list,"AZ" /*all*/) == 0)
				{
					content.push_back(entry);
				}
				else
				{
					for(int i=0; i<(int)strlen(list); i++)
					{
						//printf("search for '%c' > %s (%d)\n",list[i],entry.name.c_str(),(int)strlen(list));
						if(toupper(entry.name[0]) == list[i]) {
							content.push_back(entry);
							break;
						}
					}
				}
			} 
			else {
				cerr << '[' << BASENAME << "] - " << __FILE__ << " could not parse input line: " << line << endl;
			}
		}

		cout << '[' << BASENAME << "] - " << __FILE__ << ' ' << __FUNCTION__ << " elements: " << content.size() << endl;

		sort(content.begin(),content.end(), sortByKey);

		//copy(content.begin(), content.end(), ostream_iterator<S_ADDRESS>(cout, "\n"));

		fh.close();

	}
	else {
		cerr << '[' << BASENAME << "] - " << __FILE__ << "could not open file." << endl;
	}

	return 0;
}

int CPhoneBook::getSites(int items)
{
	int sites = 0;

	if(perpage) {
		sites = items / perpage;

		if(items % perpage)
			sites++;
	}

	if(!sites)
		sites = 1;

	return(sites);
}
