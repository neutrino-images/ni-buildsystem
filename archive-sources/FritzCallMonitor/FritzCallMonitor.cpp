
#include <stdlib.h>
#include <string.h>
#include <signal.h>

#include <sys/socket.h>

#include <fstream>
#include <sstream>
#include <iostream>
#include <unistd.h>

#include "FritzCallMonitor.h"
#include "connect.h"


CFCM* CFCM::getInstance()
{
	static CFCM* instance = NULL;
	if(!instance)
		instance = new CFCM();
	return instance;
}

CFCM::CFCM()
{
	cconnect = CConnect::getInstance();

	//default parameters
	FritzPort	= 1012;
	msgtimeout	=-1;
	BackwardSearch	= 1;
	debug		= 1;
	easymode	= 0;
	phonebooks	= 1;
	SearchPort	= 80;
	searchmode	= 0;
	searchint	= 300;
	
	strcpy(FritzAdr,	"fritz.box");
	strcpy(FritzPW,		"pwd");
	strcpy(msgtype,		"nmsg");
	strcpy(addressbook,	"/var/tuxbox/config/FritzCallMonitor.addr");
	strcpy(adflag,		"/var/etc/.call");
	strcpy(SearchAdr,	"www.goyellow.de");
	strcpy(searchquery,	"&var=tam:settings/TAM0/NumNewMessages");

	ReadConfig((char *)CONFIGFILE);

	//FIXME enable this function for all config values
	read_conf(CONFIGFILE);

	//reinit after reading configfile
	cconnect->setDebug(debug);
	cconnect->setFritzAdr(FritzAdr);
	cconnect->setFritzPort(80);
}

CFCM::~CFCM()
{
	//
}

void CFCM::FritzCall()
{
	char Buff1[BUFFERSIZE];
	int sockfd = 0;
	int loop = 0;
	int len = 0;

	int i;
	char* item[MAXITEM];

	while(!loop)
	{
		sockfd = cconnect->connect2Host(FritzAdr, FritzPort);

		if (sockfd > 0) {
			printf("[%s] - Socked (%i) connected to %s\n", BASENAME, sockfd, easymode?"EasyBox":"FritzBox");
			loop=1;
		}
		else
			sleep(5);
	}

	if(!easymode)
	{
	    do {
		bzero(Buff1, sizeof(Buff1));
		if((len = recv(sockfd, Buff1, sizeof(Buff1), 0)) <= 0) {
			printf("[%s] - recv error\n", BASENAME);
			break;
		}
#if 0
		/*
		 *	Ankommender Anruf
		 *	28.08.10 10:21:37;RING;2;040xxx;123x;ISDN;
		 *	Verbunden
		 *	28.08.10 10:25:40;CONNECT;0;4;040xxx;
		 *
		 *	Ankommender Anruf / Nummer unterdrückt
		 *	28.08.10 10:22:07;RING;0;;123x;ISDN;
		 *	Verbunden
		 *	28.08.10 10:24:37;CONNECT;0;4;;
		 *
		 *	Abgehender Anruf
		 *	28.08.10 10:28:48;CALL;1;4;123x;040xxx;ISDN;
		 *
		 *	Getrennt
		 *	28.08.10 10:28:51;DISCONNECT;1;0;
		 */
#endif
		printf("[%s] - %s",BASENAME, Buff1);

		i=0;
		//item[0]="not used";
		char* token = strtok(Buff1, ";");
		while (token != NULL)
		{
			item[i+1] = token;
			token = strtok(NULL, ";");
			if (debug) {
				if ( i != 0 )
					printf("%i - %s\n", i, item[i]);
			}
			if (i >= MAXITEM) break;
			i++;
		 }

		if (strcmp(item[2], "RING") == 0) //incomming call
		{
			if ( i == 5+1) //hidden number
			{
				strcpy(CallFrom, "Unbekannt");
				strcpy(CallTo, item[4]);
			}
			else
			{
				strcpy(CallFrom, item[4]);
				strcpy(CallTo, item[5]);
			}
			printf("[%s] - Eingehender Anruf von %s an %s\n", BASENAME, CallFrom, CallTo);

			for (i=0; i < (int)(sizeof(msnnum)/sizeof(msnnum[0])); i++)
			{
				if ((i==0 && strcmp(msnnum[i].msn, "") == 0) || strcmp(msnnum[i].msn, CallTo) == 0)
				{
					if(strlen(msnnum[i].msnName) != 0)
						strcpy(CallToName,msnnum[i].msnName);

					if (BackwardSearch && strcmp(CallFrom, "Unbekannt") != 0)
					{
						search(CallFrom);
					}
					else
						sendMSG(0);
				}
			}
		}
	    } while (loop);
	}
	else //EasyBox mode
	{
	    do {
		bzero(Buff1, sizeof(Buff1));
		if((len = recv(sockfd, Buff1, sizeof(Buff1), 0)) <= 0) {
			printf("[%s] - recv error\n",BASENAME );
			break;
		}
#if 0
		//strcpy(Buff1,"CID: *DATE*06072011*TIME*1929*LINE**NMBR*092XXXXXXX*MESG*NONE*NAME*NO NAME*\n");

		/*
		 * 	EasyBox Caller ID
		 *
		 * 	Ankommender Anruf
		 * 	CID: *DATE*06072011*TIME*1929*LINE**NMBR*092XXXXXXX*MESG*NONE*NAME*NO NAME*
		 *
		 * 	Ankommender Anruf / Nummer unterdrückt
		 * 	CID: *DATE*01072011*TIME*2007*LINE**NMBR*Privat*MESG*NONE*NAME*NO NAME*
		 */
#endif
		printf("[%s] - %s",BASENAME, Buff1);

		char* ptr;
		strcpy(CallFrom,"Unbekannt");
		strcpy(CallTo,"EasyBox");

		if ((ptr = strstr(Buff1, "CID:"))) //incomming call
		{
			if ((ptr = strstr(Buff1, "NMBR*")))
				sscanf(ptr + 5, "%63[^*]", (char *) &CallFrom);
			else if ((ptr = strstr(Buff1, "LINE*")))
				sscanf(ptr + 5, "%63[^*]", (char *) &CallTo);

			printf("[%s] - Eingehender Anruf von %s an %s\n", BASENAME, CallFrom, CallTo);

			for (i=0; i < (int)(sizeof(msnnum)/sizeof(msnnum[0])); i++)
			{
				if ((i==0 && strcmp(msnnum[i].msn, "") == 0) || strcmp(msnnum[i].msn, CallTo) == 0)
				{
					if(strlen(msnnum[i].msnName) != 0)
						strcpy(CallToName,msnnum[i].msnName);

					if (BackwardSearch && strcmp(CallFrom, "Privat") != 0 && strcmp(CallFrom, "Unbekannt") != 0)
					{
						search(CallFrom);
					}
					else
						sendMSG(0);
				}
			}
		}
	    } while (loop);
	}
	close(sockfd);
	//loop if socked lost
	FritzCall();
}

int CFCM::search(const char *searchNO)
{
	char *found;
	char *line;
	ssize_t read;
	size_t len;
	ostringstream url;
	string output ="/tmp/fim.out";
	FILE* fd;

	url	<< SearchAdr << "/suche/" << searchNO << "/-";

	memset(&address, 0, sizeof(address));

	if(search_AddrBook(CallFrom)) {
		sendMSG(1);
		return 0;
	}

	string s = cconnect->post2fritz(url.str().c_str(),80 ,"", output);

	line=NULL;
	if((fd = fopen(output.c_str(), "r")))
	{
		while ((read = getline(&line, &len, fd)) != -1)
		{
			if ((found = strstr(line, "target=\"_self\" title=\"Zur Detailseite von&#160;")))
			{
				sscanf(found + 47, "%255[^\"]", (char *) &address.name);
			}
			else if ((found = strstr(line, "\"postalCode\" content=\"")))
			{
				sscanf(found + 22, "%5[^\"]", (char *) &address.code);
			}
			else if((found = strstr(line, "\"addressLocality\" content=\"")))
			{
				sscanf(found + 27, "%127[^\"]", (char *) &address.locality);
			}
			else if((found = strstr(line, "\"streetAddress\" content=\"")))
			{
				sscanf(found + 25, "%127[^\"]", (char *) &address.street);
			}
		}
		fclose(fd);
	}
	if(line)
		free(line);

	if(strlen(address.name)!=0) {
		if (debug){printf("[%s] - (%s) = %s, %s, %s %s\n",BASENAME, searchNO, address.name, address.street, address.code, address.locality);}

		sendMSG(strlen(address.name));

		// Save address to addressbook
		add_AddrBook(CallFrom);
	}
	else {
		printf("[%s] - no results for %s\n",BASENAME, searchNO);
	}

	sendMSG(0);

	return 0;
}

void CFCM::sendMSG(int caller_address)
{
	ostringstream msg;
	ostringstream txt;
	int i,j;
	const char *newline="%0A";
	const char *space="%20%20";

	if (caller_address)
	{
		msg	<< "Anrufer : " << CallFrom << (strlen(address.name)!=0 ? newline : "")
			<< space << address.name << (strlen(address.street)!=0 ? newline : "")
			<< space << address.street << (strlen(address.code)!=0 ? newline : "")
			<< space << address.code << address.locality << newline
			<< "Leitung : " << (strlen(CallToName)!=0 ? CallToName : CallTo);
	}
	else
	{
		msg	<< "Anrufer : " << CallFrom << newline
			<< "Leitung : " << (strlen(CallToName)!=0 ? CallToName : CallTo);
	}

	if(strcmp(execute,"") != 0)
	{
		pid_t pid;
		signal(SIGCHLD, SIG_IGN);
		switch (pid = vfork())
		{
			case -1:
				perror("vfork");
				break;
			case 0:
				printf("[%s] - Execute -> %s\n",BASENAME,execute);
				if(execl("/bin/sh", "sh", execute, msg.str().c_str(), NULL))
				{
					perror("execl");
				}
				_exit (0); // terminate c h i l d proces s only
			default:
				break;
		}
	}

	for (i=0; i < (int)(sizeof(msnnum)/sizeof(msnnum[0])); i++)
	{
		if ( (i==0 && strcmp(msnnum[0].msn, "") == 0) || strcmp(msnnum[i].msn, CallTo) == 0)
		{
			for (j=0; j < (int)(sizeof(boxnum)/sizeof(boxnum[0])); j++)
			{
				if ((strcmp(boxnum[j].BoxIP, "") != 0)) {
					txt.str("");
					txt << msg.str() << ' ';

					char * ptr;
					char ip[20];
					int port = 80;

					if ((ptr = strstr(boxnum[j].BoxIP, ":"))) {
						sscanf(boxnum[j].BoxIP, "%19[^:]", ip);
						sscanf(ptr + 1, "%i", &port);
					}
					else {
						strcpy(ip,boxnum[j].BoxIP);
					}
					cconnect->get2box(ip, port, txt.str().c_str(), boxnum[j].logon, msgtype, msgtimeout);
				}
			}
		}
	}
}

int CFCM::search_AddrBook(const char *caller)
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
					printf("[%s] - \"%s\" found in %s[%d]\n", BASENAME, caller, addressbook, i);
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

int CFCM::add_AddrBook(const char *caller)
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

vector<string> CFCM::split(stringstream& str,const char& delim)
{
	string line, cell;
	vector<string> result;

	while(getline(str,cell,delim))
	{
		result.push_back(cell);
		//printf("cell=%s\n",cell.c_str());
	}
	return result;
}

string CFCM::create_map(string& k, const string& t, string& v, map<string, vector<string> >& m)
{
	// cleanup keys with no values
	if(v.empty())
	{
		k.clear();
		return("");
	}

	string key;
	string::size_type begin = k.find(t);

	if(begin != string::npos)
	{
		key = k.substr(t.size());
		k.erase(t.size());

		// modify value
		cconnect->StringReplace(v,":;,",";");
		cconnect->StringReplace(v," ;\t","");

		// create tmp vector
		stringstream is(v);
		vector<string> tmp = split(is,';');

		// copy tmp vector into map
		m[key].swap(tmp);

		//debug
		if(debug) cout << k << '[' << key << ']' << "=" << v << endl;
	}

	return(key);
}

string CFCM::create_map(string& k, const string& t, const string& v, map<string, string>& m)
{
	if(v.empty())
	{
		k.clear();
		return("");
	}

	string key;
	string::size_type begin = k.find(t);
	if(begin != string::npos)
	{
		key = k.substr(t.size());
		k.erase(t.size());

		m[key] = v;

		//debug
		cout << k << '[' << key << ']' << "=" << v << endl;
	}

	return(key);
}

void* CFCM::proxy_loop(void* arg)
{
	pthread_setcancelstate(PTHREAD_CANCEL_ENABLE,0);
	pthread_setcanceltype (PTHREAD_CANCEL_ASYNCHRONOUS,0);

	static_cast<CFCM*>(arg)->query_loop();
	return 0;
}

int CFCM::query_loop()
{
	sleep(10);

	while(1)
	{
		if(searchmode)
		{
			printf("[%s] - %s send query\n", BASENAME, cconnect->timestamp().c_str());
			if(cconnect->get_login(FritzPW))
			{
				cconnect->send_TAMquery(adflag,cconnect->getSid(),searchquery);
			}
		}

		if(!c["DECTBOXIP"].empty())
		{
			cconnect->setFritzAdr(c["DECTBOXIP"].c_str());
			printf("[%s] - %s getdevicelistinfos %s\n", BASENAME, cconnect->timestamp().c_str(),c["DECTBOXIP"].c_str());

			if(cconnect->get_login(c["DECTPASSWD"].c_str()))
			{
				cconnect->smartHome(cconnect->getSid(),"getdevicelistinfos");
				cconnect->checkdevice(wp,dp);
				cconnect->cleardevice();
			}
			cconnect->setFritzAdr(FritzAdr);
		}

		sleep(searchint);
	}
	return 0;
}

void CFCM::start_loop()
{
	if (searchmode || !c["DECTBOXIP"].empty()) {
		if(!thrTimer) {
			printf("[%s] - %s Start Thread for checking FRITZ!Box (reload %i seconds)\n",BASENAME, cconnect->timestamp().c_str(), searchint);
			pthread_create (&thrTimer, NULL, proxy_loop, this) ;
			pthread_detach(thrTimer);
		}
	}
}

void CFCM::stop_loop()
{
	if(thrTimer) {
		printf("[%s] - %s Stop Thread for checking FRITZ!Box\n", BASENAME, cconnect->timestamp().c_str());
		pthread_cancel(thrTimer);
		thrTimer = 0;
	}
}

int CFCM::ReadConfig(const char *fname)
{
	FILE *fd_conf;
	char *ptr;
	char *line_buffer;
	ssize_t read;
	size_t len;

	line_buffer=NULL;
	if((fd_conf = fopen(fname, "r")))
	{
		while ((read = getline(&line_buffer, &len, fd_conf)) != -1)
		{
			char buffer[128]="";

			if (line_buffer[0] == '#')
				continue;
			else if ((ptr = strstr(line_buffer, "DECTBOXIP="))) {
				sscanf(ptr + 10, "%127s",buffer);
//				FritzDectAdr=buffer;
			}
			else if ((ptr = strstr(line_buffer, "DECTPASSWD="))) {
				sscanf(ptr + 11, "%63s", buffer);
//				FritzDectPW=buffer;
			}
			else if ((ptr = strstr(line_buffer, "FRITZBOXIP=")))
				sscanf(ptr + 11, "%63s", (char *) &FritzAdr);
			else if ((ptr = strstr(line_buffer, "PORT=")))
				sscanf(ptr + 5, "%i", &FritzPort);
			else if ((ptr = strstr(line_buffer, "BACKWARDSEARCH=")))
				sscanf(ptr + 15, "%i", &BackwardSearch);
			else if ((ptr = strstr(line_buffer, "DEBUG=")))
				sscanf(ptr + 6, "%i", &debug);
			else if ((ptr = strstr(line_buffer, "MSGTYPE=")))
				sscanf(ptr + 8, "%5s", (char *) &msgtype);
			else if ((ptr = strstr(line_buffer, "MSGTIMEOUT=")))
				sscanf(ptr + 11, "%i", &msgtimeout);
			else if ((ptr = strstr(line_buffer, "MSN_1="))) {
				sscanf(ptr + 6, "%31[^|\n]", msnnum[0].msn);
				if((ptr = strstr(line_buffer, "|")))
					sscanf(ptr + 1, "%63[^\n]", msnnum[0].msnName);
			}
			else if ((ptr = strstr(line_buffer, "MSN_2="))) {
				sscanf(ptr + 6, "%31[^|\n]", msnnum[1].msn);
				if((ptr = strstr(line_buffer, "|")))
					sscanf(ptr + 1, "%63[^\n]", msnnum[1].msnName);
			}
			else if ((ptr = strstr(line_buffer, "MSN_3="))) {
				sscanf(ptr + 6, "%31[^|\n]", msnnum[2].msn);
				if((ptr = strstr(line_buffer, "|")))
					sscanf(ptr + 1, "%63[^\n]", msnnum[2].msnName);
			}
			else if ((ptr = strstr(line_buffer, "MSN_4="))) {
				sscanf(ptr + 6, "%31[^|\n]", msnnum[3].msn);
				if((ptr = strstr(line_buffer, "|")))
					sscanf(ptr + 1, "%63[^\n]", msnnum[3].msnName);
			}
			else if ((ptr = strstr(line_buffer, "MSN_5="))) {
				sscanf(ptr + 6, "%31[^|\n]", msnnum[4].msn);
				if((ptr = strstr(line_buffer, "|")))
					sscanf(ptr + 1, "%63[^\n]", msnnum[4].msnName);
			}
			else if ((ptr = strstr(line_buffer, "MSN_6="))) {
				sscanf(ptr + 6, "%31[^|\n]", msnnum[5].msn);
				if((ptr = strstr(line_buffer, "|")))
					sscanf(ptr + 1, "%63[^\n]", msnnum[5].msnName);
			}
			else if ((ptr = strstr(line_buffer, "BOXIP_1=")))
				sscanf(ptr + 8, "%24s", boxnum[0].BoxIP);
			else if ((ptr = strstr(line_buffer, "BOXIP_2=")))
				sscanf(ptr + 8, "%24s", boxnum[1].BoxIP);
			else if ((ptr = strstr(line_buffer, "BOXIP_3=")))
				sscanf(ptr + 8, "%24s", boxnum[2].BoxIP);
			else if ((ptr = strstr(line_buffer, "BOXIP_4=")))
				sscanf(ptr + 8, "%24s", boxnum[3].BoxIP);
			else if ((ptr = strstr(line_buffer, "LOGON_1=")))
				sscanf(ptr + 8, "%63s", boxnum[0].logon);
			else if ((ptr = strstr(line_buffer, "LOGON_2=")))
				sscanf(ptr + 8, "%63s", boxnum[1].logon);
			else if ((ptr = strstr(line_buffer, "LOGON_3=")))
				sscanf(ptr + 8, "%63s", boxnum[2].logon);
			else if ((ptr = strstr(line_buffer, "LOGON_4=")))
				sscanf(ptr + 8, "%63s", boxnum[3].logon);
			else if ((ptr = strstr(line_buffer, "ADDRESSBOOK=")))
				sscanf(ptr + 12, "%127s", (char *) &addressbook);
			else if ((ptr = strstr(line_buffer, "EASYMODE=")))
				sscanf(ptr + 9, "%i", &easymode);
			else if ((ptr = strstr(line_buffer, "PASSWD=")))
				sscanf(ptr + 7, "%63s", (char *) &FritzPW);
			else if ((ptr = strstr(line_buffer, "AD_FLAGFILE=")))
				sscanf(ptr + 12, "%127s", (char *) &adflag);
			else if ((ptr = strstr(line_buffer, "SEARCH_MODE=")))
				sscanf(ptr + 12, "%i", &searchmode);
			else if ((ptr = strstr(line_buffer, "SEARCH_QUERY=")))
				sscanf(ptr + 13, "%99s", (char *) &searchquery);
			else if ((ptr = strstr(line_buffer, "SEARCH_INT=")))
				sscanf(ptr + 11, "%i", &searchint);
			else if ((ptr = strstr(line_buffer, "CITYPREFIX=")))
				sscanf(ptr + 11, "%9s", (char *) &cityprefix);
			else if ((ptr = strstr(line_buffer, "EXEC=")))
				sscanf(ptr + 5, "%127s", (char *) &execute);
			else if ((ptr = strstr(line_buffer, "CALLERLIST_FILE=")))
				sscanf(ptr + 16, "%127s", (char *) &listfile);
		}
		fclose(fd_conf);
	}
	else
	{
		printf("[%s] - ERROR open %s\n", BASENAME,fname);
	}
	if(line_buffer)
		free(line_buffer);

	return(0);
}

int CFCM::read_conf(const string& file)
{
	fstream fh;
	string s, key, value, inx;

	// clean table for reload
	c.clear();
	wp.clear();
	dp.clear();

	fh.open(file.c_str(), ios::in);

	if(!fh.is_open())
	{
		cout << "Error reading configfile \"" << file << "\"" << endl;
		return 1;
	}

	while (getline(fh, s))
	{
		string::size_type begin = s.find_first_not_of(" \f\t\v");

		// skip blank lines
		if (begin == string::npos)
			continue;

		// skip commentary
		if (string("#;").find(s[begin]) != string::npos)
			continue;

		// extract the key value
		string::size_type end = s.find('=', begin);
		// skip lines without "="
		if (end == string::npos)
			continue;
		key = s.substr(begin, end - begin);

		// trim key
		//key.erase(key.find_last_not_of(" \f\t\v") + 1);
		cconnect->StringReplace(key," ;[;];\f;\t;\v", "");

		// skip blank keys
		if (key.empty())
			continue;

		// extract and trim value
		begin = s.find_first_not_of(" \f\n\r\t\v", end);
		end   = s.find_last_not_of(" \f\n\r\t\v") + 1;
		value = s.substr(begin + 1, end - begin);
		cconnect->StringReplace(value," ;[;];\f;\t;\v", "");

		// *** special maps ***

		// create map for Comet temp
		inx = create_map(key, "DP", value, dp);
		if(!inx.empty())
			continue;

		// create map for Comet week
		inx = create_map(key, "WP", value, wp);
		if(!inx.empty())
			continue;

		// *** config map ***

		// create map for config
		if(!key.empty()) {
			c[key] = value;
			//debug
			//cout << key << "=" << value << endl;
		}
	}
	fh.close();

	return 0;
}

void Usage()
{
	printf("[%s] - FritzBox-Anrufmonitor %s %s\n\n", BASENAME, VERSION, COPYR);;
	printf("\t\tUSAGE:\t%s\n", BASENAME);
	printf("\t\t\t-c\t\t\tget callerlist (FRITZ!Box_Anrufliste.csv)\n");
	printf("\t\t\t-h\t\t\tshow help\n");
	printf("\t\t\t-q\t\t\tsend query to FRITZ!Box\n");
	printf("\t\t\t-m\t\t\tsend message to BOXIP_1\n");
	printf("\t\t\t-s\t\t\tget smart Home infos\n");
	printf("\t\t\t-t [phonenumber] [MSN]\ttest backward search\n");
}

int main(int argc, char *argv[])
{
	CFCM * cfcm = CFCM::getInstance();
	cfcm->run(argc,argv);
}

int CFCM::run(int argc, char *argv[])
{
	printf("\n[%s] - NI FRITZ!Box-Anrufmonitor %s - %s\n", BASENAME, VERSION, COPYR);

	if(strlen(msnnum[0].msn)==0)
		printf("[%s] - Listening to all MSN's\n", BASENAME);
	else {
		for (int i=0; i < (int)(sizeof(msnnum)/sizeof(msnnum[0])); i++) {
			if(strlen(msnnum[i].msn)!=0) {
				cout << '[' << BASENAME << "] - Listening to MSN " << msnnum[i].msn << 
				(strlen(msnnum[i].msnName)!=0 ? " (" : "") <<
				(strlen(msnnum[i].msnName)!=0 ? msnnum[i].msnName : "") <<
				(strlen(msnnum[i].msnName)!=0 ? ")" : "") << endl;
			}
		}
	}

	switch (argc)
	{
		case 1:
			if(searchmode || !c["DECTBOXIP"].empty())
				start_loop();
			FritzCall();
			return 0;
		case 2:
			if (strstr(argv[1], "-h"))
			{
				Usage();
				break;
			}
			else if (strstr(argv[1], "-b"))
			{
				switch(fork())
				{
					case 0:
						if(searchmode || !c["DECTBOXIP"].empty())
							start_loop();
						FritzCall();
						break;

					case -1:
						printf("[%s] - Aborted!\n", BASENAME);
						return -1;
					default:
					      exit(0);
				}
			}
			else if (strstr(argv[1], "-c"))
			{
				printf("[%s] - get FRITZ!Box_Anrufliste.csv from FritzBox\n", BASENAME);

				if(!cconnect->get_login(FritzPW)) {
					exit(1);
				}

				//cconnect->send_refresh(cconnect->sid);
				cconnect->get_callerlist(cconnect->getSid(),listfile);
				cconnect->send_logout(cconnect->getSid());
				exit(0);
			}
			else if (strstr(argv[1], "-q"))
			{
				printf("[%s] - %s send query 2 FritzBox\n", BASENAME, cconnect->timestamp().c_str());

				if(!cconnect->get_login(FritzPW)) {
					exit(1);
				}

				cconnect->send_TAMquery(adflag,cconnect->getSid(),searchquery);

				exit(0);
			}
			else if (strstr(argv[1], "-m"))
			{
				cconnect->get2box(boxnum[0].BoxIP, 80, "FritzCallMonitor Testmessage", boxnum[0].logon, msgtype, msgtimeout);
				return 0;
			}
			else if (strstr(argv[1], "-s"))
			{
				printf("[%s] - get smart Home infos from FritzBox\n", BASENAME);

				cconnect->setFritzAdr(c["DECTBOXIP"].c_str());

				if(!cconnect->get_login(c["DECTPASSWD"].c_str())) {
					cconnect->setFritzAdr(FritzAdr);
					exit(1);
				}

				// fill vector with device infos
				cconnect->smartHome(cconnect->getSid(),"getdevicelistinfos");

				cconnect->checkdevice(wp,dp);
				// delete device vector
				cconnect->cleardevice();

				cconnect->setFritzAdr(FritzAdr);
				exit(0);
			}
			else
			{
				Usage();
				exit(1);
			}
		case 4:
			if (strstr(argv[1], "-t"))
			{
				printf("[%s] - serarch for %s\n", BASENAME, argv[2]);
				strcpy(CallFrom, argv[2]);
				strcpy(CallTo, argv[3]);
				search(CallFrom);
				return 0;
			}
		default:
			Usage();
			exit(1);
	}
	return(0);
}

 
