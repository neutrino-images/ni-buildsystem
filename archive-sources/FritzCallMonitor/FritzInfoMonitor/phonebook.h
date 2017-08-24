
#ifndef __phonebook_h__
#define __phonebook_h__

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <vector>
using namespace std;

class CPhoneBook
{
	public:
		CPhoneBook();
		~CPhoneBook();
		static	CPhoneBook* getInstance();

		void	run();

	private:
		CConnect * cconnect;
		CParser  * cpars;
		Cfb	 * cfb;
		Crc 	 * crc;

		struct S_ADDRESS {
			string	number;
			string	name;
			string	street;
			string	code;
			string	locality;
		};

		vector<S_ADDRESS> content;

		static bool	sortByKey(const S_ADDRESS& a, const S_ADDRESS& b);
		static void	toUpper(string& s);

		void	menu();
		void	dialMenu();
		int	getData(const char *fname, const char *list);
		int	getSites(int items);
		int	selList, selData, lastData;
		int	perpage;

	friend ostream& operator<< (ostream& out, const S_ADDRESS& d);
};

#endif //__phonebook_h__