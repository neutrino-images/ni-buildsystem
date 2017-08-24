#include <string.h>

#include <fstream>
#include <iostream>
#include <sstream>
#include <iomanip>
#include <vector>
#include <map>

#include <time.h>

#include <netdb.h>
#include <sys/socket.h>
//#include <arpa/inet.h>
#include <unistd.h>

//#include "md5.h"
#include <openssl/md5.h>

#include "connect.h"
//#include "base64.h"

#define BASENAME "FCM"

#include <curl/curl.h>


class CurledClass
{
  public:

  static int writer(char *data, size_t size, size_t nmemb, string *buffer_in)
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
	//sockfb=0;
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
int CConnect::connect2Host(const char *adr, int port)
{
	//IPv4 or IPv6
	int sockfd, rv;  
	struct addrinfo hints, *servinfo, *p;

	ostringstream s_port;
	s_port << port;
   
	memset(&hints, 0, sizeof hints);
	hints.ai_family		= AF_UNSPEC; // use AF_INET6 to force IPv6
	hints.ai_socktype	= SOCK_STREAM;

	if ((rv = getaddrinfo(adr, s_port.str().c_str(), &hints, &servinfo)) != 0) {
		fprintf(stderr, "[%s] - getaddrinfo: %s\n", BASENAME, gai_strerror(rv));
		return(-1);
	}

	//loop through all the results and connect to the first we can
	for(p = servinfo; p != NULL; p = p->ai_next)
	{
		if (debug)
			printf("[%s] - Try to connect to %s on port %i\n", BASENAME, adr, port);

		if ((sockfd = socket(p->ai_family, p->ai_socktype,p->ai_protocol)) == -1) {
			perror("socket");
			continue;
		}

		if (connect(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
			close(sockfd);
			perror("connect");
			continue;
		}

		break; //if we get here, we must have connected successfully
	}

	if (p == NULL) {
		//looped off the end of the list with no connection
		fprintf(stderr, "[%s] - failed to connect\n", BASENAME);
		return(-1);
	}

	freeaddrinfo(servinfo); //all done with this structure
	return(sockfd);
}

string CConnect::post2fritz(const char* url, int port, const string data, const string curlOutFile)
{
	CURL *curl;
	CURLcode result;

	// Create our curl handle
	curl = curl_easy_init();

	//errors
	char errorBuffer[CURL_ERROR_SIZE];

	// Write all expected data in here
	string buffer;

	if(!curl){
		cerr << "Error init Curl!" << endl;
		return string();
	}

	curl_easy_setopt(curl, CURLOPT_ERRORBUFFER, errorBuffer);
	curl_easy_setopt(curl, CURLOPT_URL, url);
	curl_easy_setopt(curl, CURLOPT_HEADER, 0);
	curl_easy_setopt(curl, CURLOPT_USERAGENT, "Mozilla/5.0");
	curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1);
	curl_easy_setopt(curl, CURLOPT_VERBOSE, debug?1:0);
	curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0);
	curl_easy_setopt(curl, CURLOPT_PORT, port);

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

	if(debug > 1){
		if(curlOutFile.empty())
			cout << "DEBUG-OUT" << ">>" << buffer << "<<" << "DEBUG-OUT END" << endl;
		else
			cout << "DEBUG-OUT" << ">>" << curlOutFile << "<<" << "DEBUG-OUT END" << endl;
	}

	if(result == CURLE_OK)
		return(buffer);

	return string();
}

int CConnect::get2box(const char* host, int port, const char* msg, const char* upwd, const char* msgtype, int msgtimeout)
{
	ostringstream url;

	if(debug) {cout << '[' << BASENAME << "] - " << __FUNCTION__ << "()" << endl;}

	url	<< host << "/control/message?" << msgtype << "=" << msg << "&timeout=" << msgtimeout;

	string s = post2fritz(url.str().c_str(), port);

	return(1);
}

int CConnect::get_challenge()
{
	ostringstream url;

	if(debug) {cout << '[' << BASENAME << "] - " << __FUNCTION__ << "()" << endl;}

	//if(mysockfb <= 0){
	//	printf("[%s] - CConnect::get_challenge(): ERR connect2Host\n", BASENAME);
	//	return 0;
	//}

	//url	<< "/cgi-bin/webcm?getpage=../html/login_sid.xml"; // Firmwareversion xx.04.74
	url	<< FritzAdr << "/login_sid.lua"; // OS 5.50

	string s = post2fritz(url.str().c_str());

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

	printf("[%s] - failed to get CHALLENGE\n", BASENAME);
	return 0;
}

int CConnect::get_md5(const char *challenge, char *fritzPW)
{
	//convert to utf16
	//http://www.avm.de/de/Extern/Technical_Note_Session_ID.pdf
	unsigned int i;
	int y = 0;

	string utf8_str = (string) challenge + "-" + (string) UTF8toISO(fritzPW);
	string utf16_str = ("");

	if(debug > 1)
		printf("[%s] - Challenge-Password = \"%s-%s\"\n",BASENAME, challenge, UTF8toISO(fritzPW));

	if(debug)
		printf("[%s] - Binary for hash = ", BASENAME);

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

	if(debug)
		cout << '[' << BASENAME << "] - MD5 hash = " << md5sum << " (" << strlen((char *)md5sum) << ')' << endl;

	return(strlen((char *)md5sum));
}

int CConnect::get_sid(const char *challenge, const unsigned char *md5)
{
	ostringstream command;

	command	<< "login:command/response="
		<< challenge << '-' << md5
		<< "&getpage=../html/login_sid.xml";

	if(debug) {cout << '[' << BASENAME << "] - " << __FUNCTION__ << "()" << endl;}

	string s = post2fritz(FritzAdr,80, command.str());
	if(debug) {cout << s << endl;}

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

	url << FritzAdr << "/login_sid.lua";

	command	<< "response="
		<< challenge << '-' << md5;

	if(debug) {cout << '[' << BASENAME << "] - " << __FUNCTION__ << "()" << endl;}

	string s = post2fritz(url.str().c_str(),80, command.str());

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
	//'ä','ö','ü','Ä','Ö','Ü','ß'
	const char	iso[7]={'\xe4','\xf6','\xfc','\xc4','\xd6','\xdc','\xdf'}, //ISO-8859-1	ö = 0xf6
			utf[7]={'\xa4','\xb6','\xbc','\x84','\x96','\x9c','\x9f'}; //UTF-8	ö = 0xc3 0xb6

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

int CConnect::ExistFile(const char *fname)
{
FILE *efh;

	if((efh=fopen(fname,"r"))==NULL)
	{
		return(0);
	}
	fclose(efh);
	return(1);
}

int CConnect::TouchFile(const char *fname)
{
FILE *tfh;

	if((tfh=fopen(fname,"w"))==NULL)
	{
		return(0);
	}
	fclose(tfh);
	return(1);
}

string CConnect::timestamp()
{
	ostringstream txt;

	time_t timestamp;
	tm *now;

	timestamp = time(0);
	now = localtime(&timestamp);

	txt	<< '['
		<< setfill('0') << setw (2) << static_cast<int>(now->tm_hour) 
		<< ':' 
		<< setfill('0') << setw (2) << static_cast<int>(now->tm_min) 
		<< ':' 
		<< setfill('0') << setw (2) << static_cast<int>(now->tm_sec)
		<< ']';
  
	return txt.str();
}

void CConnect::get_time(int *wday,int *hour,int *min)
{
	time_t timestamp;
	tm *now;

	timestamp = time(0);
	now = localtime(&timestamp);

	*wday=now->tm_wday;
	*hour=now->tm_hour;
	*min=now->tm_min;
}

int CConnect::my_atoi(const string text)
{
	//atoi c++ way
	int val;
	stringstream s(text);
	s >> val;
	return(val);
}

string CConnect::itoString (int& i)
{
    stringstream temp;
    temp << i;
    return temp.str();
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

string CConnect::parseString(const char* var, string& string_to_serarch)
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
		cout << " no result for " << '"' << var << '"' << res << endl;

	return(res);
}

string CConnect::parseString(string search1, string search2, string str)
{
	string ret, search;
	size_t pos_wildcard, pos_firstline, pos_search1, pos_search2;
	pos_wildcard = pos_firstline = pos_search1 = pos_search2 = string::npos;

	if((pos_wildcard = search1.find('*')) != string::npos)
	{
		search = search1.substr(0, pos_wildcard);
		//cout << "wildcard detected" << '\t' << "= " << search << "[*]" << search1.substr(pos_wildcard+1) << endl;
	}
	else
		search = search1;

	//cout << "search1" << "\t\t\t" << "= " << '"' << search << '"' << endl;
	if((pos_search1 = str.find(search)) != string::npos)
	{
		//cout << "search1 found" << "\t\t" << "= " << '"' << search << '"' << " at pos "<< (int)(pos_search1) << " => " << str << endl;

		pos_search1 += search.length();

		if(pos_wildcard != string::npos)
		{
			size_t pos_wildcard_ext;
			string wildcard_ext = search1.substr(pos_wildcard+1);

			//cout << "wildcard_ext" << "\t\t" << "= " << '"' << wildcard_ext << '"' << endl;
			if((pos_wildcard_ext = str.find(wildcard_ext,pos_wildcard+1)) != string::npos)
			{
				//cout << "wildcard_ext found" << "\t" << "= " << '"' << wildcard_ext << '"' << " at pos "<< (int)(pos_wildcard_ext) << " => " << str << endl;
				pos_search1 = pos_wildcard_ext + wildcard_ext.length();
			}
			else
			{
				//cout << "wildcard_ext not found in line " << acc << " - exit" << endl;
				return("");
			}
		}
	}
	else
	{
		//cout << "search1 not found in line " << acc << " - exit" << endl;
		return("");
	}

	if(pos_search1 != string::npos)
	{
		//cout << "search2 " << "\t\t" << "= " << '"' << search2 << '"' << endl;

		if(search2 == "\n")
		{
			ret = str.substr(pos_search1, str.length() - pos_search1);
			return(ret);
		}

		if((pos_search2 = str.find(search2, pos_search1)) != string::npos)
		{
			if(search2.empty())
				pos_search2 = str.length();

			//cout << "search2" << "\t\t\t" << "= " << '"' << search2 << '"' << " found at "<< (int)(pos_search2) << " => " << str << endl;
			ret = str.substr(pos_search1, pos_search2 - pos_search1);
		}
		//else
			//cout << "search2 not found in line " << acc << " - exit" << endl;

	}

	return(ret);
}
#if 0
/******************************************************************************
 * get login to Fritz!Box
 ******************************************************************************/
#endif
int CConnect::get_login(const char* fritzPW)
{
	if (!get_challenge()) {
		printf("[%s] - ERROR get Challenge\n",  BASENAME);
		return(0);
	}

	get_md5(challenge,(char*)fritzPW);

	if(!get_sid_LUA(challenge,md5sum)) //after 5.5x
	{
		printf("[%s] - login_sid.lua not found\n",  BASENAME);
		if(!get_sid(challenge,md5sum)) //before 5.5x
		{
			printf("[%s] - ERROR get SID\n",  BASENAME);
			return 0;
		}
	}
	return(1);
}
#if 0
/******************************************************************************
 * send logout to Fritz!Box
 ******************************************************************************/
#endif
int CConnect::send_logout(const char *sid)
{
	ostringstream url, command;

	url	<< FritzAdr << "/cgi-bin/webcm";
	command	<< "sid=" << sid
		<< "&security:command/logout=&getpage=../html/confirm_logout.htlm";

	if(debug) {cout << '[' << BASENAME << "] - " << __FUNCTION__ << "()" << endl;}

	//(w_fritz, "GET /home/home.lua?sid=%s&logout=1 HTTP/1.1\r\nHost: 192.168.99.254\r\n\r\n", sid);

	string s = post2fritz(url.str().c_str(),80, command.str().c_str());

	return(1);
}
#if 0
/******************************************************************************
 * send query's to Fritz!Box
 ******************************************************************************/
#endif
int CConnect::send_refresh(const char *sid)
{
	ostringstream url, command;

	url	<< FritzAdr << "/cgi-bin/webcm";
	command << "getpage=../html/query.txt"
		<< "&var:n[0]=telcfg:settings/RefreshJournal"
		<< "&var:n[1]=telcfg:settings/Journal/count"
		<< "&sid=" << sid;

	if(debug) {cout << '[' << BASENAME << "] - " << __FUNCTION__ << "()" << endl;}

	string s = post2fritz(url.str().c_str(),80, command.str().c_str());;

	return(0);
}


void CConnect::parseXML(const string text)
{
	device d;
	int tag=0, val=0;
	string tagname, value;
	char* t= (char*) text.c_str();

	d.tist		= -1;
	d.tsoll		= -1;
	d.absenk	= -1;
	d.komfort	= -1;

	while (*t!=0)
	{
		if(*t=='<')
		{
			tag=1;
			val=0;
			if(!value.empty())
			{
				if(tagname=="name")	d.name		= value;
				if(tagname=="mode")	d.mode		= value;
				if(tagname=="present")	d.present	= my_atoi(value);
				if(tagname=="state")	d.state		= my_atoi(value);
				if(tagname=="lock")	d.lock		= my_atoi(value);
				if(tagname=="power")	d.power		= my_atoi(value);
				if(tagname=="energy")	d.energy	= my_atoi(value);
				if(tagname=="celsius")	d.celsius	= my_atoi(value);
				if(tagname=="offset")	d.offset	= my_atoi(value);
				if(tagname=="tist")	d.tist		= my_atoi(value);
				if(tagname=="tsoll")	d.tsoll		= my_atoi(value);
				if(tagname=="absenk")	d.absenk	= my_atoi(value);
				if(tagname=="komfort")	d.komfort	= my_atoi(value);
			}
			value="";
			tagname="";
		}

		if(*t!='>' && *t!='<')
		{
			if(tag==1)
				tagname += *t;

			if(val==1)
				value += *t;
		}

		if(*t=='>')
		{
			tag=0;
			val=1;
			if(strstr(tagname.c_str(),"identifier="))
			{
				string s = parseString("identifier=\"","\"",tagname);
				StringReplace(s," ","");
				d.identifier = s;
			}
			if(strstr(tagname.c_str(),"productname="))
			{
				string s = parseString("productname=\"","\"",tagname);
				StringReplace(s," ","");
				d.productname = s;
			}

			if(!strcmp(tagname.c_str(),"/device") || !strcmp(tagname.c_str(),"/group"))
				devices.push_back(d);
		}

		t++;
	}
}

void CConnect::send2actor(const unsigned int& inx, int& t_soll)
{
	int state_soll = -1;
	int temperature = 0;

	if(devices[inx].productname=="FRITZ!DECT200")
	{
		cout << '[' << BASENAME << "]\t\tTemperature: Plan(" << t_soll << ")/Now(" << devices[inx].celsius << "); state: " << (devices[inx].state == 1 ? "ON":"OFF") << endl;

		// convert special temperature
		switch(t_soll) {
			case 1: state_soll = 1; // switch on
				break;
			case 0: state_soll = 0; // switch off
				break;
		}

		if(state_soll == -1) {
			if(t_soll <= devices[inx].celsius)
			{	//temperature okay
				cout << '[' << BASENAME << "]\t\tTemperature okay"<< endl;
				state_soll = 0;
			}
			else if(t_soll > devices[inx].celsius)
			{	//temperature to low
				cout << '[' << BASENAME << "]\t\tTemperature to low"<< endl;
				state_soll = 1;
			}
		}

		if(state_soll >= 0 && state_soll != devices[inx].state)
		{
			cout << '[' << BASENAME << "]\t\t" << "\033[0;32m" << "sending Deviceswitch "<<(state_soll ==  0? "OFF":"ON") << "\033[0m" << endl;

			if(state_soll == 0)
				smartHome(sid, "setswitchoff", devices[inx].identifier);
			else
				smartHome(sid, "setswitchon", devices[inx].identifier);
		}
		else
			cout << '[' << BASENAME << "]\t\t" << "\033[0;31m" << "send nothing to actor, state is equal" << "\033[0m" << endl;

		// set flagfile
		string flag="/var/etc/.device_" + devices[inx].identifier;
		setFlag(flag.c_str(),state_soll);
	}
	else if(devices[inx].productname=="CometDECT" || devices[inx].productname=="FRITZ!DECT300")
	{
		cout << '[' << BASENAME << "]\t\tTemperature: Plan " << t_soll << " (" << (t_soll > 1 ? t_soll * 0.2 : t_soll) << "), tist(" << devices[inx].tist << "); tsoll(" << devices[inx].tsoll << ')' << endl;

		// convert temperature
		switch(t_soll) {
			case -1: temperature = -1;	// do nothing
				 break;
			case  0: temperature = 253;	// switch off
				 break;
			default: temperature = t_soll * 0.2; // temperature step up to 0.5°, 43 = 21,5°
				 break;
		}

		if(devices[inx].tsoll != temperature) // check if plan temperature stored in actor
		{
			if(temperature == -1)
				cout << '[' << BASENAME << "]\t\t" << "\033[0;31m" << "send nothing to actor while Plan value is (-1)" << "\033[0m" << endl;
			else {
				cout << '[' << BASENAME << "]\t\t" << "\033[0;32m" << "send new tsoll temperature (" << temperature << ") to actor" << "\033[0m" << endl;

				string command = "sethkrtsoll&param=" + itoString(temperature);
				smartHome(sid, command.c_str(), devices[inx].identifier);
			}
		}
		else
			cout << '[' << BASENAME << "]\t\t" << "\033[0;31m" << "send nothing to actor, storred tsoll temperature is equal" << "\033[0m" << endl;
	}
	else
        cout << '[' << BASENAME << "]\t\t" << "\033[0;32m" << "productname \"" << devices[inx].productname << "\" not found" << "\033[0m" << endl;
}

int CConnect::checkdevice(map<string, vector<string> >& w, map<string, vector<string> >& t)
{
	int wday,hour,min,ret=-1;

	get_time(&wday,&hour,&min);

	// for building device index
	unsigned int dev_inx = 0;

	for(vector<device>::iterator dev = devices.begin(); dev != devices.end(); ++dev, ++dev_inx)
	{
		// find cdw map key by device id
		map<string, vector<string> >::iterator dev_search = w.find((*dev).identifier);
		if(dev_search != w.end())
		{
			// check config table syntax
			if(dev_search->second.size() != 7) {
				cout << "[ERROR] - " << __FUNCTION__ <<  "(): WP table syntax error, we must have 7 values per line\n";
				return(ret);
			}

			// get map value for weekday
			string w_value = dev_search->second[wday];
			cout << '[' << BASENAME << "] - " << __FUNCTION__ << "(): device[" << (*dev).identifier << "] weekday = " << wday << ", value = " << w_value << ", name = " << (*dev).name << endl;

			// find cdt map key by cdw value
			map<string, vector<string> >::iterator search = t.find(w_value);
			if(search != t.end())
			{
				// check config table syntax
				if( search->second.size() % 3 != 0 ) { // 3 because HH MM are 2 values
					cout << '[' << BASENAME << "] - " << __FUNCTION__ <<  "(): DP table syntax error, we must have time and temperature pair (HH:MM,TTT)\n";
					return(ret);
				}

				// read every time and temperature pair for cdt key
				for (unsigned int i=0; i <search->second.size(); ++i)
				{
					// check time and temperature after reading 3 values (1=HH, 2=MM, 3=temperature)
					unsigned int delim = 3;
					if( (i+1) % delim == 0)
					{
						int now = hour *60 + min;
						int ev = my_atoi(search->second[i-2]) * 60 + my_atoi(search->second[i-1]);
						int next_ev = ev;
						int temperature = my_atoi(search->second[i]);

						// check for existing next time event
						if( i+1 != search->second.size() )
							next_ev = my_atoi(search->second[i+1]) * 60  + my_atoi(search->second[i+2]);

						if((now >= ev && now <= next_ev) ||
							(i+1 == search->second.size()))	// last event was earlier than now 
						{
							// time event
							cout << '[' << BASENAME << "]\t\tTime event = " << ev/60.0 << " temperature = " << temperature << endl;

							send2actor(dev_inx, temperature);
							break;
						}
					}
				}
			}
			else
				cout << '[' << BASENAME << "]\t\tvalue not found in DP map" << endl;
		}
		else
			cout << '[' << BASENAME << "] - " << __FUNCTION__ << ": device[" << (*dev).identifier << "] not found in table WP" << endl;
	}

	return(ret);
}

int CConnect::inTime(int index, vector<vector<string> >& week, vector<vector<string> >& day)
{
	int wday,hour,min,ret=-1;

	get_time(&wday,&hour,&min);
	int pos = my_atoi(week[index][wday]);

	cout<<'['<<BASENAME<<"] - "<< __FUNCTION__<< "() "<<"device index="<<index<<" wday="<<wday<<" hour="<<hour<<" min="<<min<<"; Weekplan ("<<pos<<") = ";

	if(pos != 0)
	{
		pos--;
/*
		for (unsigned int i=0; i<day[pos].size(); ++i)
		{
			cout << day[pos][i] << ' ';
		}
		cout<<endl;
*/
		for (unsigned int i=0; i<day[pos].size(); ++i)
		{
			if(i % 4 == 0)
			{
				int now = hour *60 + min;
				int from = my_atoi(day[pos][i]) *60 + my_atoi(day[pos][i+1]);
				int to = my_atoi(day[pos][i+2]) *60 + my_atoi(day[pos][i+3]);

				if(now >= from && now <= to)
				{
					cout<< day[pos][i]<<":"<<day[pos][i+1]<<"-"<<day[pos][i+2]<<":"<< day[pos][i+3]<<endl;
					return(1);
				}
				cout<< day[pos][i]<<":"<<day[pos][i+1]<<"-"<<day[pos][i+2]<<":"<< day[pos][i+3]<<' ';
			}
		}
		cout<<endl;
		ret=0;
	}
	return(ret);
}

int CConnect::smartHome(const char *sid, const char *command, const string ain)
{
	ostringstream url;

	int ret=-1;

	if(debug) {cout << '[' << BASENAME << "] - " << __FUNCTION__ << "()" << endl;}

	url	<< FritzAdr << "/webservices/homeautoswitch.lua?switchcmd=" << command << (ain.empty()?"":"&ain=") << ain << "&sid=" << sid;

	string s = post2fritz(url.str().c_str());

	if(!strcmp(command,"getdevicelistinfos"))
	{
		//s = "<devicelist version=\"1\"><device identifier=\"08761 0831319\" id=\"16\" functionbitmask=\"1280\" fwversion=\"03.36\" manufacturer=\"AVM\" productname=\"FRITZ!DECT Repeater 100\"><present>1</present><name>Fritz!Dect Rep 100</name><temperature><celsius>200</celsius><offset>-24</offset></temperature></device><device identifier=\"08761 0021731\" id=\"17\" functionbitmask=\"896\" fwversion=\"03.36\" manufacturer=\"AVM\" productname=\"FRITZ!DECT 200\"><present>1</present><name>WZ Stehlampe</name><switch><state>0</state><mode>manuell</mode><lock>0</lock></switch><powermeter><power>0</power><energy>4282</energy></powermeter><temperature><celsius>190</celsius><offset>-27</offset></temperature></device><device identifier=\"08761 0068302\" id=\"18\" functionbitmask=\"896\" fwversion=\"03.36\" manufacturer=\"AVM\" productname=\"FRITZ!DECT 200\"><present>1</present><name>WZ Freiheitsstatue</name><switch><state>0</state><mode>auto</mode><lock>0</lock></switch><powermeter><power>0</power><energy>2167</energy></powermeter><temperature><celsius>190</celsius><offset>-17</offset></temperature></device><device identifier=\"08761 0069718\" id=\"19\" functionbitmask=\"896\" fwversion=\"03.36\" manufacturer=\"AVM\" productname=\"FRITZ!DECT 200\"><present>0</present><name>Bananen-Haus</name><switch><state></state><mode></mode><lock></lock></switch><powermeter><power></power><energy></energy></powermeter><temperature><celsius></celsius><offset></offset></temperature></device><device identifier=\"08761 0021736\" id=\"20\" functionbitmask=\"896\" fwversion=\"03.36\" manufacturer=\"AVM\" productname=\"FRITZ!DECT 200\"><present>1</present><name>RaspiServer</name><switch><state>1</state><mode>manuell</mode><lock>0</lock></switch><powermeter><power>4360</power><energy>53683</energy></powermeter><temperature><celsius>210</celsius><offset>-35</offset></temperature></device><device identifier=\"08761 0068647\" id=\"21\" functionbitmask=\"896\" fwversion=\"03.36\" manufacturer=\"AVM\" productname=\"FRITZ!DECT 200\"><present>1</present><name>Wohnmobil</name><switch><state>0</state><mode>manuell</mode><lock>0</lock></switch><powermeter><power>0</power><energy>12620</energy></powermeter><temperature><celsius>136</celsius><offset>-25</offset></temperature></device><group identifier=\"86:6D:75-900\" id=\"900\" functionbitmask=\"512\" fwversion=\"1.0\" manufacturer=\"AVM\" productname=\"\"><present>1</present><name>Testgruppe</name><switch><state>0</state><mode>manuell</mode><lock></lock></switch><groupinfo><masterdeviceid>0</masterdeviceid><members>17,21</members></groupinfo></group></devicelist>";
		parseXML(s);

		//cout 	<<"identifier;present;name;state;mode;lock;power;energy;celsius;offset;" <<endl;

		unsigned int x=0;
		for(vector<device>::iterator it = devices.begin(); it != devices.end(); ++it, ++x)
		{
			if(!ain.empty())
			{
				if((*it).identifier==ain)
				{
					cout<<'['<<BASENAME<<"] - " <<(*it).productname	<< ": "
					<<(*it).identifier	<< ';'<<(*it).present	<< ';'<<(*it).name	<< ';'<<(*it).state	<< ';'<<(*it).mode	<< ';'
					<<(*it).lock		<< ';'<<(*it).power	<< ';'<<(*it).energy	<< ';'<<(*it).celsius	<< ';'<<(*it).offset	<< ';'
					<<(*it).tist		<< ';'<<(*it).tsoll	<< ';'<<(*it).absenk	<< ';'<<(*it).komfort	<< ';'<<endl;
					return (x);
				}
			}
			else 
			{
				cout<<'['<<BASENAME<<"] - " <<(*it).productname	<< ": "
				<<(*it).identifier	<< ';'<<(*it).present	<< ';'<<(*it).name	<< ';'<<(*it).state	<< ';'<<(*it).mode	<< ';'
				<<(*it).lock		<< ';'<<(*it).power	<< ';'<<(*it).energy	<< ';'<<(*it).celsius	<< ';'<<(*it).offset	<< ';'
				<<(*it).tist		<< ';'<<(*it).tsoll	<< ';'<<(*it).absenk	<< ';'<<(*it).komfort	<< ';'<<endl;
			}
		}
	}

	return (ret);
}

#if 0
/******************************************************************************
 * FritzCallMonitor
 ******************************************************************************/
#endif
//new query
int CConnect::send_TAMquery(const char *flag, const char *sid, const char *searchstr)
{
	ostringstream url;

	if(debug) {cout << '[' << BASENAME << "] - " << __FUNCTION__ << "()" << endl;}

	url	<< FritzAdr << "/query.lua?sid=" << sid << searchstr;

	string s = post2fritz(url.str().c_str());
	StringReplace(s," ","");
	string res = parseString("var", s);

	if(!res.empty())
	{
		setFlag(flag,my_atoi(res));
	}
	else {
		printf("[%s] - %s ERROR\n", BASENAME, timestamp().c_str());
		return 1;
	}

	return 0;
}

void CConnect::setFlag(const char *flag, const int& i)
{
	if(i==0)
	{
		cout << '[' << BASENAME << ']' << " - " << timestamp() << " disable flag "<<flag<<endl;
		remove(flag);
	}
	else {
		cout << '[' << BASENAME << ']' << " - " << timestamp() << " enable flag "<<flag<<endl;
		if(!TouchFile(flag))
			cout << "ERROR  writing flag " << flag << endl;
	}
}

#if 0
//old query

int CConnect::send_query(const char *flag, const char *sid, const char *searchstr)
{
	ostringstream command;
	int i=0;
	char *line;
	ssize_t read;
	size_t len;

	command	<< "getpage=../html/query.txt"
		<< searchstr
		<< "&sid=" << sid;

	if(debug) {cout << '[' << BASENAME << "] - " << __FUNCTION__ << "()" << endl;}

	post2fritz(command.str().c_str());

	line=NULL;
	while ((read = getline(&line, &len, r_fritz)) != -1)
	{
		i++;
		if(debug>1)
			printf("line[%d]: %s", i, line);

		if(i==7)
		{
			if(strlen(line)>10) {
				printf("ERROR\n");
				break;
			}
			else if(atoi(trim(line))==0) {
				printf("res=%s =>disable flag\n",trim(line));
				remove(flag);
				break;
			}
			else {
				printf("res=%s =>enable flag\n",trim(line));
				if(!TouchFile(flag))
					printf("ERROR writing flag %s\n",flag);
				break;
			}
		}
	}
	if(line)
		free(line);

	quitfritz();
	return(0);
}
#endif

int CConnect::get_callerlist(const char *sid, const char *file)
{
	ostringstream url, command;

	if(debug) {cout << '[' << BASENAME << "] - " << __FUNCTION__ << "()" << endl;}

	url	<< FritzAdr << "/fon_num/foncalls_list.lua?csv=";
	command	<< "refresh=&sid=" << sid;

	string s = post2fritz(url.str().c_str(),80, command.str().c_str(), file);

	return(0);
}
