#ifndef VINFO_H_
#define VINFO_H_

#define VERSION "vinfo Version 3.27"
#define SUPPORT "www.neutrino-images.de"
#define COPYRIGHT "luke777, FlatTV"

enum {false, true};

enum {MGCAMD, NEWCS, OSCAM_VERSION, OSCAM_VERSION_NEW, OSCAM_BUILD, OSCAM_BUILD_NEW, DOSCAM, GBOX, GBOX_GIT, MD5EMU };

typedef struct _s_string {
	char *str;
	int offset;
} s_string;

struct md5emu
{
	char md5[35];
	char v_name[20];
};

struct mgcamd
{
	char md5[35];
	char v_name[25];
};

char version[40] = "keine Informationen gefunden";
const char COMPILE_STRING[] = "%[0-9.a-zA-Z ]";
const char COMPILE_STRING_NOSPACE[] = "%[0-9.a-zA-Z]";

// Funktionsdeklarationen =====================================================
void Usage();
FILE *OpenBinFile(char *file);
long Search(FILE *fh, s_string *string, int emu);
void Emu (char *file, s_string *search, int emu);
void GBoxHandling(char *file, s_string *search);
void MgcamdHandling(char *file, s_string *search);
int OscamHandling(char *file);
void md5emuHandling(char *file, s_string *search);
// MD5 Funktionsdeklaration
int mdfile(FILE *fp, unsigned char *digest);
int ret_md5_sum(int emu);
char *DetectMD5Version(unsigned char *p, int emu);

#endif /*VINFO_H_*/
