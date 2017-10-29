#include <fstream>
#include <sstream>
#include <iostream>
#include <string>
#include <map>

#include <ctime>
#include <iomanip> //setfill

#include <unistd.h>
#include <cstdlib>
#include <sys/stat.h>

using namespace std;

#define BASNAME "[emmrd] - "

static std::map<std::string, std::string> cam_conf;
static int num_reader;

class emmrd
{

private:

static void timestamp()
{
	time_t t = time(0); // get time now
	struct tm * now = localtime( & t );

	cout << BASNAME
	<<  setfill('0') << setw (2) << now->tm_mday << '.'
	<<  setfill('0') << setw (2) << (now->tm_mon + 1) << '.'
	<< (now->tm_year + 1900) << ' '
	<<  setfill('0') << setw (2) << now->tm_hour << ':'
	<<  setfill('0') << setw (2) << now->tm_min << ':'
	<<  setfill('0') << setw (2) << now->tm_sec;
}

static int read_conf(const string file)
{
	fstream fh;
	string s, key, value;
	num_reader	= -1;
	bool reader	= false;

	// delete map
	cam_conf.clear();

	fh.open(file.c_str(), ios::in);

	if(!fh.is_open())
	{
		cout << BASNAME << "Error reading configfile \"" << file << "\"" << endl;
		return 1;
	}

	while (!fh.eof())
	{
		getline(fh, s);

		string::size_type begin = s.find_first_not_of(" \f\t\v");

		// skip blank lines
		if (begin == string::npos)
			continue;

		// skip commentary
		if (string("#;").find(s[begin]) != string::npos)
			continue;

		// extract the key value
		string::size_type end = s.find('=', begin);
		key = s.substr(begin, end - begin);

		// get reader section
		if (string("[").find(s[begin]) != string::npos)
		{
			if(key == "[reader]")
			{
				reader = true;
				num_reader++;
				continue;
			}
			else
			{
				reader = false;
				continue;
			}
		}

		// trim key
		key.erase( key.find_last_not_of(" \f\t\v") + 1);

		// skip blank keys
		if (key.empty())
			continue;

		// extract and trim value
		begin = s.find_first_not_of(" \f\n\r\t\v", end + 1);
		end   = s.find_last_not_of(" \f\n\r\t\v") + 1;

		value = s.substr(begin, end - begin);

		// create index for reader
		ostringstream inx;
		if(reader == true)
			inx << num_reader << '.' << key;
		else
			inx << key;

		//cout << inx.str() << " = " << value << endl;
		cam_conf[inx.str()]=value;
	}
	fh.close();

	return 0;
}

static string read_lastline(const string file, int pos = 0)
{
	fstream fh;
	string s, last, data;

	fh.open(file.c_str(), ios::in);

	if(fh.is_open())
	{
		while (getline (fh, s))
		{
			last.swap (s);
		}

		if (fh.good () || fh.eof ())
		{
			data = last.substr (pos);
			//cout << '"' << data << '"' << endl;
		} else
		{
			cout << BASNAME << "Error reading file \"" << file << "\"" << endl;

		}

		fh.close();
	}
	else
	{
		//cout << "Error opening file \"" << file << "\"" << endl;
	}
	return data;
}

static int write(const string file, const string &data)
{
	fstream fh;

	fh.open(file.c_str(), ios::out);

	if(fh.is_open())
	{
		fh << data;
		fh.close();
	}
	else
	{
		cout << BASNAME << "error opening file \"" << file << "\"" << endl;
	}

	return 0;
}

static bool file_exists(const char *filename)
{
	struct stat stat_buf;
	if(::stat(filename, &stat_buf) == 0)
	{
		return true;
	}
	return false;
}

public:

static int run(const char *iFile, const char *oFile)
{
	string logpath;

	emmrd::timestamp();

	if(!file_exists(iFile))
	{
		cout <<  " - error find configfile " << iFile << endl;
		exit(0);
	}

	read_conf(iFile);

	// find parameter "emmlogdir" in config
	if(cam_conf.find("emmlogdir") != cam_conf.end())
	{
		//cout << "find emmlogdir => " << cam_conf.find("emmlogdir")->second << endl;
		logpath = cam_conf.find("emmlogdir")->second;

		if (string("/").find(logpath[logpath.size()-1]) == string::npos)
		{
			logpath += "/";
		}
	}
	else
	{
		cam_conf["emmlogdir"]="";
	}

	// check emmlogfile for each reader
	cout <<  " - check emmlogfile for each reader" << endl;
	for (int i = 0; i <= num_reader; ++i)
	{
		string emmdata, lastdata;
		ostringstream label;

		// index for each reader
		label << i << '.' << "label";

		if(cam_conf.find(label.str()) != cam_conf.end())
		{
			// label_emm.log
			string filename = cam_conf.find(label.str())->second + "_emm.log";
			// logpath/label.log
			string t_emmfile = logpath + filename;
			// .label_emm.log
			string t_filename = "/var/etc/." + filename;

			// last run data
			lastdata = read_lastline(t_filename);
			// last entry from logfile without date/time
			emmdata = read_lastline(t_emmfile, 22);

			// compare
			if(!emmdata.empty())
			{
				if(emmdata == lastdata)
				{
					cout << BASNAME << "equal EMM data" << endl;
				}
				else
				{
					if(!lastdata.empty())
					{
						// write flagfile
						write(oFile,"");
						cout << BASNAME << "new EMM data detected" << endl;
					}
					else
					{
						// only print timestamp output
						cout << BASNAME << "first run" << endl;
					}

					// save last result
					write(t_filename,emmdata);
				}
			}
		}
	}

	return 0;
}
	
}; //class

int main(int argc, char *argv[])
{
	cout << BASNAME << "(c)FlatTV 2015 " << endl;

	switch (argc)
	{
		case 3:
		{
			while(true)
			{
				emmrd::run(argv[1], argv[2]);
				sleep(3600);
			}
			break;
			exit(0);
		}
		default:
			cout << "\tCheck and create a flagfile, if emm data has changed since last run" << endl;
			cout << "\tUSAGE:\t" << BASNAME << "<(d)oscam configfile> <flagfile>" << std::endl;
			return 1;
	}
	exit(1);
}
