#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "vinfo.h"
#include "md5.h"

static struct md5emu md5emu_versions[] =
{
	{"21cfa58e94ea12e93cb344361cfca0d3","2011/02/21"},	// cs2gbox
	{"60290d667a8fceb8e61ed568416fa7e5","v2.1B"},		// NI cs2gbox [Mar 04 2011]
	{"627bf42e18d100418b8eb26aeb208f05","v2.1C"},		// NI cs2gbox [Aug 14 2011]
	{"3ade7732b3259b372b9c61c6260730aa","v2.2A"},		// NI cs2gbox [Aug 16 2011]
	{"ae7adbf886156b5e699a9b71cb8c3fed","v2.1C 2012"},	// NI cs2gbox [2012]
};

static struct mgcamd mgcamd_versions[] =
{
	{"2282041518e3cf58d706e127adfa97b0","1.35a 2010/01/26"},
	{"4a0f1ef99d09f8e386ff2b03f8dc5a24","1.35a 2010/07/30"},
	{"291a3f7a9ba3f7cc0afe79b058650464","1.35a Austria-SAT"},
	{"cd60d00cd76d66214c0b57d3181447b7","1.35a 2014/02/03"},	//by mixvt (compiled Feb  3 2014 19:20:06)
	{"0d7206cc96c050fd7d4fa4a777c44503","1.35c Austria-/Canalsat"},
};

s_string searchstring[] = {
	{ "compiled %s %s)", 17 },		// mgcamd
	{ "Butter-team", 15 },			// newcs
	{ "started version", 16 },		// oscam version old
	{ "cardserver %s, version", 23 },	// oscam version new
	{ "svn, build #", 12 },			// oscam build
	{ "svn, build r", 12 },			// oscam build new
	{ "EMU: ", 5 },				// doscam
	{ "svn", 31 },				// gbox svn
	//{ "gbox_cfg, trace", -27 },		// gbox git - old function
	{ "Linux@ARM", 55 },			// gbox git
};

void Usage()
{
	printf("%s\n", VERSION);
	printf("Usage: vinfo <CAM-Code> <Path to emu>\n");
	printf("\tInfo: get emu-information offline\n");
	printf("\tSupportboard: %s\n", SUPPORT);
	printf("\tCopyright: %s\n\n", COPYRIGHT);
	printf("<CAM-Code> (Supported Binarys):\n");
	printf("   NEWCS\n");
	printf("   MGCAMD\n");
	printf("   GBOX.NET\n");
	printf("   OSEMU\n");
	printf("   OSCAM\n");
	printf("   NCAM\n");
	printf("   DOSCAM\n");
	printf("   CS2GBOX\n");
}

static char *trim(char *txt)
{
	register int l;
	register char *p1, *p2;

	if (*txt==' ')
	{
		for (p1=p2=txt;
			(*p1==' ') || (*p1=='\t') || (*p1=='\n') || (*p1=='\r');
			p1++){};
		while (*p1)
			*p2++=*p1++;
		*p2='\0';
	}
	if ((l=strlen(txt))>0)
		for (p1=txt+l-1;
			(*p1==' ') || (*p1=='\t') || (*p1=='\n') || (*p1=='\r');
			*p1--='\0'){};
	return(txt);
}

FILE *OpenBinFile(char *file)
{
	FILE *fh;
	if (!(fh=fopen(file, "rb")))
	{
		perror("Can`t open file");
		exit(EXIT_FAILURE);
	}
	return(fh);
}

long Search(FILE *fh, s_string *string, int emu)
{
	long found_pos;						// Rückgabewert
	char buffer[1024];					// Gröe des Lesebuffers
	char * p;						// temp. Zeiger für buffer erstellen
	int slen = strlen(string[emu].str);			// Länge der Zeichenkette für Überlappung ermitteln
	//printf("string: %i (%s)\n", slen, string[emu].str);
	int idx;
	int found = 0;
	long sp = 0;						// fr berlappung
	
	//printf("--> String: %s\n", string[emu].str);
	int szread;
	while ((szread = fread(buffer, 1, sizeof(buffer), fh)))
	{
		p = buffer;
		for ( idx = 0; idx < szread; idx++ ) 
		{
			switch (emu)
			{
/*
				case CAMD3:
					if (p[0] == '\0' && p[1] == string[emu].str[0] && p[2] == string[emu].str[1])
					{
						found_pos = ftell(fh)-szread+idx;
						return(found_pos);
					}
					break;
*/				default:
					if ( *p == string[emu].str[0] ) 
					{
						found = ( strstr( p, string[emu].str ) == p );
						if (found)
						{
							found_pos = ftell(fh)-szread+idx;
							return(found_pos);
						}
					}
					
			}
			p++;
		}
		sp += ( sizeof(buffer) - slen );
		fseek( fh, sp, SEEK_SET );
		szread = fread(buffer,1,sizeof(buffer), fh );      
	}
	
	return(0);
}

void Emu (char *file, s_string *search, int emu)
{
	FILE *fh;
	fh = OpenBinFile(file);
	strcpy(version,"keine Informationen gefunden");

	long pos = Search(fh, searchstring, emu);
	//printf("pos: %ld\n", pos);
	if (pos == 0)
		fclose(fh);
	else
	{
		fseek(fh, pos+searchstring[emu].offset, SEEK_SET);
		fscanf(fh, COMPILE_STRING, version);
		fclose(fh);
	}
}

int mdfile(FILE *fp, unsigned char *digest)
{
	unsigned char buf[1024];
	struct MD5Context ctx;
	int n;

	MD5Init(&ctx);
	while ((n = fread(buf, 1, sizeof(buf), fp)) > 0)
		MD5Update(&ctx, buf, n);
	MD5Final(digest, &ctx);
	if (ferror(fp))
		return -1;
	return 0;
}

int ret_md5_sum(int emu)
{
	switch (emu)
	{
		case MD5EMU:
			return sizeof(md5emu_versions) / sizeof(*md5emu_versions);
		case MGCAMD:
			return sizeof(mgcamd_versions) / sizeof(*mgcamd_versions);
		default:
			return 0;
	}
}

char *DetectMD5Version(unsigned char *p, int emu)
{
	int count;
	char md5string[40]="";
	char tmp[6];
	
	for (count=0; count<16; count++)
	{
		sprintf((char*) &tmp, "%02x", p[count] );
		strcat(md5string, tmp);
	}

	int anz = ret_md5_sum(emu);

	for(count=0; count<anz; count++)
	{
		switch (emu)
		{
			case MD5EMU:
				if (strcmp(md5emu_versions[count].md5, md5string)==0)
					return md5emu_versions[count].v_name;
			case MGCAMD:
				if (strcmp(mgcamd_versions[count].md5, md5string)==0)
					return mgcamd_versions[count].v_name;
				  
		}
	}
	return "Version unbekannt";
}

int File_check(const char * str)
{
	FILE * Existance;
	
	if ( ( Existance = fopen(str, "r+") ) == 0)
		return(false);
	else
		fclose(Existance);
	
	return(true);
}

void GBoxHandling(char *file, s_string *search)
{
	FILE *fh;
	
	if (File_check("/tmp/gbox.ver"))
	{
		fh=fopen("/tmp/gbox.ver", "r");
		fscanf(fh, "%40s", version);
		fclose(fh);
		printf("%s ",version);
	}

	Emu(file, search, GBOX);

	if (strstr(version, "keine Informationen gefunden")) {
		Emu(file, search, GBOX_GIT);
		printf("GIT #");
	}
	else {
		printf("SVN #");
	}
}

void MgcamdHandling(char *file, s_string *search)
{
	FILE *fh;
	
	fh = OpenBinFile(file);
	unsigned char digest[16];
	mdfile(fh, digest);
	strcpy(version, DetectMD5Version(digest, MGCAMD));
	fclose(fh);

	if (strstr(version, "Version unbekannt"))
		Emu(file, search, MGCAMD);
}

int OscamHandling(char *file)
{
	FILE *pipe_reader;
	char *ptr;
	char *buffer;
	char str[128]	= "";
	ssize_t read;
	size_t len;
	int ret = 0;

	snprintf(str, sizeof(str), "%s -V", file);

	buffer=NULL;
	if (!(pipe_reader = popen (str, "r")))
		printf("[OscamHandling] popen error\n");

	strcpy(str,"");

	while ((read = getline(&buffer, &len, pipe_reader)) != -1)
	{
		if ((ptr = strstr(buffer, "Version:"))) {
			printf("%s\n",trim(ptr+8));
			ret=1;
		}
	}
	pclose(pipe_reader);
	if(buffer)
		free(buffer);
	if(ret != 1)
		printf("%s\n", version);
	return(ret);
}

void md5emuHandling(char *file, s_string *search)
{
	FILE *fh;
	
	fh = OpenBinFile(file);
	unsigned char digest[16];
	mdfile(fh, digest);
	strcpy(version, DetectMD5Version(digest, MD5EMU));
	fclose(fh);
}

int main(int argc, char **argv)
{
	switch (argc)
	{
		case 3:
			if (strstr(argv[1], "MGCAMD"))
				MgcamdHandling(argv[2], searchstring);
			else if (strstr(argv[1], "NEWCS"))
				Emu(argv[2], searchstring, NEWCS);
			else if (strstr(argv[1], "OSEMU"))
				strcpy(version, "n/a");
			else if (strstr(argv[1], "OSCAM"))
				Emu(argv[2], searchstring, OSCAM_VERSION);
			else if (strstr(argv[1], "NCAM"))
				Emu(argv[2], searchstring, OSCAM_VERSION_NEW);
			else if (strstr(argv[1], "CS2GBOX"))
				md5emuHandling(argv[2], searchstring);
			else if (strstr(argv[1], "GBOX.NET"))
				GBoxHandling(argv[2], searchstring);
			else
				Usage();
			break;
		default:
			Usage();
			exit(1);
	}
#if 0
	if (strstr(version, "keine Informationen gefunden"))
	{
		if (strstr(argv[1], "NEWCAMD"))
			Emu(argv[2], searchstring, NEWCAMD_OLD);
		else if (strstr(argv[1], "CCCAM"))
			Emu(argv[2], searchstring, CCCAM_OLD);
		else if (strstr(argv[1], "RDGD"))
			Emu(argv[2], searchstring, RDGD_NEW);
		else if (strstr(argv[1], "NEWCS"))
			Emu(argv[2], searchstring, NEWCS_07);
		else if (strstr(argv[1], "EVOCAMD"))
		{
			Emu(argv[2], searchstring, EVOCAMD_NEW);
			sscanf(version, "%[^ ]", version);
		}
		else if (strstr(argv[1], "SCAM"))
			ScamHandling(argv[2]);
	}
	
	if (strstr(version, "Compiled on"))
		Emu(argv[2], searchstring, NEWCS_NEW);
#endif

	if (strstr(argv[1], "OSCAM"))
	{
		int doscam = 0;

		if (strstr(version, "keine Informationen gefunden"))
			Emu(argv[2], searchstring, OSCAM_VERSION_NEW);

		if (!strstr(version, "keine Informationen gefunden"))
			printf("%s", version);

		Emu(argv[2], searchstring, DOSCAM);
		if(strstr(version, "Key"))
			doscam = 1;

		Emu(argv[2], searchstring, OSCAM_BUILD);
		if(strstr(version, "keine Informationen gefunden"))
			Emu(argv[2], searchstring, OSCAM_BUILD_NEW);

		if (!strstr(version, "keine Informationen gefunden"))
			printf(" SVN #%s %s\n", version, (doscam?"(DOSCam)":""));
		else 
			OscamHandling(argv[2]);
	}
	else
	{
		printf("%s\n", version);
	}

	exit(EXIT_SUCCESS);
}
