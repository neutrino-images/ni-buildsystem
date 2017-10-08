
#include <stdlib.h>
#include <string.h>

#include <fstream>
#include <iostream>
#include <sstream>

//#include "md5.h"
#include <openssl/md5.h>
#include <stdarg.h>
#include <curl/curl.h>

#include "parser.h"
#include "globals.h"

#include "connect.h"

using namespace std;

class CurledClass
{
  public:

  static int writer(char *data, size_t size, size_t nmemb, std::string *buffer_in)
  {

	// Is there anything in the buffer?
	if (buffer_in != NULL)
	{
		// Append the data to the buffer
		buffer_in->append(data, size * nmemb);
 
		// How much did we write?
		return size * nmemb;
	}
	return 0;
  }
};

CConnect* CConnect::getInstance()
{
	static CConnect* instance = NULL;
	if(!instance)
		instance = new CConnect();
	return instance;
}

CConnect::CConnect()
{
	cpars = CParser::getInstance();

	//sockfb		= 0;
	query_logic	= 0;
	loginLUA 	= 0;
	debug		= 1;
}

CConnect::~CConnect()
{
	//
}

#if 0
/******************************************************************************
 * functions
 ******************************************************************************/
#endif
std::string CConnect::post2fritz(const char* url, const std::string data, const std::string curlOutFile)
{
	CURL *curl;
	CURLcode result;

	// multipart post
	struct curl_httppost *formpost=NULL;
	struct curl_httppost *lastptr=NULL;
	struct curl_slist *headerlist=NULL;
	static const char buf[] = "Expect:";

	if(!multipart.empty())
	{
		curl_global_init(CURL_GLOBAL_ALL);

		// add all map values
		for (vector<string>::iterator it = multipart.begin(); it != multipart.end(); ++it)
		{
			// extract the name value
			string::size_type begin = (*it).find_first_not_of(" \f\t\v");
			string::size_type end = (*it).find('=');
			string key = (*it).substr(begin, end - begin);

			// extract the contents value
			begin = (*it).find_first_not_of(" \f\n\r\t\v", end);
			end   = (*it).find_last_not_of(" \f\n\r\t\v");
			string value = (*it).substr(begin + 1, end - begin);

			//cout << key << "='" << value << "'" << endl;

			curl_formadd(&formpost,
				&lastptr,
				CURLFORM_COPYNAME, key.c_str(),
				CURLFORM_COPYCONTENTS, value.c_str(),
				CURLFORM_END);
		}
	}

	// Create our curl handle
	curl = curl_easy_init();

	if(!multipart.empty()) {
		// initialize custom header list (stating that Expect: 100-continue is not wanted
		headerlist = curl_slist_append(headerlist, buf);
	}

	//errors
	char errorBuffer[CURL_ERROR_SIZE];

	// Write all expected data in here
	std::string buffer;

	if(!curl){
		std::cerr << "Error init Curl!" << std::endl;
		return std::string();
	}

	curl_easy_setopt(curl, CURLOPT_ERRORBUFFER, errorBuffer);
	curl_easy_setopt(curl, CURLOPT_URL, url);
	curl_easy_setopt(curl, CURLOPT_HEADER, 0);
	curl_easy_setopt(curl, CURLOPT_USERAGENT, "Mozilla/5.0");
	curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
	curl_easy_setopt(curl, CURLOPT_VERBOSE, debug?1:0);
	curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0);

	if(!multipart.empty())
		curl_easy_setopt(curl, CURLOPT_HTTPPOST, formpost);

	if(!data.empty())
	{
		curl_easy_setopt(curl, CURLOPT_POST, 1);
		curl_easy_setopt(curl, CURLOPT_POSTFIELDS, data.c_str());
		// print CURLOPT_POSTFIELDS
		if(debug > 1 && !data.empty()) {cout << '[' << BASENAME << "] - CURLOPT_POSTFIELDS: " << data << endl;}
	}

	FILE *tmpFile = fopen(curlOutFile.c_str(), "w");
	if (tmpFile) {
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, NULL);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, tmpFile);
	} else  {
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, CurledClass::writer);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, &buffer);
	}

	// Attempt to retrieve the remote page
	result = curl_easy_perform(curl);

	// Always cleanup
	curl_easy_cleanup(curl);
	if (tmpFile)
		fclose(tmpFile);
	if(!multipart.empty())
		multipart.clear();

	if(debug > 1){
		if(curlOutFile.empty())
			cout << "DEBUG-OUT" << ">>" << buffer << "<<" << "DEBUG-OUT END" << endl;
		else
			cout << "DEBUG-OUT" << ">>" << curlOutFile << "<<" << "DEBUG-OUT END" << endl;
	}

	if(result == CURLE_OK)
		return(buffer);

	return std::string();
}

int CConnect::get_challenge(bool lua)
{
	ostringstream url;

	log(1,"%s(%s)\n", __FUNCTION__, lua?"lua":"xml");

	//if(mysockfb <= 0){
	//	printf("[%s] - CConnect::get_challenge(): ERR connect2Host\n", BASENAME);
	//	return 0;
	//}

	if(lua){
		url << cpars->getFritzAdr() << "/login_sid.lua"; // OS 5.50
	} else {
		url << cpars->getFritzAdr() <<  "/cgi-bin/webcm?getpage=../html/login_sid.xml"; // Firmwareversion xx.04.74
	}

	string s = post2fritz(url.str().c_str(), "");

	//search
	string s1 = "<Challenge>";
	string s2 = "</Challenge>";
	string token;
	size_t pos = 0;

	if((pos = s.find(s1)) != string::npos)
	{
		s.erase(0, pos + s1.length());

		pos = 0;
		if((pos = s.find(s2)) != string::npos)
		{
			s.erase(pos, s.length());
			if(!s.empty())
			{
				strncpy(challenge,s.c_str(),sizeof(challenge));
				if(debug) {printf("[%s] - CHALLENGE %s \n", BASENAME, challenge);}
				return 1;
			}
		}
	}

	if(lua)
	{
		log(0,"%s(%s) - NO CHALLENGE found\n", __FUNCTION__, lua?"lua":"xml");
		return(get_challenge(false/*xml*/));
	}
	else
	{
		log(0,"%s(%s) - failed to get CHALLENGE\n", __FUNCTION__, lua?"lua":"xml");
	}

	return 0;
}

int CConnect::get_md5(const char *challenge, char *fritzPW)
{
	//convert to utf16
	//http://www.avm.de/de/Extern/Technical_Note_Session_ID.pdf
	unsigned int i;
	int y = 0;

	std::string utf8_str = (std::string) challenge + "-" + (std::string) UTF8toISO(fritzPW);
	std::string utf16_str = ("");

	log(2,"Challenge-Password = \"%s-%s\"\n",challenge, UTF8toISO(fritzPW));

	log(1,"Binary for hash = ");

	for (i=0; i < utf8_str.length(); i++)
	{
		y = i*2;
		// change UNICODE > 255 in 46 (".")
		if (utf8_str[i] > 0xAD)
		{
			utf16_str += '\x2E';
			utf16_str += '\x00';
		}
		else
		{
			utf16_str += utf8_str[i];
			utf16_str += '\x00';
		}
		if (debug)
			printf("%02x%02x",utf16_str[y],utf16_str[y+1]);
	}
	if (debug)
		printf("\n");

	//get md5sum from utf16 binary hash
	MD5_CTX ctx; 
	//struct MD5Context ctx; /*md5.h"*/

	MD5_Init(&ctx);
	MD5_Update(&ctx, utf16_str.c_str(), strlen(utf8_str.c_str())*2)/*size*/;
	MD5_Final(digest, &ctx);

	strcpy((char *)md5sum,"");

	for (i = 0; i < 16; i++) {
		char fdigest[5];
		sprintf(fdigest,"%02x", digest[i]);
		strcat((char *)md5sum, fdigest);
	}

	log(2,"MD5 hash = %s (%d)\n",md5sum, strlen((char *)md5sum));

	return(strlen((char *)md5sum));
}

int CConnect::get_sid(const char *challenge, const unsigned char *md5)
{
	ostringstream url,command;

	url	<< cpars->getFritzAdr() << "/cgi-bin/webcm";
	command	<< "login:command/response="
		<< challenge << '-' << md5
		<< "&getpage=../html/login_sid.xml";

	if(debug) {cout << '[' << BASENAME << "] - " << __FUNCTION__ << "()" << endl;}

	string s = post2fritz(url.str().c_str(), command.str());

	//search
	string s1 = "<SID>";
	string s2 = "</SID>";
	string token;
	size_t pos = 0;

	if((pos = s.find(s1)) != string::npos)
	{
		s.erase(0, pos + s1.length());

		pos = 0;
		if((pos = s.find(s2)) != string::npos)
		{
			s.erase(pos, s.length());
			if(s != "0000000000000000" && !s.empty())
			{
				strncpy(sid,s.c_str(),sizeof(sid));
				if(debug) {printf("[%s] - SID %s \n", BASENAME, sid);}
				return 1;
			}
		}
	}

	printf("[%s] - failed to get SID\n", BASENAME);
	return(0);
}

int CConnect::get_sid_LUA(const char *challenge, const unsigned char *md5)
{
	ostringstream url, command;

	url << cpars->getFritzAdr() << "/login_sid.lua";

	command	<< "response="
		<< challenge << '-' << md5;

	if(debug) {cout << '[' << BASENAME << "] - " << __FUNCTION__ << "()" << endl;}

	string s = post2fritz(url.str().c_str(), command.str());

	//search
	string s1 = "<SID>";
	string s2 = "</SID>";
	string token;
	size_t pos = 0;

	if((pos = s.find(s1)) != string::npos)
	{
		s.erase(0, pos + s1.length());

		pos = 0;
		if((pos = s.find(s2)) != string::npos)
		{
			s.erase(pos, s.length());
			if(s != "0000000000000000" && !s.empty())
			{
				strncpy(sid,s.c_str(),sizeof(sid));
				if(debug) {printf("[%s] - SID %s \n", BASENAME, sid);}
				return 1;
			}
		}
	}

/*	//split into line
	string delimiter = "\n";
	string token;
	size_t pos = 0;

	while ((pos = s.find(delimiter)) != string::npos) {
		i++;
		token = s.substr(0, pos);
		if(debug) {cout << "rec[" << i << "]" << token << endl;}
		s.erase(0, pos + delimiter.length());
	}
*/

	printf("[%s] - failed to get SID\n", BASENAME);
	return(0);
}
#if 0
/******************************************************************************
 * tools
 ******************************************************************************/
#endif
char *CConnect::trim(char *txt)
{
	register int l;
	register char *p1, *p2;

	if (*txt==' ')
	{
		for (p1=p2=txt;
			(*p1==' ') || (*p1=='\t') || (*p1=='\n') || (*p1=='\r');
			p1++);
		while (*p1)
			*p2++=*p1++;
		*p2='\0';
	}
	if ((l=strlen(txt))>0)
		for (p1=txt+l-1;
			(*p1==' ') || (*p1=='\t') || (*p1=='\n') || (*p1=='\r');
			*p1--='\0');
	return(txt);
}

char *CConnect::UTF8toISO(char *txt)
{
	//http://www.lingua-systems.de/knowledge/unicode-mappings/iso-8859-1-to-unicode.html
	//'ä','ö','ü','Ä','Ö','Ü','ß','é'
	const unsigned	iso[]={'\xe4','\xf6','\xfc','\xc4','\xd6','\xdc','\xdf','\xe9'}, //ISO-8859-1	ö = 0xf6
			utf[]={'\xa4','\xb6','\xbc','\x84','\x96','\x9c','\x9f','\xa9'}; //UTF-8	ö = 0xc3 0xb6

	int i,found,quota=0;
	char *rptr=txt,*tptr=txt;

	while(*rptr != '\0')
	{
		if(*rptr=='\'')
		{
			quota^=1;
		}
		if (!quota && *rptr=='\xc3' && *(rptr+1))
		{
			found=0;
			for(i=0; i<(int)sizeof(utf) && !found; i++)
			{
				if(*(rptr+1)==utf[i])
				{
					found=1;
					*tptr=iso[i];
					++rptr;
				}
			}
			if(!found)
			{
				*tptr=*rptr;
			}
		}
		else if (!quota && *rptr=='\xc2' && *(rptr+1))
		{
			*tptr=*(rptr+1);
			++rptr;
		}
		else
		{
			*tptr=*rptr;
		}
		tptr++;
		rptr++;
	}
	*tptr=0;
	return(txt);
}

void CConnect::log(const int& dlevel, const char *ftxt,...)
{
	if(debug >= dlevel)
	{
		va_list params;
		va_start(params, ftxt);
		printf("[%s] - ", BASENAME);
		vprintf(ftxt, params);
		fflush(stdout);
		va_end(params);
	}
}

#if 0
/******************************************************************************
 * get login to Fritz!Box
 ******************************************************************************/
#endif
int CConnect::get_login(const char* fritzPW)
{
	log(1,"%s()\n", __FUNCTION__);

	int ret=get_challenge();

	if (ret < 0)
		return 0;

	if(!ret)
	{
		if(!send_old_login(fritzPW)) {
			log(0,"ERROR send_old_login\n");
			return 0;
		}
	}
	else 
	{
		get_md5(challenge,(char*)fritzPW);

		if(!get_sid_LUA(challenge,md5sum))
		{
			log(0,"login_sid.lua not found\n");
			if(!get_sid(challenge,md5sum))
			{
				log(0,"ERROR get SID\n");
				return 0;
			}
		}
		else
			loginLUA = 1;
	}

	query_logic = get_query_logic(sid,0);

	if(!query_logic) {
		if(get_OLDquery_logic(sid,1)) {
			query_logic=2; //old logic
		}
		else {
			log(0,"ERROR get query logic\n");
			return 0;
		}
	}

	log(1,"query_logic = %i\n", query_logic);
	return(query_logic);
}
#if 0
/******************************************************************************
 * send logout to Fritz!Box
 ******************************************************************************/
#endif
int CConnect::send_logout(const char *sid)
{
	ostringstream url, command;

	url	<< cpars->getFritzAdr() << "/cgi-bin/webcm";
	command	<< "sid=" << sid
		<< "&security:command/logout=&getpage=../html/confirm_logout.htlm";

	if(debug) {cout << '[' << BASENAME << "] - " << __FUNCTION__ << "()" << endl;}

	//(w_fritz, "GET /home/home.lua?sid=%s&logout=1 HTTP/1.1\r\nHost: 192.168.99.254\r\n\r\n", sid);

	post2fritz(url.str().c_str(), command.str().c_str());

	return(1);
}
#if 0
/******************************************************************************
 * send old logic password to Fritz!Box
 ******************************************************************************/
#endif
int CConnect::send_old_login(const char *fritzPW)
{
	ostringstream url, command;
	size_t pos = 0;

	url	<< cpars->getFritzAdr() << "/cgi-bin/webcm";
	command	<< "getpage=../html/de/menus/menu2.html&var%3Alang=de&var%3Amenu=home&var%3Apagename=home&login%3Acommand%2Fpassword="
		<< fritzPW << "&sid=" << sid;

	if(debug) {cout << '[' << BASENAME << "] - " << __FUNCTION__ << "()" << endl;}

	string s = post2fritz(url.str().c_str(), command.str().c_str());

	if((pos= s.find("class=\"errorMessage\"")) != std::string::npos)
	{
		log(0,"failed to get old login\n");
		return 0;
	}

	return 1;
}
#if 0
/******************************************************************************
 * send query's to Fritz!Box
 ******************************************************************************/
#endif
int CConnect::get_query_logic(const char *sid, int logic)
{
	if(!loginLUA) {
		return (get_OLDquery_logic(sid, logic));
	}

	size_t pos;
	std::ostringstream url;

	log(1,"%s()\n", __FUNCTION__);

	url	<< cpars->getFritzAdr() << "/query.lua?sid=" << sid
		<< "&ver=uimodlogic:status/nspver"; //Firmware > 06.9

	string s = post2fritz(url.str().c_str(), "");
	string res = cpars->parseString("ver", s);

	if(!res.empty() && (pos = res.find('.')) != string::npos)
	{
		log(0,"Firmwareversion (%s)\n", res.c_str());
		cpars->setNspver(res);
		query_logic = 3;
		return (query_logic);
	}
	else
	{
		url.str("");
		url	<< cpars->getFritzAdr() << "/query.lua?sid=" << sid
		<< "&ver=logic:status/nspver"; //Firmware < 06.9

		s = post2fritz(url.str().c_str(), "");
		res = cpars->parseString("ver", s);

		if(!res.empty() && (pos = res.find('.')) != string::npos)
		{
			log(0,"Firmwareversion (%s)\n", res.c_str());
			cpars->setNspver(res);
			query_logic = 3;
			return (query_logic);
		}
	}

	return (get_OLDquery_logic(sid, logic));
}

int CConnect::get_OLDquery_logic(const char *sid, int logic)
{
	ostringstream url, command;
	std::string output ="/tmp/fim.out";
	char *line;
	ssize_t read;
	size_t len;
	FILE* fd;
	int i = 0;
	int res = 0;

	url	<< cpars->getFritzAdr() << "/cgi-bin/webcm";

	if(logic)
	{
		command	<< "getpage=../html/query.txt&var:cnt=1&var:n0=logic:status/nspver" //old
			<< "&sid=" << sid;
	}
	else
	{
		command	<< "getpage=../html/query.txt&var:n[0]=logic:status/nspver" //new
			<< "&sid=" << sid;
	}

	log(1,"%s()\n", __FUNCTION__);

	post2fritz(url.str().c_str(), command.str().c_str(),output);

	line=NULL;
	if((fd = fopen(output.c_str(), "r")))
	{
		while ((read = getline(&line, &len, fd)) != -1)
		{
			i++;
			if(debug){cout << "rec " << '[' << i << ']' << line;}

			if(i==1)
			{
				if(strlen(trim(line))!=0 && strlen(trim(line))<35) {
					log(0,"Firmwareversion (%s)\n", (trim(line)));
					cpars->setNspver(trim(line));
					res=1;
				}
			}
		}
		fclose(fd);
	}
	if(line)
		free(line);

	return (res);
}

int CConnect::send_refresh(const char *sid)
{
	if(query_logic == 3) {
		return(0);
	}

	std::ostringstream url, command;

	url	<< cpars->getFritzAdr() << "/cgi-bin/webcm";

	command	<< "getpage=../html/query.txt"
		<< (query_logic==2 /*old logic*/ ? "&var:cnt=2" : "")
		<< "&var:n"
		<< (query_logic==1 ? "[" : "") << 0 << (query_logic==1 ? "]" : "")
		<< "=telcfg:settings/RefreshJournal&var:n"
		<< (query_logic==1 ? "]" : "") << 1 << (query_logic==1 ? "]" : "")
		<< "=telcfg:settings/Journal/count"
		<< "&sid=" << sid;

	log(1,"%s()\n", __FUNCTION__);

	post2fritz(url.str().c_str(), command.str().c_str());
	return 0;
}

/******************************************************************************
 * FritzInfoMonitor
 ******************************************************************************/
#if 0
void send_query(char *sid, char *searchquery)
{
/*
	-- query.lua
	--
	-- Liest Werte von Control-Manager Variablen aus und gibt diese in einer JSON Struktur zur├╝ck.
	--
	-- Jeder GET Parameter wird als <name>=<query> gedeutet. <name> kann dabei relativ frei gew├ñhlt werden. <query>
	-- ist der Querystring f├╝r eine Control-Manager Variable.
	--
	-- Beispiel: http://fritz.box/query.lua?fw=logic:status/nspver&ld=landevice:settings/landevice/list(name,ip,mac)
	--
	-- Ja, normale Queries k├Ânnen mit Multiqueries gemischt werden.
	--
	-- Multiqueries werden am Vorhandensein von "list(...)" in der Query erkannt. Da alte emu-Module dieses Kommando
	-- nicht kennen, kann alternativ der Pr├ñfix "mq_" vor den Namen der Query gesetzt werden. Beispiel:
	-- http://fritz.box/query.lua?mq_log=logger:status/log
	-- Nur bei einer "mq_" Liste wird der Knotennamen ("landevice0") mit ausgegeben.
	--
	-- Und nicht die Session-ID vergessen! Wenn die Box mit einem Passwort gesichert ist, sieht ein Request in
	-- Wahrheit so aus:
	-- http://fritz.box/query.lua?sid=bc0c3998a520f93c&fw=logic:status/nspver
	--
	-- Wenn auf der Box kein Passwort gesetzt ist, kann die Session-ID entfallen. Das Skript sorgt dann selbst f├╝r
	-- eine g├╝ltige Session-ID.
	--
*/

	int i;
	int y=0;
	int inx=-1;
	char *ptr;
	char line[BUFFERSIZE];

	connect2fritz();

	if(debug)
		printf("GET /query.lua?sid=%s&mq_result=%s HTTP/1.1\n", sid, searchquery);

	fprintf(w_fritz, "GET /query.lua?sid=%s&mq_result=%s HTTP/1.1\r\n\r\n", sid, searchquery);

	fflush(w_fritz);

	for (i=1; 1; i+=1) {

		char *s=fgets(line, sizeof(line), r_fritz);

		if(debug)
			printf("Line %d/[%d]%d: %s",i,inx,y,line);

		if (s==NULL)
		{
			break;
		}
		else if (strstr(line, "Journal"))
		{
			y=0;
			inx++;
		}
		else if(inx >= 0)
		{
/*
			Line 1/[-1]0: HTTP/1.0 200 OK
			Line 2/[-1]1: Content-type: application/json
			Line 3/[-1]2: Expires: -1
			Line 4/[-1]3:
			Line 5/[-1]4: {
			Line 6/[-1]5:  "mq_result" : [
			Line 7/[-1]6:  {
			Line 8/[-1]7:  "_node" : "Journal0",
			Line 9/[0]1:  "0" : "3",
			Line 10/[0]2:  "5" : "07.09.11 20:48",
			Line 11/[0]3:  "Type" : "caller number",
			Line 12/[0]4:  "Date" : "4",
			Line 13/[0]5:  "Number" : "0:03",
			Line 14/[0]6:  "Port" : "my number",
			Line 15/[0]7:  "Duration" : "0",
			Line 16/[0]8:  "Route" : "Name",
			Line 17/[0]9:  "RouteType" : "my home",
			Line 18/[0]10:  "Name" : ""
			Line 19/[0]11:  },
			Line 20/[0]12:  {
			Line 21/[0]13:  "_node" : "Journal1",
*/
			switch (y)
			{
				case 1: sscanf(line + 8, "%[^\"]", (char *) &caller[inx].call_type);
				case 2: sscanf(line + 8, "%[^\"]", (char *) &caller[inx].call_date);
				case 3: sscanf(line +11, "%[^\"]", (char *) &caller[inx].call_numr);
					if(strlen(caller[inx].call_numr) == 0) {
					//	strcpy(caller[inx].call_numr, "keine Rufnummer");
					}
				case 8: sscanf(line +12, "%[^\"]", (char *) &caller[inx].call_name);
					if(strlen(caller[inx].call_name) == 0) {
					//	strcpy(caller[inx].call_name, "unbekannt");
					}
			}
		}
		y++;
	}

	if(debug) {
		for (i=0; i < MAXCALLER; i++)
			printf("inx[%i] %s %s %s %s\n",i,caller[i].call_type, caller[i].call_date, caller[i].call_numr, caller[i].call_name);
	}

	// When finished send all lingering transmissions and close the connection
	quitfritz();
}
#endif

int CConnect::send_query_info(const char *sid)
{
	if(query_logic == 3) {
		return(get_QueryInfos(sid));
	}

	char *line;
	ssize_t read;
	size_t len;
	string output ="/tmp/fim.out";
	FILE* fd;
	int i = 0;

	ostringstream url, command;

	url	<< cpars->getFritzAdr() << "/cgi-bin/webcm";

	if(query_logic==2) 
	{
		command	<< "getpage=../html/query.txt"
			<< "&var:cnt=6"
			<< "&var:n0=ddns:settings/account0/state"
			<< "&var:n1=ddns:settings/account0/domain"
			<< "&var:n2=tam:settings/TAM0/Active"
			<< "&var:n3=tam:settings/TAM0/NumNewMessages"
			<< "&var:n4=sip:settings/sip0/displayname"
			<< "&var:n5=sip:settings/sip1/displayname"
			<< "&var:n6=connection0:pppoe:status/ip"
			<< "&sid=" << sid;
	}
	else
	{
		command	<< "getpage=../html/query.txt"
			<< "&var:n[0]=ddns:settings/account0/state"
			<< "&var:n[1]=ddns:settings/account0/domain"
			<< "&var:n[2]=tam:settings/TAM0/Active"
			<< "&var:n[3]=tam:settings/TAM0/NumNewMessages"
			<< "&var:n[4]=sip:settings/sip0/displayname"
			<< "&var:n[5]=sip:settings/sip1/displayname"
			<< "&var:n[6]=connection0:pppoe:status/ip"
			<< "&sid=" << sid;
	}

	log(1,"%s()\n", __FUNCTION__);

	post2fritz(url.str().c_str(), command.str().c_str(),output);

	line=NULL;
	if((fd = fopen(output.c_str(), "r")))
	{
		while ((read = getline(&line, &len, fd)) != -1)
		{
			i++;
			if(debug>1){cout << "rec " << '[' << i << ']' << line;}

			switch(i)
			{
				case 1: cpars->setDdns_state(trim(line));break;
				case 2: cpars->setDdns_domain(trim(line)); break;
				case 3: cpars->setTam0_active(trim(line));break;
				case 4: cpars->setTam0_NumNewMessages(trim(line));break;
				case 5: cpars->setSip0Nr(trim(line));break;
				case 6: cpars->setSip1Nr(trim(line));break;
				case 7: cpars->setPppoe_ip(trim(line));break;
			}
		}
		fclose(fd);
		log(1,"ddns_state=%i ddns_domain=%s tam0_active=%i tam0_NumNewMessages=%i sip0nr=%s sip1nr=%s pppoe_ip=%s\n",
			atoi(cpars->getDdns_state().c_str()),
			cpars->getDdns_domain().c_str(),
			atoi(cpars->getTam0_active().c_str()),
			atoi(cpars->getTam0_NumNewMessages().c_str()),
			cpars->getSip0Nr().c_str(),cpars->getSip1Nr().c_str(),
			cpars->getPppoe_ip().c_str());
	}
	if(line)
		free(line);

	return 0;
}

int CConnect::get_QueryInfos(const char *sid)
{
	ostringstream url,command;
	int i = 0;

	url	<< cpars->getFritzAdr() << "/query.lua?sid=" << sid
		<< "&var0=ddns:settings/account0/state"
		<< "&var1=ddns:settings/account0/domain"
		<< "&var2=tam:settings/TAM0/Active"
		<< "&var3=tam:settings/TAM0/NumNewMessages"
		<< "&var4=sip:settings/sip0/displayname"
		<< "&var5=sip:settings/sip1/displayname"
		<< "&var6=connection0:pppoe:status/ip";

	log(1,"%s()\n", __FUNCTION__);

	string s = post2fritz(url.str().c_str(), "");
    StringReplace(s," ","");

	for (i=0; i <= 6; i++) 
	{
		stringstream ss;
		ss << "var" << i;

		string res = cpars->parseString(ss.str().c_str(), s);

		switch(i)
		{
			case  0: cpars->setDdns_state(res);break;
			case  1: cpars->setDdns_domain(res); break;
			case  2: cpars->setTam0_active(res);break;
			case  3: cpars->setTam0_NumNewMessages(res);break;
			case  4: cpars->setSip0Nr(res);break;
			case  5: cpars->setSip1Nr(res);break;
			case  6: cpars->setPppoe_ip(res);break;
		}
	}
	return 0;
}

int CConnect::send_query_caller(const char *sid, int s, int max)
{
	if(loginLUA) {
		return (get_caller_LUA(sid, s, max));
	}

	std::ostringstream url, command;
	int i=0;
	char *line;
	ssize_t read;
	size_t len;
	int inx=0;
	int inxx=0;
	int items=9;
	char c1[2] = "[";
	char c2[2] = "]";
	string output ="/tmp/fim.out";
	FILE* fd;

	log(1,"%s()\n", __FUNCTION__);

	cpars->init_caller();

	url	<< cpars->getFritzAdr() << "/cgi-bin/webcm";
	command	<< "getpage=../html/query.txt";

	if(query_logic==2) //old logic
	{
		strcpy(c1,"");
		strcpy(c2,"");
		items=7;
		command	<< "&var:cnt=" << items * max;
	}

	inx=0;
	log(0,"hole Eintrag %d bis %d\n",s+1,s+max);
	for (i=s; i <= s+max; i++) 
	{
		command	<< "&var:n" << c1 << inx << c2 << "=telcfg:settings/Journal" << i << "/Type";
		inx++;
		command	<< "&var:n" << c1 << inx << c2 << "=telcfg:settings/Journal" << i << "/Date";
		inx++;
		command	<< "&var:n" << c1 << inx << c2 << "=telcfg:settings/Journal" << i << "/Number";
		inx++;
		command	<< "&var:n" << c1 << inx << c2 << "=telcfg:settings/Journal" << i << "/Port";
		inx++;
		command	<< "&var:n" << c1 << inx << c2 << "=telcfg:settings/Journal" << i << "/Duration";
		inx++;
		command	<< "&var:n" << c1 << inx << c2 << "=telcfg:settings/Journal" << i << "/Route";
		inx++;
		command	<< "&var:n" << c1 << inx << c2 << "=telcfg:settings/Journal" << i << "/Name";
		inx++;

		if(query_logic==1)
		{ 
			command	<< "&var:n" << c1 << inx << c2 << "=telcfg:settings/Journal" << i << "/RouteType";
			inx++;
			command	<< "&var:n" << c1 << inx << c2 << "=telcfg:settings/Journal" << i << "/PortName";
			inx++;
		}
	}
	command	<< "&sid=" << sid;

	post2fritz(url.str().c_str(), command.str().c_str(), output);

	i=0;
	inx=0;
	inxx=0;

	line=NULL;
	if((fd = fopen(output.c_str(), "r")))
	{
		while ((read = getline(&line, &len, fd)) != -1)
		{
			i++;
			inx++;
			if(debug>1){cout << "rec" << '[' << inxx << ']' << '[' << inx << ']' << '[' << i << ']' << line;}
/*
			1="Type";
			2="Date";
			3="Number";
			4="Port";
			5="Duration";
			6="Route";
			7="Name";
			8="RouteType";
			9="PortName"
*/

			switch(inx)
			{
				case 1: strcpy(cpars->caller[inxx].call_type, trim(line)); break;
				case 2: strcpy(cpars->caller[inxx].call_date, trim(line)); break;
				case 3: strcpy(cpars->caller[inxx].call_numr, trim(line)); break;
				case 5: strcpy(cpars->caller[inxx].call_time, trim(line));break;
				case 6: strcpy(cpars->caller[inxx].port_rout, trim(line));break;
				case 7: strcpy(cpars->caller[inxx].call_name, UTF8toISO(trim(line)));
					if(query_logic != 1)
					{
						inx=0;
						inxx++;
					}
					break;
				case 9:
					strcpy(cpars->caller[inx].port_name, UTF8toISO(trim(line)));
					inx=0;
					inxx++;
					break;
			}

			if (inxx==max) 
			{
				break;
			}
		}
		fclose(fd);
	}
	if(debug) {
		for (i=0; i < max; i++)
			log(1,"inxx[%i] %s(%i) %s(%i) %s(%i) %s(%i) %s(%i) %s(%i) %s(%i)\n",i,
			       cpars->caller[i].call_type, strlen(cpars->caller[i].call_type),
			       cpars->caller[i].call_date, strlen(cpars->caller[i].call_date), 
			       cpars->caller[i].call_numr, strlen(cpars->caller[i].call_numr),
			       cpars->caller[i].call_name, strlen(cpars->caller[i].call_name),
			       cpars->caller[i].port_rout, strlen(cpars->caller[i].port_rout),
			       cpars->caller[i].port_name, strlen(cpars->caller[i].port_name),
			       cpars->caller[i].call_time, strlen(cpars->caller[i].call_time));
	}
	if(line)
		free(line);

	return(0);
}

int CConnect::get_caller_LUA(const char *sid, int s, int max)
{
	ostringstream url,command;
	string output = "/tmp/fim.out";
	int i = 0;
	int inx	= 0;
	int skip = 1;

	url	<< cpars->getFritzAdr() << "/fon_num/foncalls_list.lua?csv=";
	command	<< "refresh=&sid=" << sid;

	log(1,"%s()\n", __FUNCTION__);

	post2fritz(url.str().c_str(), command.str().c_str(), cpars->getListfile());

	cpars->init_caller();

	ifstream fh(cpars->getListfile());
	if ( fh.is_open() )
	{
		string line;

		while (getline(fh,line))
		{

			string	Typ;
			string	Datum;
			string	Name;
			string	Rufnummer;
			string	Nebenstelle;
			string	Eigene_Rufnummer;
			string	Dauer;

			istringstream in(line);

			// select data
			if(inx <= skip+s)
			{
				inx++;
				continue;
			}
			else if(inx > skip+s+max)
			{
				break;
			}

			if(	getline(in, Typ,		';') &&
				getline(in, Datum,		';') &&
				getline(in, Name,		';') &&
				getline(in, Rufnummer,		';') &&
				getline(in, Nebenstelle,	';') &&
				getline(in, Eigene_Rufnummer,	';') &&
				getline(in, Dauer,		';') )
			{
				size_t found;
				if((found = Eigene_Rufnummer.find("Internet")) != std::string::npos)
					Eigene_Rufnummer.replace(found,8,"@");

				//this is ugly, better use vector!!!
				strcpy(cpars->caller[i].call_type, Typ.c_str());
				strcpy(cpars->caller[i].call_date, Datum.c_str());
				strcpy(cpars->caller[i].call_numr, Rufnummer.c_str());
				strcpy(cpars->caller[i].call_time, Dauer.c_str());
				strcpy(cpars->caller[i].port_rout, Eigene_Rufnummer.c_str());
				strcpy(cpars->caller[i].call_name, UTF8toISO((char*)Name.c_str()));
				strcpy(cpars->caller[i].port_name, UTF8toISO((char*)Nebenstelle.c_str()));

				if(debug>1)
				{
					cout	<< "  rec[" << inx << "]" << line << endl;
					cout	<< "array[" << i << "]"
							<< Typ << ";"
							<< Datum << ";"
							<< Name << ";"
							<< Rufnummer << ";"
							<< Nebenstelle << ";"
							<< Eigene_Rufnummer << ";"
							<< Dauer << endl;
				}
				i++;
			}
			else {
				cerr << '[' << BASENAME << "] - " << __FILE__ << " could not parse line [" << inx << "]" << line << endl;
			}
			inx++;
		}
		fh.close();
	}
	else {
		cerr << '[' << BASENAME << "] - " << __FILE__ << "error open file" << endl;
	}

	return(0);
}

int CConnect::get_phonebooks(const char *sid, int phonebook)
{
	char *line;
	ssize_t read;
	size_t len;
	ostringstream url, command;
	string output ="/tmp/fim.out";
	FILE* fd;
	int i = 0;

	log(1,"%s()\n", __FUNCTION__);

	if(loginLUA) {
		return(get_phonebooks_LUA(sid, phonebook));
	}

	cpars->init_address();

	url	<< cpars->getFritzAdr() << "/cgi-bin/webcm";
	command	<< "telcfg:settings/Phonebook/Books/Select=" << phonebook-1
		<< "&getpage=../html/de/menus/menu2.html"
		<< "&var:lang=de"
		<< "&var:pagename=fonbuch"
		<< "&var:menu=fon"
		<< "&sid=" << sid;


	post2fritz(url.str().c_str(), command.str().c_str(), output);

	line=NULL;
	if((fd = fopen(output.c_str(), "r")))
	{
		while ((read = getline(&line, &len, fd)) != -1)
		{
			char *ptr;
			char buffer[50];

			i++;
			if(debug>1){cout << "rec " << '[' << i << ']' << line;}

			if ((ptr = strstr(line, ">TrFonName("))) {
				sscanf(ptr + 11, "\"%*[^\"]\", \"%[^\"]", (char *) &cpars->address.name);
			}
			else if ((ptr = strstr(line, ">TrFonNr("))) {
				sscanf(ptr + 9, "\"%49[^\"]\", \"%[^\"]", (char *) &buffer,(char *) &cpars->address.number);

				if(!strstr(buffer,"intern")) //no "intern" type
				{
					if(cpars->address.number[0] != '0' && strlen(cpars->getCityprefix()) > 0) {
						sprintf(buffer,"%s%s",cpars->getCityprefix(),cpars->address.number);
						strcpy(cpars->address.number,buffer);
					}

					if (cpars->search_AddrBook(cpars->address.number)) {
						log(1,"[existing]\t%s %s\n",cpars->address.number,cpars->address.name);
					}
					else {
						cpars->add_AddrBook(cpars->address.number);
						log(1,"[add]\t\t%s %s\n",cpars->address.number,cpars->address.name);
					}
				}
			}
			else if (strstr(line, "document.write(TrFon1())")) {
			cpars->init_address();
			}
		}
		fclose(fd);
	}
	if(line)
		free(line);

	return(0);
}

int CConnect::get_phonebooks_LUA(const char *sid, int phonebook)
{
	std::ostringstream url,command, vsid, bookID;
	string output ="/tmp/fim.out";

	ifstream fh;
	string str, line;
	size_t pos;
	size_t begin = 0;

	log(1,"%s()\n", __FUNCTION__);

	// create multipart vector
	vsid << "sid=" << sid;
	bookID << "PhonebookId=" << phonebook;
	multipart.push_back(vsid.str());
	multipart.push_back(bookID.str());
	multipart.push_back("PhonebookExportName=Telefonbuch");
	multipart.push_back("PhonebookExport=");

	//get phonebook
	url.str("");
	url	<< cpars->getFritzAdr() << "/cgi-bin/firmwarecfg";
	post2fritz(url.str().c_str(), "", output);

	// parse output
	fh.open(output.c_str(), std::ios::in);
	if(fh.is_open())
	{
		while (!fh.eof())
		{
			getline(fh, str);

			// get the whole Data in one line
			line += str;
		}
		fh.close();

		// loop search
		bool stop = false;
		do {
			str = "<realName>";
			if((pos=line.find(str, begin)) != string::npos)
			{
				size_t name_ende = line.find("</realName>", pos);
				string tmp = line.substr(pos+str.length(), name_ende - (pos+str.length()));
				strcpy(cpars->address.name, tmp.c_str());
				cout << " name - " << cpars->address.name << endl;
			}

			str = "<number";
			if((pos=line.find(str, begin)) != string::npos)
			{
				str = ">";
				size_t number_start = line.find_first_of(str, pos);
				string tmp = line.substr(pos, number_start - pos);

				size_t number_ende = line.find("</number>", number_start);
				tmp = line.substr(number_start+str.length(), number_ende - (number_start+str.length()));
				strcpy(cpars->address.number, tmp.c_str());
				cout << " number - " << cpars->address.number << endl;
			}

			if(pos == string::npos)
				stop = true;
			else
			{
				//add to AddrBook
				if(strlen(cpars->address.number) != 0)
				{
					if(cpars->address.number[0] != '0' && strlen(cpars->getCityprefix()) > 0) {
						char buffer[50];
						sprintf(buffer,"%s%s",cpars->getCityprefix(),cpars->address.number);
						strcpy(cpars->address.number,buffer);
					}

					if(cpars->search_AddrBook(cpars->address.number)) {
						cout << '[' << BASENAME << "] - [existing]\t";
					}
					else {
						cpars->add_AddrBook(cpars->address.number);
						cout << '[' << BASENAME << "] - [add]\t";
					}
					cout << cpars->address.number << ' ' <<  cpars->address.name << endl;
				}
			}

			begin = pos +1;

		} while (!stop);
	}
/*
	line=NULL;
	if((fd = fopen(output.c_str(), "r")))
	{
		while ((read = getline(&line, &len, fd)) != -1)
		{
			char *ptr;

			cpars->init_address();
			i++;
			if(debug>1){cout << "rec " << '[' << i << ']' << line;}

			if((ptr = strstr(line, "<person><realName>"))) {
				sscanf(ptr + 18, "%[^<]", (char *) &cpars->address.name);
				cout << cpars->address.name << endl;
			}

			if((ptr = strstr(line, "<number type=\"home\" prio=\"1\" id=\"0\">"))) {
				sscanf(ptr + 36, "%[^<]", (char *) &cpars->address.number);
				cout << cpars->address.number << endl;

				//add to AddrBook
				if(strlen(cpars->address.number) != 0)
				{
					if(cpars->address.number[0] != '0' && strlen(cpars->getCityprefix()) > 0) {
						char buffer[50];
						sprintf(buffer,"%s%s",cpars->getCityprefix(),cpars->address.number);
						strcpy(cpars->address.number,buffer);
					}

					if(cpars->search_AddrBook(cpars->address.number)) {
						cout << '[' << BASENAME << "] - [existing]\t";
					}
					else {
						cpars->add_AddrBook(cpars->address.number);
						cout << '[' << BASENAME << "] - [add]\t";
					}
					cout << cpars->address.number << ' ' <<  cpars->address.name << endl;
				}
			}

			
		}
		fclose(fd);
	}
	if(line)
		free(line);
*/
	return(0);
}

int CConnect::dial(const char *sid, int port, const char *number)
{
	std::ostringstream url,command;

	if(query_logic == 3) {
		url	<< cpars->getFritzAdr() << "/fon_num/fonbook_list.lua?"
			<< "dial=" << number
			<< "&orig_port=" << port
			<< "&sid=" << sid;
	}
	else {
		url	<< cpars->getFritzAdr() << "/cgi-bin/webcm";
		command	<< "getpage=../html/de/menus/menu2.html"
			<< "&telcfg:settings/UseClickToDial=1"
			<< "&telcfg:settings/DialPort=" << port
			<< "&telcfg:command/Dial=" << number
			<< "&sid=" << sid;
	}

	log(1,"%s()\n", __FUNCTION__);

	post2fritz(url.str().c_str(), command.str().c_str());

	return(0);
}

int CConnect::hangup(const char *sid, int port)
{
	std::ostringstream url,command;

	url	<< cpars->getFritzAdr() << "/cgi-bin/webcm";
	command	<< "getpage=../html/de/menus/menu2.html"
		<< "&telcfg:settings/UseClickToDial=1"
		<< "&telcfg:settings/DialPort=" << port
		<< "&telcfg:command/Hangup="
		<< "&sid=" << sid;

	log(1,"%s()\n", __FUNCTION__);

	post2fritz(url.str().c_str(), command.str().c_str());

	return(0);
}

int CConnect::reconnect(const char *sid)
{
	std::ostringstream url,command;

	if(query_logic == 3) {
		url	<< cpars->getFritzAdr() << "/internet/inetstat_monitor.lua?sid=" << sid
			<< "&useajax=1&action=disconnect&xhr=1";
	}
	else {
		url	<< cpars->getFritzAdr() << "/cgi-bin/webcm";
	    command	<< "sid=" << sid
			<< "&connection0%3Asettings%2Fcmd_disconnect=";
	}

	log(1,"%s()\n", __FUNCTION__);

	post2fritz(url.str().c_str(), command.str().c_str());

	return(0);
}

/******************************************************************************
 * reverse search
 ******************************************************************************/
int CConnect::rsearch(const char *searchNO)
{
	char *found;
	char *line;
	ssize_t read;
	size_t len;
	ostringstream url;
	string sstr;
	string output ="/tmp/fim.out";
	FILE* fd;

	log(1,"%s()\n", __FUNCTION__);

	cpars->init_address();

	if(searchNO[0] != '0')
		sstr = (std::string) (strlen(cpars->getCityprefix())>0 ? cpars->getCityprefix() : "") + (std::string) searchNO;
	else
		sstr = searchNO;

	url	<< cpars->getSearchAdr() << "/suche/" << sstr << "/-";

	post2fritz(url.str().c_str(),"", output);

	line=NULL;
	if((fd = fopen(output.c_str(), "r")))
	{
		while ((read = getline(&line, &len, fd)) != -1)
		{
			if ((found = strstr(line, "target=\"_self\" title=\"Zur Detailseite von&#160;")))
			{
				sscanf(found + 47, "%255[^\"]", (char *) &cpars->address.name);
			}
			else if ((found = strstr(line, "\"postalCode\" content=\"")))
			{
				sscanf(found + 22, "%5[^\"]", (char *) &cpars->address.code);
			}
			else if((found = strstr(line, "\"addressLocality\" content=\"")))
			{
				sscanf(found + 27, "%127[^\"]", (char *) &cpars->address.locality);
			}
			else if((found = strstr(line, "\"streetAddress\" content=\"")))
			{
				sscanf(found + 25, "%127[^\"]", (char *) &cpars->address.street);
			}
		}
		fclose(fd);
	}
	if(line)
		free(line);

	if(strlen(cpars->address.name)!=0) {
		log(1,"(%s) = %s, %s, %s %s\n",sstr.c_str(), cpars->address.name, cpars->address.street, cpars->address.code, cpars->address.locality);

		return(1);
	}
	else {
		log(0,"no results for %s\n", sstr.c_str());
	}

	return(0);
}

void CConnect::StringReplace(string &str, const string search, const string rstr)
{
	stringstream f(search); // stringstream f("string1;string2;stringX");
	string s;
	while (getline(f, s, ';'))
	{
		string::size_type ptr = 0;
		string::size_type pos = 0;

		while((ptr = str.find(s,pos)) != string::npos)
		{
			str.replace(ptr,s.length(),rstr);
			pos = ptr + rstr.length();
		}
	}
}
