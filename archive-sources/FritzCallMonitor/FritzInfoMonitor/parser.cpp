
#include <stdlib.h>
#include <string.h>

#include <fstream>
#include <iostream>
#include <sstream>

#include "globals.h"
#include "parser.h"

CParser* CParser::getInstance()
{
	static CParser* instance = NULL;
	if(!instance)
		instance = new CParser();
	return instance;
}

CParser::CParser()
{
	FritzPort	= 1012;
	FritzWebPort	= 80;
	SearchPort	= 80;
	debug		= 1;

	strcpy(FritzAdr		, "fritz.box");
	strcpy(SearchAdr	, "www.goyellow.de");
	//strcpy(ddns_domain	, "keine Information gefunden");
	strcpy(addressbook	, "/var/tuxbox/config/FritzCallMonitor.addr");

	struct_dialport dialport_t[MAXDAILPORTS] =
	{
		{"Fon 1",	1	},
		{"Fon 2",	2	},
		{"Fon 3",	3	},
		{"ISDN & DECT",	50	},
		{"ISDN 1",	51	},
		{"ISDN 2",	52	},
		{"DECT 1",	610	},
		{"DECT 2",	611	}
	};
	memcpy(dialport, &dialport_t, sizeof(dialport_t));

	ddns_domain	="keine Information gefunden";
	nspver		= "";
}

CParser::~CParser()
{
	//
}

int CParser::ReadConfig(const char *fname)
{
	FILE *fd_conf;
	char *ptr;
	char *line_buffer;
	ssize_t read;
	size_t len;
	char tmp[6];

	line_buffer=NULL;
	if((fd_conf = fopen(fname, "r")))
	{
		while ((read = getline(&line_buffer, &len, fd_conf)) != -1)
		{
			if (line_buffer[0] == '#')
			continue;

			if ((ptr = strstr(line_buffer, "FRITZBOXIP=")))
				sscanf(ptr + 11, "%63s", (char *) &FritzAdr);
			else if ((ptr = strstr(line_buffer, "PORT=")))
				sscanf(ptr + 5, "%i", &FritzPort);
			else if ((ptr = strstr(line_buffer, "DEBUG=")))
				sscanf(ptr + 6, "%i", &debug);
			else if ((ptr = strstr(line_buffer, "ADDRESSBOOK=")))
				sscanf(ptr + 12, "%127s", (char *) &addressbook);
			else if ((ptr = strstr(line_buffer, "PASSWD=")))
				sscanf(ptr + 7, "%63s", (char *) &FritzPW);
			else if ((ptr = strstr(line_buffer, "CITYPREFIX=")))
				sscanf(ptr + 11, "%9s", (char *) &cityprefix);
			else if ((ptr = strstr(line_buffer, "DIALPREFIX=")))
				sscanf(ptr + 11, "%19s", (char *) &dialprefix);
			else if ((ptr = strstr(line_buffer, "PORT_1="))) {
				sscanf(ptr + 7, "%[^,],%s", (char *) &dialport[0].port_name, (char *) &tmp);
				dialport[0].port = atoi(tmp);
			}
			else if ((ptr = strstr(line_buffer, "PORT_2="))) {
				sscanf(ptr + 7, "%[^,],%29s", (char *) &dialport[1].port_name, (char *) &tmp);
				dialport[1].port = atoi(tmp);
			}
			else if ((ptr = strstr(line_buffer, "PORT_3="))) {
				sscanf(ptr + 7, "%[^,],%29s", (char *) &dialport[2].port_name, (char *) &tmp);
				dialport[2].port = atoi(tmp);
			}
			else if ((ptr = strstr(line_buffer, "PORT_4="))) {
				sscanf(ptr + 7, "%[^,],%29s", (char *) &dialport[3].port_name, (char *) &tmp);
				dialport[3].port = atoi(tmp);
			}
			else if ((ptr = strstr(line_buffer, "PORT_5="))) {
				sscanf(ptr + 7, "%[^,],%s", (char *) &dialport[4].port_name, (char *) &tmp);
				dialport[4].port = atoi(tmp);
			}
			else if ((ptr = strstr(line_buffer, "PORT_6="))) {
				sscanf(ptr + 7, "%[^,],%29s", (char *) &dialport[5].port_name, (char *) &tmp);
				dialport[5].port = atoi(tmp);
			}
			else if ((ptr = strstr(line_buffer, "PORT_7="))) {
				sscanf(ptr + 7, "%[^,],%29s", (char *) &dialport[6].port_name, (char *) &tmp);
				dialport[6].port = atoi(tmp);
			}
			else if ((ptr = strstr(line_buffer, "PORT_8="))) {
				sscanf(ptr + 7, "%[^,],%29s", (char *) &dialport[7].port_name, (char *) &tmp);
				dialport[7].port = atoi(tmp);
			}
			else if ((ptr = strstr(line_buffer, "CALLERLIST_STR="))) {
				sscanf(ptr + 15, "%127s", (char *) &liststr);
			}
			else if ((ptr = strstr(line_buffer, "CALLERLIST_FILE="))) {
				sscanf(ptr + 16, "%127s", (char *) &listfile);
			}
		}
		fclose(fd_conf);
		if(line_buffer)
			free(line_buffer);
	}
	else
	{
		printf("[%s] - ERROR open %s\n", BASENAME,fname);
		return 1;
	}

	return 0;
}

void CParser::read_neutrino_osd_conf(int *ex,int *sx,int *ey, int *sy, const char *filename)
{
	const char spres[][4]={"","crt","lcd"};
	char sstr[4][32];
	int pres=-1, resolution=-1, loop, *sptr[4]={ex, sx, ey, sy};
	char *buffer;
	size_t len;
	ssize_t read;
	FILE* fd;

	fd = fopen(filename, "r");
	if(fd){
		buffer=NULL;
		len = 0;
		while ((read = getline(&buffer, &len, fd)) != -1){
			sscanf(buffer, "screen_preset=%d", &pres);
			sscanf(buffer, "osd_resolution=%d", &resolution);
		}
		if(buffer)
			free(buffer);
		rewind(fd);
		++pres;
		sprintf(sstr[0], "screen_EndX_%s_%d=%%d", spres[pres], resolution);
		sprintf(sstr[1], "screen_StartX_%s_%d=%%d", spres[pres], resolution);
		sprintf(sstr[2], "screen_EndY_%s_%d=%%d", spres[pres], resolution);
		sprintf(sstr[3], "screen_StartY_%s_%d=%%d", spres[pres], resolution);

		buffer=NULL;
		len = 0;
		while ((read = getline(&buffer, &len, fd)) != -1){
			for(loop=0; loop<4; loop++) {
				sscanf(buffer, sstr[loop], sptr[loop]);
			}
		}
		fclose(fd);
		if(buffer)
			free(buffer);
	}
}

unsigned short CParser::Percentconverter (unsigned short percent)
{
	return(2.55*percent);
}

int CParser::ReadColors (const char *filename)
{
	FILE *fh;
	char *ptr;
	char *line_buffer;
	ssize_t read;
	size_t len;


	if (!(fh=fopen(filename, "r")))
	{
		perror("neutrino.conf");
		return(1);
	}

	line_buffer=NULL;
	while ((read = getline(&line_buffer, &len, fh)) != -1)
	{
		if ((ptr = strstr(line_buffer, "menu_Head_alpha=")))
			sscanf(ptr+16, "%hu", &cmh[mALPHA]);
		else if ((ptr = strstr(line_buffer, "menu_Head_blue=")))
			sscanf(ptr+15, "%hu", &cmh[mBLUE]);
		else if ((ptr = strstr(line_buffer, "menu_Head_green=")))
			sscanf(ptr+16, "%hu", &cmh[mGREEN]);
		else if ((ptr = strstr(line_buffer, "menu_Head_red=")))
			sscanf(ptr+14, "%hu", &cmh[mRED]);
		else if ((ptr = strstr(line_buffer, "menu_Head_Text_alpha=")))
			sscanf(ptr+21, "%hu", &cmht[mALPHA]);
		else if ((ptr = strstr(line_buffer, "menu_Head_Text_blue=")))
			sscanf(ptr+20, "%hu", &cmht[mBLUE]);
		else if ((ptr = strstr(line_buffer, "menu_Head_Text_green=")))
			sscanf(ptr+21, "%hu", &cmht[mGREEN]);
		else if ((ptr = strstr(line_buffer, "menu_Head_Text_red=")))
			sscanf(ptr+19, "%hu", &cmht[mRED]);
		else if ((ptr = strstr(line_buffer, "menu_Content_alpha=")))
			sscanf(ptr+19, "%hu", &cmc[mALPHA]);
		else if ((ptr = strstr(line_buffer, "menu_Content_blue=")))
			sscanf(ptr+18, "%hu", &cmc[mBLUE]);
		else if ((ptr = strstr(line_buffer, "menu_Content_green=")))
			sscanf(ptr+19, "%hu", &cmc[mGREEN]);
		else if ((ptr = strstr(line_buffer, "menu_Content_red=")))
			sscanf(ptr+17, "%hu", &cmc[mRED]);
		else if ((ptr = strstr(line_buffer, "menu_Content_Text_alpha=")))
			sscanf(ptr+24, "%hu", &cmct[mALPHA]);
		else if ((ptr = strstr(line_buffer, "menu_Content_Text_blue=")))
			sscanf(ptr+23, "%hu", &cmct[mBLUE]);
		else if ((ptr = strstr(line_buffer, "menu_Content_Text_green=")))
			sscanf(ptr+24, "%hu", &cmct[mGREEN]);
		else if ((ptr = strstr(line_buffer, "menu_Content_Text_red=")))
			sscanf(ptr+22, "%hu", &cmct[mRED]);
	}

	fclose(fh);
	if(line_buffer)
		free(line_buffer);

	unsigned char bgra_t[][5] = {
		"\x00\x00\x00\x00","\x00\x00\x00\xFF","\x00\x00\x80\xFF","\x00\x80\x00\xFF",
		"\x00\x48\xA0\xFF","\x80\x00\x00\xFF","\x80\x00\x80\xFF","\x80\x80\x00\xFF",
		"\xA0\xA0\xA0\xFF","\x50\x50\x50\xFF","\x00\x00\xFF\xFF","\x00\xFF\x00\xFF",
		"\x00\xFF\xFF\xFF","\xFF\x00\x00\xFF","\xFF\x00\xFF\xFF","\xFF\xFF\x00\xFF",
		"\xFF\xFF\xFF\xFF","\xFF\x80\x00\xF0","\x80\x00\x00\xF0","\xFF\x80\x00\xFF",
		"\x40\x20\x00\xFF","\x00\xC0\xFF\xFF","\x0C\x0C\x0C\xF7","\x30\x30\x30\xF7"
	};

	bgra_t[CMH][mRED] = Percentconverter(cmh[mRED]);
	bgra_t[CMH][mGREEN] = Percentconverter(cmh[mGREEN]);
	bgra_t[CMH][mBLUE] = Percentconverter(cmh[mBLUE]);
	bgra_t[CMH][mALPHA] = (255-Percentconverter(cmh[mALPHA]));

	bgra_t[CMHT][mRED] = Percentconverter(cmht[mRED]);
	bgra_t[CMHT][mGREEN] = Percentconverter(cmht[mGREEN]);
	bgra_t[CMHT][mBLUE] = Percentconverter(cmht[mBLUE]);
	bgra_t[CMHT][mALPHA] = (255-Percentconverter(cmht[mALPHA]));

	bgra_t[CMC][mRED] = Percentconverter(cmc[mRED]);
	bgra_t[CMC][mGREEN] = Percentconverter(cmc[mGREEN]);
	bgra_t[CMC][mBLUE] = Percentconverter(cmc[mBLUE]);
	bgra_t[CMC][mALPHA] = 255-Percentconverter(cmc[mALPHA]);

	bgra_t[CMCT][mRED] = Percentconverter(cmct[mRED]);
	bgra_t[CMCT][mGREEN] = Percentconverter(cmct[mGREEN]);
	bgra_t[CMCT][mBLUE] = Percentconverter(cmct[mBLUE]);
	bgra_t[CMCT][mALPHA] = (255-Percentconverter(cmct[mALPHA]));

	const int sz = sizeof(bgra)/sizeof(**bgra);
	copy(*bgra_t, (*bgra_t) + sz, *bgra);

	return(0);
}
#if 0
/******************************************************************************
 * local addressbook functions
 ******************************************************************************/
#endif
int CParser::search_AddrBook(const char *caller)
{
	FILE *fd;
	char *line_buffer;
	string search_str;
	ssize_t ptr;
	size_t len;
	int i=0;

	if(strlen(caller)!=0){
		search_str = (string) caller + "|";
	} else {
		return(0);
	}

	if(!(fd = fopen(addressbook, "r"))) {
		perror(addressbook);
		return(0);
	}
	else
	{
		line_buffer=NULL;
		while ((ptr = getline(&line_buffer, &len, fd)) != -1)
		{
			i++;
			if (strstr(line_buffer, search_str.c_str()))
			{
				sscanf(line_buffer,"%*[^|]|%255[^|]|%127[^|]|%5[^|]|%127[^|]",
					(char *) &address.name,
					(char *) &address.street,
					(char *) &address.code,
					(char *) &address.locality);
				if (debug)
					printf("[%s] - \"%s\" found [%d]\n", BASENAME, caller, i);
				fclose(fd);
				if(line_buffer)
					free(line_buffer);
				return(1);
			}
		}
		if (debug)
			printf("[%s] - \"%s\" not found in %s\n", BASENAME, caller, addressbook);

		fclose(fd);
		if(line_buffer)
			free(line_buffer);
	}
	return(0);
}

int CParser::add_AddrBook(const char *caller)
{
	ofstream os(addressbook, ios::out | ios::app);

	if (os.is_open())
	{
		os	<< caller << '|'
			<< address.name << '|'
			<< address.street << '|'
			<< address.code << '|'
			<< address.locality << '|' << endl;
		os.close();
	}
	else
	{
		return(0);
	}

	return(1);
}

void CParser::init_caller()
{
	memset(&caller, 0, sizeof(caller));
}

void CParser::init_address()
{
	memset(&address, 0, sizeof(address));
}

string CParser::parseString(const char* var, string& string_to_serarch)
{
	string res="";
	size_t pos1, pos2;

	if((pos1 = string_to_serarch.find(var)) != string::npos)
	{
		// "ver":"84.05.50"
		pos1 += strlen(var)+3;
		string tmp = string_to_serarch.substr(pos1);

		if((pos2 = tmp.find('"')) != string::npos)
		{
			res = tmp.substr(0,pos2);
			//cout << " result: " << var << " = " << res << endl;
		}
	}
	else
		cout << '[' << BASENAME << "] - " << __FUNCTION__ << "(): no result for " << '"' << var << '"' << endl;

	return(res);
}
