
#ifndef __connect_h__
#define __connect_h__

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

using namespace std;

class CConnect
{
	public:
		CConnect();
		~CConnect();
		static CConnect* getInstance();

		struct device {
			string	identifier;
			string	productname;
			string	name;
			string	mode;
			int	present;
			int	state;
			int	lock;
			int	power;
			int	energy;
			int	celsius;
			int	offset;
			int	tist;
			int	tsoll;
			int	absenk;
			int	komfort;
		};

		vector<device> devices;

		int	connect2Host(const char *adr, int port);
		int	get2box(const char* host, int port, const char* msg, const char* upwd, const char* msgtype, int msgtimeout);
		int	get_login(const char* fritzPW);
		int	send_refresh(const char *sid);
		int	get_callerlist(const char *sid, const char *file);
		int	send_logout(const char *sid);
		int	send_TAMquery(const char* flag, const char *sid, const char *searchstr);
		int	my_atoi(const std::string text);
		string	itoString (int& i);
		int	smartHome(const char *sid, const char *command, const std::string ain = "");
		void	get_time(int *wday,int *hour,int *min);	
		void	parseXML(const string text);
		void	StringReplace(string &str, const string search, const string rstr);
		int	inTime(int index, vector<vector<string> >& week, vector<vector<string> >& day);
		// this is the "old" way for FRITZ!DECT
		void	checkdevice(vector<string>& dectid, vector<int>& temp, vector< vector<string> >& week, vector< vector<string> >& day);
		// check Comet DECT device
		int	checkdevice(map<string, vector<string> >& w, map<string, vector<string> >& t);
		virtual void	cleardevice(){ devices.clear(); };

		string	timestamp();
		string	query2fritz(const char* command);
		string	parseString(const char* var, string& string_to_serarch);
		string	parseString(string search1, string search2, string str);
		string	post2fritz(const char* url, int port = 80, const string data = "", const string curlOutFile = "");

		virtual void	setDebug(const int Debug){debug = Debug;};
		virtual const char* getSid(){return sid;};
		virtual void setFritzAdr(const char* Adr){FritzAdr = Adr;};
		virtual void setFritzPort(const int Port){FritzWebPort = Port;};

	private:
		FILE 	*r_fritz;
		FILE	*w_fritz;
		//int	sockfb;
		int	debug;
		char	challenge[20];
		char	sid[20];
		int	FritzWebPort;
		const char* FritzAdr;

		unsigned char	digest[16];
		unsigned char	md5sum[33];

		int	get_challenge();
		int	get_md5(const char *challenge, char *FritzPW);
		int	get_sid(const char *challenge, const unsigned char *md5);
		int	get_sid_LUA(const char *challenge, const unsigned char *md5);
		int	get_challenge(const char* host, int port,const char* fritzPW);
		void	setFlag(const char *flag, const int& i);
		// send command to DECT actor
		void	send2actor(const unsigned int& inx, int& t_soll);

		char	*trim(char *txt);
		char	*UTF8toISO(char *txt);
		int	ExistFile(const char *fname);
		int	TouchFile(const char *fname);
};

#endif //__connect_h__
