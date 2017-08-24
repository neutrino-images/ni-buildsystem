
#ifndef __connect_h__
#define __connect_h__

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

class CConnect
{
	public:
		CConnect();
		~CConnect();
		static CConnect* getInstance();

		int	connect2Host(const char *adr, int port);
		int	get2box(const char* host, int port, const char* msg, const char* upwd);
		int	get_login(const char* fritzPW);
		int	get_callerlist(const char *sid, const char *file);
		int	get_phonebooks(const char *sid, int phonebook);
		int	get_phonebooks_LUA(const char *sid, int phonebook);
		int	send_refresh(const char *sid);
		int	send_logout(const char *sid);
		int	send_query(const char* flag, const char *sid, const char *searchstr);
		int	send_query_caller(const char *sid, int s, int max);
		int	send_query_info(const char *sid);
		int	rsearch(const char *searchNO);
		int 	dial(const char *sid, int port, const char *number);
		int	reconnect(const char *sid);
		int 	hangup(const char *sid, int port);
		char	*trim(char *txt);
		char	*UTF8toISO(char *txt);
		void	log(const int& dlevel, const char *ftxt,...);
        void	StringReplace(string &str, const string search, const string rstr);

		std::string	query2fritz(const char* command);

		virtual int	getQueryLogic(){return query_logic;};
		virtual void	setDebug(const int Debug){debug = Debug;};
		virtual const char* getSid(){return sid;};

	private:
		CParser *	cpars;

		FILE 	*r_fritz;
		FILE	*w_fritz;
		int	sockfb;
		int	debug;
		int	query_logic;
		int	loginLUA;
		char	sid[20];
		char	challenge[20];
		vector<string> multipart;

		string	timestamp();
		string	basename;
		unsigned char	digest[16];
		unsigned char	md5sum[33];

		int	connect2fritz();
		int	quitfritz();
		int	get_challenge(bool lua = true);
		int	get_md5(const char *challenge, char *fritzPW);
		int	get_sid(const char *challenge, const unsigned char *md5);
		int	get_sid_LUA(const char *challenge, const unsigned char *md5);
		int	get_caller_LUA(const char *sid, int s, int max);
		int	get_challenge(const char* host, int port,const char* fritzPW);
		std::string	post2fritz(const char* url, const std::string data, const std::string curlOutFile = "");
		int	get_OLDquery_logic(const char *sid, int logic);

		///get Infos from FB with query.lua
		int	get_QueryInfos(const char *sid);

		//FritzInfoMonitor
		//Firmware < xx.04.74 without SID
		int	send_old_login(const char *fritzPW);

		int	ExistFile(const char *fname);
		int	TouchFile(const char *fname);

//FIXME		void 	init_caller();
//FIXME		void	init_address();
		
		///query syntax
		int	get_query_logic(const char *sid, int logic);
		void	get_query_version(const char *sid);
};

#endif //__connect_h__
