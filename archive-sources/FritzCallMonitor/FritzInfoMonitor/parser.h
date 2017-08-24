
#ifndef __parser_h__
#define __parser_h__

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <string>
#include <vector>

using namespace std;

class CParser
{
	public:
		CParser();
		virtual~CParser();
		static CParser* getInstance();

		int 		ReadConfig(const char *fname);
		unsigned short	Percentconverter (unsigned short percent);
		void		read_neutrino_osd_conf(int *ex,int *sx,int *ey, int *sy, const char *filename);
		int		ReadColors (const char *filename);
		int		search_AddrBook(const char *caller);
		int		add_AddrBook(const char *caller);
		void		init_caller();
		void		init_address();
		string		parseString(const char* var, std::string& string_to_serarch);

		unsigned char	bgra[24][5];

		typedef struct {
			char	number[64];
			char	name[256];
			char	street[128];
			char	code[6];
			char	locality[128];
		} S_ADDRESS;
		S_ADDRESS address;

#define MAXCALLER 12
		typedef struct {
			char call_type[2];
			char call_date[20];
			char call_name[256];
			char call_numr[64];
			char call_time[6];
			char port_rout[20];
			char port_name[30];
		} S_CALLER;
		S_CALLER caller[MAXCALLER];

#define MAXDAILPORTS 8
		typedef struct s_dialport {
			char port_name[30];
			int port;
		} struct_dialport;
		struct_dialport dialport[MAXDAILPORTS];

		virtual void	setTam0_active(const std::string& Tam0_active){tam0_active = Tam0_active;};
		virtual void	setTam0_NumNewMessages(const std::string& Tam0_NumNewMessages){tam0_NumNewMessages = Tam0_NumNewMessages;};
		virtual void	setDdns_state(const std::string& Ddns_state){ddns_state = Ddns_state;};
		virtual void	setDdns_domain(const std::string& Ddns_domain){ddns_domain = Ddns_domain;};
		virtual void	setNspver(const std::string& Nspver){nspver = Nspver;};
		virtual void	setSip0Nr(const std::string& Sip0Nr){sip0nr = Sip0Nr;};
		virtual void	setSip1Nr(const std::string& Sip1Nr){sip1nr = Sip1Nr;};
		virtual void	setPppoe_ip(const std::string& Pppoe_ip){pppoe_ip = Pppoe_ip;};

		virtual string	getTam0_active(){return tam0_active;};
		virtual string	getTam0_NumNewMessages(){return tam0_NumNewMessages;};
		virtual string	getDdns_state(){return ddns_state;};
		virtual string	getDdns_domain(){return ddns_domain;};
		virtual string	getNspver(){return nspver;};
		virtual string	getSip0Nr(){return sip0nr;};
		virtual string	getSip1Nr(){return sip1nr;};
		virtual string	getPppoe_ip(){return pppoe_ip;};

		virtual int	getDebug(){return debug;};
		virtual int	getFritzPort(){return FritzWebPort;};
		virtual int	getSearchPort(){return SearchPort;};
		virtual const char* getFritzAdr(){return FritzAdr;};
		virtual const char* getFritzPW(){return FritzPW;};
		virtual const char* getSearchAdr(){return SearchAdr;};
		virtual const char* getCityprefix(){return cityprefix;};
		virtual const char* getDialprefix(){return dialprefix;};
		virtual const char* getListfile(){return listfile;};
		virtual const char* getListstr(){return liststr;};
		virtual const char* getAddressbook(){return addressbook;};

		//virtual void setNspver(const char* nspver);
		//virtual const char* getNspver(){return nspver;};

	protected:
		string	tam0_active;
		string	tam0_NumNewMessages;
		string	ddns_state;
		string	ddns_domain;
		string	nspver;
		string	sip0nr;
		string	sip1nr;
		string	pppoe_ip;

		int	debug;
		int	FritzPort, FritzWebPort,SearchPort;
		char	FritzAdr[64];
		char	FritzPW[64];
		char	SearchAdr[20];
		char	cityprefix[10];
		char	dialprefix[20];
		char	listfile[128];
		char	liststr[128];
		char	addressbook[128];

		enum {mBLUE, mGREEN,  mRED, mALPHA};
		unsigned short cmh[4];	// Titelzeile		- menu_Head(SKIN0)
		unsigned short cmht[4];	// Titeltextfarbe	- menu_Head_Text(ORANGE)
		unsigned short cmc[4];	// Hintergrundfarbe	- menu_Content(SKIN1)
		unsigned short cmct[4];	// Body Textfarbe	- menu_Content_Text(WHITE)
};

#endif //__parser_h__
