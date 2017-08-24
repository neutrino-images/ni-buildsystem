#include "oscammon.h"

#ifdef BUILTIN_CRYPTO
#	include "aes_core.c"
#	include "crc32.c"
#else
#	include <openssl/aes.h>
#	include <zlib.h>
#endif

#include "md5.c"

#define	MAXCLIENTS	48
#define	MAXSERVER	16
#define	MAXFIELDS	24
#define	MAXFIELDSIZE	32

#include "icons.inc"

typedef	struct	s_server
{
	char 	*name;
	char	*label;
	char	*user;
	char	*pwd;
	uint16_t port;
}	SERVER;

static	FT_Library	library;
static	FTC_Manager	manager;
static	FTC_SBitCache	cache;
static	FTC_SBit	sbit;
static	FTC_ImageTypeRec desc;
static	FT_Face		face;
static	FT_UInt		prev_glyphindex;
static	FT_Bool		use_kerning;

static	int		fb, rc, lcd;	// devices
static	unsigned char	*lfb=0, *lbb=0, *lbb0=0, *lbb1=0, *lbb2=0;
static	int		startx, starty;
static	int		fbsize;

static	char 		*montxt="oscammon";
static	char 		*monver="0.6f";
static	int		sfd=0, connected=0;
static	struct		sockaddr_in sa;
static	unsigned char	raddr[4]={0,0,0,0};
static	int		tbidx=0;
static	char		txtbuf[MAXCLIENTS<<8], *tptr[MAXCLIENTS+1][MAXFIELDS+1];
static	char		*fontpath=(char *)txtbuf; // simple trick to save space
static	char		*icon_esc=icon_home; // for safety, home always exists
static	int		lbidx=0, logwy=0;
static	char		logbuf[32][128];
static	time_t		logsent=0;
static	int		cur_server=0, num_server=0;
static	char		cfgbuf[MAXSERVER<<8], *cfgptr=cfgbuf;
static	SERVER		server[MAXSERVER];
static	int		syspage=0, cs_uptime=0;
static	int		hidemonitor=0, smallfont=0, mode2=0;
static	char		pin[4]={10,10,10,10};
static	AES_KEY		d_key, e_key;
static	unsigned char	ucrc[4];
static	int		px1=0, py1, px2, py2;
static	int		mwidth;
static	int		slim=0, trace=0;

static void csmon_show_clients(void);

static char *trim(char *txt)
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

static char *strtolower(char *txt)
{
	char *p;
	for (p=txt; *p; p++)
		*p=tolower(*p);
	return(txt);
}

static void csmon_log(char *fmt,...)
{
	va_list params;
	va_start(params, fmt);
	printf("%s: ", montxt);
	vprintf(fmt, params);
	fflush(stdout);
	va_end(params);
}

static char *csmon_add_para(char *txt)
{
	char *ptr;
	strcpy(ptr=cfgptr, txt);
	cfgptr+=strlen(txt)+1;
	return(ptr);
}

static void csmon_parse_url(char *url)
{
	char *service="oscammon://", *port, *para;
	SERVER this;

	if (num_server>=MAXSERVER) return;
	if (strncmp(url, service, strlen(service))) return;
	this.user=url+strlen(service);
	if (!(this.name=strchr(this.user, '@'))) return;
	*this.name++='\0';
	if (!(this.pwd=strchr(this.user, ':'))) return;
	*this.pwd++='\0';
	if (!(port=strchr(this.name, ':'))) return;
	*port++='\0';
	this.label=this.name;
	if ((para=strchr(port, '?')))
	{
		char *ptr1, *ptr2;
		*para++='\0';
		for (ptr1=strtok(para, "&"); ptr1; ptr1=strtok(NULL, ","))
		{
			if (!(ptr2=strchr(ptr1, '='))) continue;
			*ptr2++='\0';
			strtolower(ptr1);
			if (!strcmp("label", ptr1)) this.label=ptr2;
		}
	}
	if ((server[num_server].port=atoi(port)))
	{
		server[num_server].user =csmon_add_para(this.user);
		server[num_server].pwd  =csmon_add_para(this.pwd);
		server[num_server].name =csmon_add_para(this.name);
		server[num_server].label=csmon_add_para(this.label);
		num_server++;
	}
}

static void csmon_chk_para(char *token, char *value)
{
	if (!strcmp(token, "server"))
		csmon_parse_url(value);
	else if (!strcmp(token, "font"))
		strncpy(fontpath, value, 256);
	else if (!strcmp(token, "hidemonitor"))
		{ if (atoi(value)) hidemonitor=1; }
	else if (!strcmp(token, "startwithip"))
		{ if (atoi(value)) mode2=1; }
	else if (!strcmp(token, "smallfont"))
		{ if (atoi(value)) smallfont=1; }
	else if (!strcmp(token, "pin"))
		{ 
			if (strlen(value)==4) 
			{ 
				int i; 
				for (i=0; i<4; i++) 
				{ 
					if ((value[i]<'0') || (value[i]>'9'))	// invalid
						pin[0]=10;	// flag for no pin
					else
						pin[i]=value[i]-'0';
				}
			}
		}
}

static int csmon_read_config()
{
	FILE *fp;
	char token[256];

	strcpy(fontpath, FONT);
	if (!(fp=fopen(CFGFILE, "r")))
		return(-1);
	while(fgets(token, sizeof(token), fp))
	{
		char *value;
		if (!(value=strchr(trim(token), '='))) continue;
		*value++='\0';
		csmon_chk_para(trim(strtolower(token)), trim(value));
	}
	fclose(fp);
	return(0);
}

static void csmon_set_key(char *key)
{
	AES_set_encrypt_key(key, 128, &e_key);
	AES_set_decrypt_key(key, 128, &d_key);
}

static unsigned char *i2b(int n, ulong i)
{
	static unsigned char b[4];
	switch(n)
	{
		case 2:
			b[0]=(i>> 8) & 0xff;
			b[1]=(i    ) & 0xff;
			break;
		case 4:
			b[0]=(i>>24) & 0xff;
			b[1]=(i>>16) & 0xff;
			b[2]=(i>> 8) & 0xff;
			b[3]=(i    ) & 0xff;
			break;
	}
	return(b);
}

static void csmon_set_account(char *user, char *pwd)
{
	unsigned long c;
	unsigned long md5[4];
	c=crc32(0L, md5_buffer(user, strlen(user), md5), 16);
	ucrc[0]=(c>>24) & 0xff; ucrc[1]=(c>>16) & 0xff;
	ucrc[2]=(c>> 8) & 0xff; ucrc[3]=(c    ) & 0xff;
	csmon_set_key(md5_buffer(pwd, strlen(pwd), md5));
}

#define boundary(exp, n) (((((n)-1)>>(exp))+1)<<(exp))

static int csmon_send(char *txt)
{
	int i, l;
	unsigned char buf[256+32];
	buf[0]='&';
	buf[9]=strlen(txt);
	l=boundary(4, buf[9]+5)+5;
	strcpy(buf+10, txt);
	memcpy(buf+5, i2b(4, crc32(0L, buf+10, l-10)), 4);
	for(i=0; i<(l-5); i+=16)
		AES_encrypt(buf+5+i, buf+5+i, &e_key);
	memcpy(buf+1, ucrc, 4);
	return(send(sfd, buf, l, 0));
}

static int csmon_recv(unsigned char *buf, int l)
{
	int i, n;
	if (!sfd) return(-1);
	if ((n=recv(sfd, buf, l, 0))<10)
		return(-1);
	if (buf[0]!='&')		// not crypted
		return(-1);
	if (memcmp(buf+1, ucrc, 4))	// wrong user crc
		return(-1);
	for(i=0; i<(n-5); i+=16)
		AES_decrypt(buf+5+i, buf+5+i, &d_key);
	if (memcmp(buf+5, i2b(4, crc32(0L, buf+10, n-10)), 4))
	{
		csmon_log("CRC error while receiving ! wrong password ?\n");
		return(-1);
	}
	n=buf[9];
	buf[10+n]='\0';
	memmove(buf, buf+10, n+1);
	return(n);
}

static int csmon_recv_timer(unsigned char *txt, int l, int sec)
{
	struct timeval tv;
	fd_set fds;
	int rc;

	if (!sfd) return(-1);
	tv.tv_sec = sec;
	tv.tv_usec = 0;
	FD_ZERO(&fds);
	FD_SET(sfd, &fds);

	select(sfd+1, &fds, 0, 0, &tv);

	rc=0;
	if (FD_ISSET(sfd, &fds))
		if (!(rc=csmon_recv(txt, l)))
			rc=-1;

	return(rc);
}

static int csmon_gets(unsigned char *txt, int sec)
{
	int r, done=0;
	unsigned char *ptr;
	static unsigned char lbuf[4096];
	static int p=0;
	txt[0]='\0';
	while (!done)
	{
		lbuf[p]=0;
		if ((ptr=strchr(lbuf, '\n')))
		{
			*ptr=0;
			strcpy(txt, lbuf);
			ptr++;
			p-=ptr-lbuf;
			if (p>0) memmove(lbuf, ptr, p+1);
			done=1;
		}
		else
		{
			if ((r=csmon_recv_timer(lbuf+p, sizeof(lbuf)-p, sec))>0)
				p+=r;
			else
				done=1;
		}
	}
	return(txt[0]);
}

static void csmon_disconnect(void)
{
	if (sfd)
	{
		csmon_send("exit");
		close(sfd);
	}
	for (lbidx=31; lbidx; lbidx--)
		logbuf[lbidx][0]='\0';
	logsent=0;
	sfd=0;
	memset(tptr, tbidx=0, sizeof(tptr));
	cs_uptime=0;
}

static int csmon_connect(int srvidx)
{
	int sd;
	struct protoent *ptrp;

	csmon_show_clients();
	connected=0;
	if (!((int)(ptrp=getprotobyname("udp"))))
		return(0);

	memset((char *)&sa, 0, sizeof(sa));
	sa.sin_family = AF_INET;
	sa.sin_port = htons(server[srvidx].port);
	memcpy(&sa.sin_addr, raddr, sizeof(raddr));

	if ((sd=socket(PF_INET, SOCK_DGRAM, ptrp->p_proto))<0)
		return(0);

	if (connect(sd, (struct sockaddr *)&sa, sizeof(sa))<0)
	{
		close(sd);
		return(0);
	}
	csmon_set_account(server[srvidx].user, server[srvidx].pwd);
	connected=1;
	cs_uptime=0;
	return(sd);
}

static int csmon_chkcon(int srvidx)
{
	struct hostent *rht;
	if (!(rht=gethostbyname(server[srvidx].name)))
		return(-1);
	if (memcmp(raddr, rht->h_addr, sizeof(raddr)))
	{
		csmon_disconnect();
		memcpy(raddr, rht->h_addr, sizeof(raddr));
	}
	if (!sfd)
	{
		sfd=csmon_connect(srvidx);
//	if (sfd) csmon_send("log on");
	}
	return(sfd);
}

/******************************************************************************
 * GetRCCode
 ******************************************************************************/

static long GetRCCode_API3()
{
	long rcc=(-1);
	static __u16 rc_last_key = KEY_RESERVED;

	if (read(rc, &ev, sizeof(ev))==sizeof(ev))
	{
		if (ev.value)
		{
			if (ev.code!=rc_last_key)
			{
				rc_last_key=ev.code;
				switch(ev.code)
				{
					case KEY_UP:		rcc=RC_UP;	break;
					case KEY_DOWN:		rcc=RC_DOWN;	break;
					case KEY_LEFT:		rcc=RC_LEFT;	break;
					case KEY_RIGHT:		rcc=RC_RIGHT;	break;
					case KEY_OK:		rcc=RC_OK;	break;
					case KEY_0:		rcc=RC_0;	break;
					case KEY_1:		rcc=RC_1;	break;
					case KEY_2:		rcc=RC_2;	break;
					case KEY_3:		rcc=RC_3;	break;
					case KEY_4:		rcc=RC_4;	break;
					case KEY_5:		rcc=RC_5;	break;
					case KEY_6:		rcc=RC_6;	break;
					case KEY_7:		rcc=RC_7;	break;
					case KEY_8:		rcc=RC_8;	break;
					case KEY_9:		rcc=RC_9;	break;
					case KEY_RED:		rcc=RC_RED;	break;
					case KEY_GREEN:		rcc=RC_GREEN;	break;
					case KEY_YELLOW:	rcc=RC_YELLOW;	break;
					case KEY_BLUE:		rcc=RC_BLUE;	break;
					case KEY_VOLUMEUP:	rcc=RC_PLUS;	break;
					case KEY_VOLUMEDOWN:	rcc=RC_MINUS;	break;
					case KEY_MUTE:		rcc=RC_MUTE;	break;
					case KEY_HELP:		rcc=RC_HELP;	break;
					case KEY_INFO:		rcc=RC_HELP;	break;
					case KEY_SETUP:		rcc=RC_DBOX;	break;
					case KEY_EXIT:
					case KEY_HOME:		rcc=RC_HOME;	break;
					case KEY_FORWARD:	rcc=RC_FORWARD;	break;
					case KEY_REWIND:	rcc=RC_REWIND;	break;
					case KEY_PLAY:		rcc=RC_PLAY;	break;
					case KEY_POWER:		rcc=RC_STANDBY;
				}
			}
		}
		else
			rc_last_key=KEY_RESERVED;
	}
	return(rcc);
}

static long csmon_getrc()
{
	fd_set fds;
	FD_ZERO(&fds);
	FD_SET(rc, &fds);
	select(rc+1, &fds, 0, 0, 0);
	if (FD_ISSET(rc, &fds))
		return(GetRCCode_API3());
	else
		return(-1);
}

/******************************************************************************
 * MyFaceRequester
 ******************************************************************************/

static FT_Error MyFaceRequester(FTC_FaceID face_id, FT_Library library, FT_Pointer request_data, FT_Face *aface)
{
	FT_Error result;

	result=FT_New_Face(library, face_id, 0, aface);
	csmon_log("<Font \"%s\" %s>\n", (char *)face_id,
		(result) ? "failed" : "loaded");
	return(result);
}

#ifdef NOT_USED_YET
/******************************************************************************
 * RenderLCDDigit
 ******************************************************************************/

void RenderLCDDigit(int digit, int sx, int sy)
{
	int x, y;

	for(y=0; y<15; y++)
	{
		for(x=0; x<10; x++)
		{
			if (lcd_digits[digit*15*10+x+y*10])
				lcd_buffer[sx+x+((sy+y)/8)*120] |= 1<<((sy+y)%8);
			else
				lcd_buffer[sx+x+((sy+y)/8)*120] &= ~(1<<((sy+y)%8));
		}
	}
}

/******************************************************************************
 * UpdateLCD
 ******************************************************************************/

void UpdateLCD(int account)
{
	int x, y;

	//set online status

		for(y = 0; y < 19; y++)
		{
			for(x = 0; x < 17; x++)
			{
				if(lcd_status[online*17*19 + x + y*17]) lcd_buffer[4 + x + ((18 + y)/8)*120] |= 1 << ((18 + y)%8);
				else lcd_buffer[4 + x + ((18 + y)/8)*120] &= ~(1 << ((18 + y)%8));
			}
		}

	//set digits

		RenderLCDDigit(maildb[account].nr[0] - '0', 41, 20);

		RenderLCDDigit(maildb[account].time[0] - '0', 58, 20);
		RenderLCDDigit(maildb[account].time[1] - '0', 71, 20);
		RenderLCDDigit(maildb[account].time[3] - '0', 93, 20);
		RenderLCDDigit(maildb[account].time[4] - '0', 106, 20);

		RenderLCDDigit(maildb[account].status[0] - '0', 28, 44);
		RenderLCDDigit(maildb[account].status[1] - '0', 41, 44);
		RenderLCDDigit(maildb[account].status[2] - '0', 54, 44);
		RenderLCDDigit(maildb[account].status[4] - '0', 80, 44);
		RenderLCDDigit(maildb[account].status[5] - '0', 93, 44);
		RenderLCDDigit(maildb[account].status[6] - '0', 106, 44);

	//copy to lcd

		write(lcd, &lcd_buffer, sizeof(lcd_buffer));
}
#endif

/******************************************************************************
 * bufsize / SetPixel / HorLine - speed up with defines
 ******************************************************************************/


#define bufsize(n) ((n)<<2)
#define SetPixel(x, y, c)  memcpy(lbb + ((startx + (x))<<2) + fix_screeninfo.line_length*(starty + (y)), bgra[c], 4)
static void HorLine(int x, int y, int l, int color)
{
	for (l+=x; x<l; x++)
		SetPixel(x, y, color);
}

/******************************************************************************
 * RenderChar
 ******************************************************************************/

static int RenderChar(FT_ULong currentchar, int sx, int sy, int ex, int color)
{
	int row, pitch, bit, x = 0, y = 0;
	FT_Error error;
	FT_UInt glyphindex;
	FT_Vector kerning;
	FTC_Node anode;

	// simulate TAB
	if (currentchar == '\t')
	{
		return 15;
	};

	//load char
	if (!(glyphindex=FT_Get_Char_Index(face, (int)currentchar))) // cast (int) due to 7025
	{
		csmon_log("<FT_Get_Char_Index for Char \"%c\" failed: \"undefined character code\">\n", (int)currentchar);
		return(0);
	}

	if ((error=FTC_SBitCache_Lookup(cache, &desc, glyphindex, &sbit, &anode)))
	{
		csmon_log("<FTC_SBitCache_Lookup for Char \"%c\" failed with Errorcode 0x%.2X>\n", (int)currentchar, error);
		return(0);
	}

	if (use_kerning)
	{
		FT_Get_Kerning(face, prev_glyphindex, glyphindex, ft_kerning_default, &kerning);
		prev_glyphindex=glyphindex;
		kerning.x>>=6;
	}
	else
	  kerning.x=0;

	//render char
	if (color!=(-1))	/* don't render char, return charwidth only */
	{
		if (sx+sbit->xadvance>=ex) return(-1);	/* limit to maxwidth */

		for (row=0; row<sbit->height; row++)
		{
			for (pitch=0; pitch<sbit->pitch; pitch++)
			{
				for (bit=7; bit>=0; bit--)
				{
					if (pitch*8+7-bit >= sbit->width) break; /* render needed bits only */
					if ((sbit->buffer[row*sbit->pitch+pitch]) & 1<<bit)
						SetPixel(sx + x + sbit->left + kerning.x, sy + y - sbit->top, color);
					x++;
				}
			}
			x=0;
			y++;
		}
	}
	return(sbit->xadvance + kerning.x);		// return charwidth
}

/******************************************************************************
 * GetStringLen
 ******************************************************************************/

static int GetStringLen(unsigned char *string)
{
	int stringlen=0;

	prev_glyphindex=0;
	while (*string!='\0')
	{
		stringlen+=RenderChar(*string, -1, -1, -1, -1);
		string++;
	}
	return(stringlen);
}

/******************************************************************************
 * RenderString
 ******************************************************************************/

static void RenderString(unsigned char *string, int sx, int sy, int maxwidth, int layout, int size, int color)
{
	int stringlen, ex, charwidth;

	//set size
	if (size==SMALL)
		desc.width = desc.height = 24;
	else
		desc.width = desc.height = 32; // 40

	//set alignment
	if (layout!=LEFT)
	{
		stringlen=GetStringLen(string);
		switch(layout)
		{
			case CENTER: if (stringlen<maxwidth) sx+=(maxwidth-stringlen)/2;
				break;

			case RIGHT:  if (stringlen<maxwidth) sx+=maxwidth-stringlen;
		}
	}

	//reset kerning
	prev_glyphindex=0;

	//render string
	ex = sx + maxwidth;

	while(*string!='\0')
	{
		if ((charwidth=RenderChar(*string, sx, sy, ex, color))==-1)
			return;			/* string > maxwidth */
		sx+=charwidth;
		string++;
	}
}

/******************************************************************************
 * RenderBox
 ******************************************************************************/

static void RenderBox(int sx, int sy, int ex, int ey, int mode, int color)
{
	int loop;

	if (mode==FILL)
		for(; sy<=ey; sy++)
			HorLine(sx, sy, ex-sx+1, color);
	else
	{
		//hor lines
		for(loop=sx; loop<=ex; loop++)
		{
			SetPixel(loop, sy  , color);
			SetPixel(loop, sy+1, color);
			SetPixel(loop, ey-1, color);
			SetPixel(loop, ey  , color);
		}
		//ver lines
		for(loop=sy; loop<=ey; loop++)
		{
			SetPixel(sx  , loop, color);
			SetPixel(sx+1, loop, color);
			SetPixel(ex-1, loop, color);
			SetPixel(ex  , loop, color);
		}
	}
}

/******************************************************************************
 * RenderCircle
 ******************************************************************************/

static void RenderCircle(int sx, int sy, int color)
{
	int x, y;

	for (y=0; y<15; y++)
		for (x=0; x<15; x++)
			if (circle[x+y*15])
				if (circle[x+y*15] == 1)
					SetPixel(sx + x, sy + y, color);
				else
					SetPixel(sx + x, sy + y, circle[x+y*15]);
}

/******************************************************************************
 * PaintIcon
 ******************************************************************************/

struct rawHeader
{
	uint8_t width_lo;
	uint8_t width_hi;
	uint8_t height_lo;
	uint8_t height_hi;
	uint8_t transp;
} __attribute__ ((packed));

static void PaintIcon(unsigned char *icon, int sx, int sy)
{
	struct rawHeader header;
	uint16_t	width, height;
	int		x, y;

	memcpy(&header, icon, sizeof(struct rawHeader));
	width  = (header.width_hi  << 8) | header.width_lo;
	height = (header.height_hi << 8) | header.height_lo;
	icon+=sizeof(struct rawHeader);

	for (y=0; y<height; y++)
	{
		for (x=0; x<width; x+=2)
		{
			unsigned char pix;
			pix = (*icon & 0xf0) >> 4;
			if (pix != header.transp)
				SetPixel(sx+x, sy+y, pix+1);
			pix = (*icon++ & 0x0f);
			if (pix != header.transp)
				SetPixel(sx+x+1, sy+y, pix+1);
		}
	}
}

/******************************************************************************
 * Pop-Up's
 ******************************************************************************/

static void csmon_redraw_screen(int lbb_no)
{
	lbb=(lbb_no) ? lbb1 : lbb0;	// set default backbuffer;
	if (px1)	// active popup
	{
		int y;
		memcpy(lbb2, lbb0, fbsize);
		for(y=py1; y<=py2; y++)
		{
			long offset=bufsize(startx + px1) + fix_screeninfo.line_length*(starty + y);
			memcpy(lbb2 + offset, lbb1 + offset, bufsize(px2-px1+1));
		}
		memcpy(lfb, lbb2, fbsize);
	}
	else
		memcpy(lfb, lbb0, fbsize);
}

#define LABEL_YS 32

#define csmon_popup_close() csmon_redraw_screen(px1=0)

static void csmon_popup_window(char *label, char *icon, int x1, int y1, int xs, int ys)
{
	lbb=lbb1;	// while painting popup use popup-backbuffer
	if (x1<0) x1=((var_screeninfo.xres-xs)>>1)-startx;
	if (y1<0) y1=((var_screeninfo.yres-ys)>>1)-starty;
	px1=x1; py1=y1; px2=x1+xs; py2=y1+ys;
	RenderBox(px1+1, py1+1, px2+1, py2+1, GRID, BLACK);
	RenderBox(px1+2, py1+2, px2+2, py2+2, GRID, BLACK);
	RenderBox(px1  , py1  , px2  , py1+LABEL_YS, FILL, BLACK);
	RenderBox(px1  , py1+LABEL_YS, px2  , py2, FILL, L_NGDARK);
	PaintIcon(icon, px1+4, py1+2);
	RenderString(label, px1+32, py1+24, px2, LEFT, BIG, ORANGE);
	RenderBox(px2-110, py2-36  , px2-10  , py2-10, FILL, ORANGE);
	PaintIcon(icon_esc, px2-105, py2-34);
	RenderString("Zurück", px2-70, py2-16, px2-10, LEFT, SMALL, BLACK);
/*
	RenderBox(px1+10, py2-36, px1+100 , py2-10, FILL, ORANGE);
	PaintIcon(icon_help, px1+15, py2-34);
	RenderString("Weiter", px1+45, py2-16, px2-10, LEFT, SMALL, BLACK);
*/
	px2+=2; py2+=2;
}

static void csmon_message(int waitflag, char *label, char *txt)
{
	int xs;
	RenderString("", startx, starty, startx, LEFT, BIG, WHITE);
	xs=GetStringLen(txt)+32;
	if (xs<300) xs=300;
	csmon_popup_window(label, icon_info, -1, -1, xs, 130);
	RenderString(txt, px1, py1+(LABEL_YS<<1)+8, px2-px1, CENTER, BIG, WHITE);
	csmon_redraw_screen(0);
	if (waitflag)
	{
		long rccode;
		while (waitflag)
			waitflag=(((rccode=csmon_getrc())!=RC_HOME) && (rccode!=RC_OK));
		csmon_popup_close();
	}
}

#define PINCX 32
#define PINCY 40
static int csmon_getpin(char *cp)
{
	int cy, cx, state, cell=0, action=1;

	if (cp[0]>9) return(2);	// no pin needed
	char c[]={10,10,10,10};
      //  csmon_popup_window("PIN-Abfrage", icon_lock, -1, -1, 300, 100);
      //  cx=px1+32;
	csmon_popup_window("PIN-Abfrage", icon_lock, -1, -1, 300, 150);
	cx=px1+((px2-px1)>>1)-(PINCX<<1);
	cy=py1+LABEL_YS+20;
	RenderBox(cx, cy, cx+(PINCX<<2), cy+PINCY, GRID, WHITE);
	RenderBox(cx+3*PINCX, cy, cx+(PINCX<<2), cy+PINCY, GRID, WHITE);
	RenderBox(cx+PINCX, cy, cx+(PINCX<<1), cy+PINCY, GRID, WHITE);
	for (state=2; state>1;)
	{
		int i;
		long rccode;
		if (action)
			for (i=0; i<4; i++)
			{
				RenderBox(cx+1+(i*PINCX), cy+1, cx+((i+1)*PINCX)-1, cy+PINCY-1, FILL, (i==cell) ? BLUE2 : BLUE1);
				if (c[i]<10) RenderCircle(cx+8+(i*PINCX), cy+13, WHITE);
			}
		csmon_redraw_screen(1);
		action=1;
		switch(rccode=csmon_getrc())
		{
			case RC_0	: case RC_1:
			case RC_2	: case RC_3:
			case RC_4	: case RC_5:
			case RC_6	: case RC_7:
			case RC_8	: case RC_9: c[cell]=rccode-RC_0; // fall through
			case RC_RIGHT	: cell+=1; break;
			case RC_LEFT	: cell+=3; break;
		//      case RC_OK	: state=1; break;	// for test ONLY !
			case RC_HOME	: state=0; break;
			default		: action=0;		// no refresh needed
		}
		cell%=4;
		if (!memcmp(cp, c, 4)) state=1;
	}
	csmon_popup_close();
	return(state);
}

static void csmon_helpscreen()
{
	int cy, x1, x2, tc=B_GRAY;
	char buf[35];
	sprintf(buf,"NI Edition - OSCAM-Monitor %s\n", monver);
	csmon_popup_window(buf, icon_info, -1, -1, 350, 380);
	cy=py1+LABEL_YS+10;
	x1=px1+24;
	x2=px1+70;
	RenderCircle(x1+4, cy+6, RED);
	RenderString("Client-Prozesse anzeigen", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	RenderCircle(x1+4, cy+6, GREEN);
	RenderString("Server-Prozesse anzeigen", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	PaintIcon(icon_up, x1, cy+3);
	RenderString("Nächster Server", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	PaintIcon(icon_down, x1, cy+3);
	RenderString("Vorheriger Server", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	PaintIcon(icon_left, x1-10, cy+3);
	PaintIcon(icon_right, x1+10, cy+3);
	RenderString("Toggle (große Schrift)", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	PaintIcon(icon_plus, x1, cy+3);
	RenderString("Große Schrift", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	PaintIcon(icon_minus, x1, cy+3);
	RenderString("Kleine Schrift", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	PaintIcon(icon_mute_small, x1, cy+3);
	RenderString("Monitor-Clients ausblenden", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	PaintIcon(icon_help, x1, cy+3);
	RenderString("Hilfe ein-/weiterschalten", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	PaintIcon(icon_esc, x1, cy+3);
	RenderString("Monitor beenden", x2, cy+24, px2-x2, LEFT, BIG, tc);
	csmon_redraw_screen(0);
}

static void csmon_helpscreen2()
{
	int cy, x1, x2, tc=B_GRAY;
	char buf[35];
	sprintf(buf,"NI Edition - OSCAM-Monitor %s\n", monver);
	csmon_popup_window(buf, icon_info, -1, -1, 350, 350);
	cy=py1+LABEL_YS+10;
	x1=px1+24;
	x2=px1+70;
	RenderCircle(x1+4, cy+6, BLUE);
	RenderString("Logfile ein-/ausschalten", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	RenderCircle(x1+4, cy+6, YELLOW);
	RenderString("OSCAM Server Details", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	PaintIcon(icon_forward, x1, cy+3);
	RenderString("User anzeigen", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	PaintIcon(icon_rewind, x1, cy+3);
	RenderString("Chid's anzeigen", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	PaintIcon(icon_1, x1, cy+3);
	RenderString("Debug Level 0", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	PaintIcon(icon_2, x1, cy+3);
	RenderString("Debug Level 63", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	PaintIcon(icon_3, x1, cy+3);
	RenderString("Debug Level 255", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	PaintIcon(icon_play, x1, cy+3);
	RenderString("Cardserver restart", x2, cy+24, px2-x2, LEFT, BIG, tc);
	cy+=28;
	PaintIcon(icon_power_button, x1, cy+3);
	RenderString("Cardserver beenden", x2, cy+24, px2-x2, LEFT, BIG, tc);
	csmon_redraw_screen(0);
}

static void csmon_show_log(int force, int lsiz)
{
	int i, y, idx, color, log;
	static int last=-1;
	if (force) last=-1;
	if (last!=lbidx)
	{
		RenderBox(0, logwy, mwidth-1, 504, FILL, NGDARK);
		RenderBox(0, logwy, mwidth-1, 504, GRID, ORANGE);
		int xstart = !slim ? 120 : 85;
		for (y=498, i=64; y>(logwy+(desc.height*3/4)/*15*/); y-=desc.height*3/4/*20*/, i--)
		{
			idx=(lbidx+i-1)&0x1f;
			if (logbuf[idx][0])
			{
				if(logbuf[idx][1]=='V') //'version'
					RenderString(logbuf[idx]+8, xstart, y, mwidth-xstart, LEFT, lsiz, B_GREEN);
				else if(logbuf[idx][1]=='U') //'getuser'
					RenderString(logbuf[idx]+8, xstart, y, mwidth-xstart, LEFT, lsiz, B_GREEN);
				else if(logbuf[idx][1]=='D') //'details'
					RenderString(logbuf[idx]+17, xstart, y, mwidth-xstart, LEFT, lsiz, B_GREEN);

				else if(logbuf[idx][0]=='U') //'USERMSG'
					RenderString(logbuf[idx]+8, xstart, y, mwidth-xstart, LEFT, lsiz, B_GREEN);
				else
				{
					logbuf[idx][8]='\0';
					RenderString(logbuf[idx], !slim ? 20 : 4, y,  90, LEFT, lsiz, WHITE);

					switch(logbuf[idx][18])
					{
						case 'n':
						case 'l':
						case 's': color=ORANGE; break;
						case 'p':
						case 'r': color=YELLOW; break;
						default : color=WHITE;
					}
					RenderString(logbuf[idx]+/*18*/10, xstart, y, mwidth-xstart, LEFT, lsiz, color);
				}
			}
		}
		csmon_redraw_screen(0);
		last=lbidx;
	}
}

static int csmon_add_client(char *line)
{
	int i, n, l;
	char *ptr, *txt, *str[32];
	static int nr=0;
	static char seq=0;
	txt=line+8;
	//printf("header=%-8.8s\n", line); fflush(stdout);
	if ((line[2]=='S') || (line[2]=='B'))
	{
		seq=line[3];
		memset(tptr, tbidx=nr=0, sizeof(tptr));
	}
	if (line[3]!=seq)	// check block sequence id
		return(0);
	memset(str, 0, sizeof(str));
	if (nr>MAXCLIENTS) return(0);
	for (i=n=0, l=strlen(txt), str[0]=ptr=txt; n<l; n++)
	{
		if (txt[n]=='|')
		{
			txt[n]='\0';
			str[++i]=txt+n+1;
		}
	}
	for (i=0; i<MAXFIELDS; i++)
	{
		tptr[nr][i]=txtbuf+tbidx;
		strncpy(tptr[nr][i], str[i] ? str[i] : "", MAXFIELDSIZE);
		txtbuf[tbidx+MAXFIELDSIZE]='\0';
		tbidx+=1+strlen(tptr[nr][i]);
	}
	if (*tptr[nr][1]=='s')
		cs_uptime=atoi(tptr[nr][11]);
	//printf("tbidx=%d rc=%d\n", tbidx, (line[2]=='E') || (line[2]=='S'));
	nr++;
	return((line[2]=='E') || (line[2]=='S'));
}

static char *csmon_sec2disp(int sec, char *buf)
{
	int lmin, ltmp;
	buf[0]='\0';
	lmin=sec/60;
	if ((ltmp=(lmin/60/24)))
	{
		sprintf(buf, "%dt ", ltmp);
		lmin%=24*60;
	}
	ltmp=strlen(buf);
	sprintf(buf+ltmp, "%d:%02dh", lmin/60, lmin%60);
	return(buf);
}

void csmon_show_nick(void)
{
	int l;
	char buf[64], txt[16], *ptr;
	if (cs_uptime)
		snprintf(ptr=buf, sizeof(buf)-1, "%s - %s",
			server[cur_server].label, csmon_sec2disp(cs_uptime, txt));
	else
		ptr=server[cur_server].label;
	desc.width = desc.height = 32;
	l=16+(GetStringLen(ptr)>>1);
	if (l>250) l=250;
	RenderBox((mwidth/2-20)-l, 0, (mwidth/2+20)+l, 30, FILL, NGDARK);
	RenderBox((mwidth/2-20)-l, 0, (mwidth/2+20)+l, 30, GRID, ORANGE);
	PaintIcon(icon_ni,(mwidth/2-16)-l,3);
	RenderString(ptr, (mwidth/2)-l, 23, l<<1, CENTER , BIG, WHITE);
	//PaintIcon(icon_lock, 1, 1);
}

static int csmon_circol(int order, char *txt)
{
	int n;
	n=atoi(txt);
	if (order)
	{
		order=n;
		n=(order==0) ? 2 : (order<0) ? 1 : 0;
	}
	switch(n)
	{
		case  0: n=GREEN ; break;
		case  1: n=YELLOW  ; break;
		default: n=RED   ; break;
	}
	return(n);
}

static void csmon_show_client(int idx, int y, int siz)
{
	int i, col, label;
	int p1[]={153, 269, 369, 485, 551, 625, 790, 610};
	if (!slim)
	{
		p1[0]=200;
		p1[1]=360;
		p1[2]=460;
		p1[4]=1000;
		p1[5]=720;
		p1[6]=920;
	}

	int p2[8];
	char buf[128], ctype[8], *user, *nrtxt;
	col=WHITE;

	if ((label=(idx<0)))
	{
		idx=MAXCLIENTS;
		tptr[idx][0]="PID";
		tptr[idx][1]="Typ";
		tptr[idx][2]="Nr";
		tptr[idx][3]="Benutzer";
		tptr[idx][4]="AU";
		tptr[idx][5]="Crypted";
		tptr[idx][6]="IP";
		tptr[idx][7]="Port";
		tptr[idx][8]="Protokoll";
		tptr[idx][11]="Online";
		tptr[idx][13]="Sender";
		tptr[idx][14]="Idle";
		tptr[idx][15]="On";
		tptr[idx][23]="Time";
		col=ORANGE;
	}
	for (i=0; i<7; i++)
		p2[i]=(siz==BIG) ? p1[i] : p1[0]+((p1[i]-p1[0])*3/4);
	sprintf(buf, "%s:%s", tptr[idx][6], tptr[idx][7]);
	user=(*tptr[idx][3]) ? tptr[idx][3] : "anonym";
	switch(*tptr[idx][1])
	{
		case 'm': 
		case 'c': nrtxt=tptr[idx][/*2*/0]; break;
		case 'p': 
		case 'r': sprintf(nrtxt=ctype, "%c%02d", *tptr[idx][1], atoi(tptr[idx][2])); break;
		default : nrtxt=tptr[idx][1];
	}

	if (syspage)
	{
		RenderString(label ? tptr[idx][1] : nrtxt	, 13, y, 45, LEFT, siz, col);
	}
	else
	{
		//RenderString(label ? tptr[idx][2] : nrtxt	,  4, y, 24, RIGHT, siz, col);
		if(label)
			RenderString(tptr[idx][0]		,  4+4, y, 95, LEFT, siz, col);
		else
			RenderString(nrtxt			,  4, y, 95, LEFT, siz, col);

		if (label)
			RenderString(tptr[idx][15]		, !slim? 112 : 92, y, 28, RIGHT, siz, col);
		else
			RenderCircle(!slim? 124 : 104, y-15, csmon_circol(0, tptr[idx][15]));

	}
	if (label)
		RenderString(tptr[idx][4]			, !slim? 138 : 118, y, 28, RIGHT, siz, col);
	else
	{
		int c;
		switch(*tptr[idx][1])
		{
			case 's': case 'l':
			case 'n': case 'm':	c=GRAY; break;
			default :		c=csmon_circol(1, tptr[idx][4]);
		}
		RenderCircle(!slim? 148 : 128, y-15, c);
	}
	//sprintf(buf, "xres=%i", !slim ? 1 : 0);
	//RenderString(buf					,800 ,y ,110, LEFT , siz, col);
	RenderString(user					, p2[0] ,y , !slim? 150 : 110, LEFT , siz, col);
	RenderString(tptr[idx][8]				, p2[1] ,y , 100, LEFT , siz, col);
	if ((mode2) && (siz==BIG))
	{
		RenderString(buf				, p2[2] ,y , 180, LEFT , siz, col);
	}
	else
		RenderString(tptr[idx][13]			, p2[2] ,y , !slim? 240 : 175, LEFT , siz, col);
	if (label)
	{
		RenderString(tptr[idx][syspage ? 14 : 11]	, p2[4] ,y ,  70, LEFT , siz, col);
	}
	else
	{
		RenderString(csmon_sec2disp(atoi(tptr[idx][syspage ? 14 : 11]), buf)
								, p2[4] ,y ,  70, LEFT , siz, WHITE);
	}
	if (siz==SMALL || !slim)
	{
		sprintf(buf, "%s:%s", tptr[idx][6], tptr[idx][7]);
		RenderString(buf				, p2[5] ,y , 180, LEFT , siz, col);

		if (label)
			RenderString(tptr[idx][23]		, p2[6] ,y ,  70, LEFT , siz, col);
		else
			RenderString(tptr[idx][23]		, p2[6] ,y ,  70, LEFT , siz, WHITE);
	}
}

static int csmon_chk_client(int idx)
{
	if (syspage==1)
		return((*tptr[idx][1]!='c') && (*tptr[idx][1]!='m'));
	else
		return((*tptr[idx][1]=='c')||((*tptr[idx][1]=='m') && (!hidemonitor)));
}

static void csmon_show_clients(void)
{
	int i, nr, h, zy, siz, lsiz;
	for (i=nr=0; tptr[i][0]; i++)
		if (csmon_chk_client(i)) nr++;
	h=20;
	if (smallfont || (slim))
		lsiz=SMALL;
	else
		lsiz=BIG;
	if ((nr>10) || (smallfont))
	{
		zy=20;
		siz=SMALL;
		logwy=h+17+(nr+1)*zy;
	}
	else
	{
		zy=30;
		siz=BIG;
		logwy=h+20+(nr+1)*zy;
	}
	memset(lbb, 0, fbsize);
	RenderBox(0, h, mwidth-1, h+12+(nr+1)*zy, FILL, NGDARK);
	RenderBox(0, h, mwidth-1, h+12+(nr+1)*zy, GRID, ORANGE);
	h+=(siz==BIG)?1:4;
	csmon_show_client(-1, h+zy, siz);
	csmon_show_nick();
	for (i=0, nr=1; (tptr[i][0]) && (nr<21); i++)
		if (csmon_chk_client(i))
		{
			nr++;
			csmon_show_client(i, h+nr*zy, siz);
		}
	csmon_show_log(1, lsiz);
}

static void csmon_add_log(char *txt)
{
	strncpy(logbuf[lbidx], txt, 127);
	lbidx=(lbidx+1) & 0x1f;
}

static int add_trace(char *log)
{
	char txt[512];
	FILE *fd;
	sprintf(txt,"%s\n", log);
	if((fd = fopen("/tmp/oscammon.log", "a"))) 
	{
		fputs(txt, fd);
		fclose(fd);
		printf("%s",txt);
	}
	
}

static void csmon_chk_receive(void)
{
	int rflog, rfclient, siz, lsiz;
	char txt[512];

	if (smallfont)
		siz=SMALL;
	else
		siz=BIG;

	if (smallfont || (slim))
		lsiz=SMALL;
	else
		lsiz=BIG;

	if (sfd)
	{
		rflog=rfclient=0;
		while (csmon_gets(txt, 0))
		{
			//printf("empfang: {%s}\n", txt);
			if ((strlen(txt)<8)||(txt[0]!='[')||(txt[7]!=']')) continue;
			switch (txt[1])
			{
				case 'D': csmon_add_log(txt); //details
					 rflog=1;
					 break;
				case 'L': csmon_add_log(txt+19);
					if(trace) add_trace(txt);
					rflog=1;
					break;
				case 'U': csmon_add_log(txt); //getuser
					rflog=1;
					break;
				case 'V': csmon_add_log(txt);
					rflog=1;
					break;
				case 'I': rfclient=csmon_add_client(txt);
					break;
			}
		}
		if (rfclient) csmon_show_clients();
		else if (rflog) csmon_show_log(0, lsiz);
	}
}

static int csmon_chk_rc(long rccode)
{
	static int new_server=0;
	int ok;

	switch(rccode)
	{
		case RC_HOME:
			if (px1)	// active popup
				csmon_popup_close();	// close popup
			else
				return(1);	// exit flag
			break;

		case RC_HELP:
			if (px1)	// active popup
			{
				csmon_popup_close();
				csmon_helpscreen2();
			}
			else
				csmon_helpscreen();
			break;

		case RC_STANDBY:
			csmon_send("shutdown");
			break;

		case RC_UP:
		case RC_DOWN:
			if (num_server<2) return(0);
			for (ok=0; !ok;)
			{
				new_server+=(rccode==RC_UP) ? 1 : num_server-1;
				new_server%=num_server;
				ok=((server[new_server].name) && (server[new_server].port));
				if (new_server==cur_server) ok=1;
			}
			if (new_server==cur_server) return(1);
			cur_server=new_server;
			logsent=0;
			csmon_disconnect();
			break;

		case RC_LEFT:
		case RC_RIGHT:
			mode2^=1;
			logsent=0;
			break;
		case RC_MUTE:
			hidemonitor^=1;
			logsent=0;
			break;
		case RC_RED:
			syspage=0;
			logsent=0;
			break;
		case RC_GREEN:
			syspage=1;
			logsent=0;
			break;
		case RC_MINUS:
			if (!smallfont)
			{
				smallfont=1;
				logsent=0;
			}
			break;
		case RC_PLUS:
			if (smallfont)
			{
				smallfont=0;
			logsent=0;
			}
			break;

		case RC_YELLOW:
			csmon_send("details");
			break;
		case RC_BLUE:
			if (trace)
			{
				csmon_add_log("USERMSG=Trace Log off");
				csmon_show_clients();
				trace=0;
			}
			else
			{
				trace=1;
				csmon_add_log("USERMSG=Trace Log on");
				csmon_show_clients();
			}
			break;
		case RC_PLAY:
			csmon_send("restart");
			break;
		case RC_FORWARD:
			csmon_send("getuser");
			break;
		case RC_REWIND:
			csmon_send("reread");
			break;
		case RC_1:
			csmon_send("debug 0");
			break;
		case RC_2:
			csmon_send("debug 63");
			break;
		case RC_3:
			csmon_send("debug 255");
			break;
	}
	return(0);
}

void read_neutrino_osd_conf(int *ex,int *sx,int *ey, int *sy)
{
	const char *filename="/var/tuxbox/config/neutrino.conf";
	const char spres[][4]={"","crt","lcd"};
	char sstr[4][32];
	int pres=-1, resolution=-1, loop, *sptr[4]={ex, sx, ey, sy};
	char *buffer;
	size_t len;
	ssize_t read;
	FILE* fd;

	fd = fopen(filename, "r");
	if(fd){
		buffer=NULL;
		len = 0;
		while ((read = getline(&buffer, &len, fd)) != -1){
			sscanf(buffer, "screen_preset=%d", &pres);
			sscanf(buffer, "osd_resolution=%d", &resolution);
		}
		if(buffer)
			free(buffer);
		rewind(fd);
		++pres;
		sprintf(sstr[0], "screen_EndX_%s_%d=%%d", spres[pres], resolution);
		sprintf(sstr[1], "screen_StartX_%s_%d=%%d", spres[pres], resolution);
		sprintf(sstr[2], "screen_EndY_%s_%d=%%d", spres[pres], resolution);
		sprintf(sstr[3], "screen_StartY_%s_%d=%%d", spres[pres], resolution);

		buffer=NULL;
		len = 0;
		while ((read = getline(&buffer, &len, fd)) != -1){
			for(loop=0; loop<4; loop++) {
				sscanf(buffer, sstr[loop], sptr[loop]);
			}
		}
		fclose(fd);
		if(buffer)
			free(buffer);
	}
}

/******************************************************************************
 * init
 ******************************************************************************/


static int csmon_init()
{
	int sx, ex, sy, ey;
	FT_Error error;
	//struct stat chkstat;

	//show versioninfo
	csmon_log("NI-Edition OSCAM-Monitor version %s\n", monver);
	csmon_log("hardware coolstream\n");

	//get params
	fb = rc = lcd = sx = ex = sy = ey = -1;

	// open Framebuffer
	fb=open("/dev/fb/0", O_RDWR);
      
	// open Remote Control
	rc = open("/dev/input/nevis_ir", O_RDONLY);
	if(rc == -1) {
		csmon_log("error open remote control\n");
		exit(1);
	}

	//init framebuffer

	if (ioctl(fb, FBIOGET_FSCREENINFO, &fix_screeninfo) == -1)
	{
		csmon_log("<FBIOGET_FSCREENINFO failed>\n");
		return(1);
	}

	if (ioctl(fb, FBIOGET_VSCREENINFO, &var_screeninfo) == -1)
	{
		csmon_log("<FBIOGET_VSCREENINFO failed>\n");
		return(1);
	}

	fbsize=fix_screeninfo.line_length*var_screeninfo.yres;


	if (!(lfb = (unsigned char*)mmap(0, fix_screeninfo.smem_len, PROT_READ | PROT_WRITE, MAP_SHARED, fb, 0)))
	{
		csmon_log("<mapping of Framebuffer failed>\n");
		return(1);
	}

	//init fontlibrary

	if ((error = FT_Init_FreeType(&library)))
	{
		csmon_log("<FT_Init_FreeType failed with Errorcode 0x%.2X>", error);
		munmap(lfb, fix_screeninfo.smem_len);
		return(1);
	}

	if ((error = FTC_Manager_New(library, 1, 2, 0, &MyFaceRequester, NULL, &manager)))
	{
		csmon_log("<FTC_Manager_New failed with Errorcode 0x%.2X>\n", error);
		FT_Done_FreeType(library);
		munmap(lfb, fix_screeninfo.smem_len);
		return(1);
	}

	if ((error = FTC_SBitCache_New(manager, &cache)))
	{
		csmon_log("<FTC_SBitCache_New failed with Errorcode 0x%.2X>\n", error);
		FTC_Manager_Done(manager);
		FT_Done_FreeType(library);
		munmap(lfb, fix_screeninfo.smem_len);
		return(1);
	}

	if((error = FTC_Manager_LookupFace(manager, fontpath, &face)))
	{
		csmon_log("<FTC_Manager_Lookup_Face failed with Errorcode 0x%.2X>\n", error);
		FTC_Manager_Done(manager);
		FT_Done_FreeType(library);
		munmap(lfb, fix_screeninfo.smem_len);
		return(1);
	}

	use_kerning = FT_HAS_KERNING(face);

	desc.face_id = fontpath;

	desc.flags = FT_LOAD_MONOCHROME;


	//init backbuffer
	lbb = malloc(3*fbsize);
	if (!lbb)
	{
		csmon_log("<memory allocating failed>\n");
		FTC_Manager_Done(manager);
		FT_Done_FreeType(library);
		munmap(lfb, fix_screeninfo.smem_len);
		return(1);
	}
	lbb0 = lbb;
	lbb1 = lbb+fbsize;
	lbb2 = lbb+(fbsize<<1);

	memset(lbb, 0, 3*fbsize);

	read_neutrino_osd_conf(&ex,&sx,&ey,&sy);
	if((ex == -1) || (sx == -1) || (ey == -1) || (sy == -1))
	{
		sx = 40;
		ex = var_screeninfo.xres - 40;
		sy = 40;
		ey = var_screeninfo.yres - 40;
	}

	if (fb == -1 || rc == -1 || sx == -1 || ex == -1 || sy == -1 || ey == -1)
	{
		csmon_log("<missing Param(s)>\n");
		return(1);
	}

	//startx = sx + (((ex-sx) - 620)/2);
	//starty = sy + (((ey-sy) - 505)/2);
	//ex=693, sx=29, ey=535, sy=43, startx=51, starty=37 var_screeninfo.xres=720, var_screeninfo.yres=576
	mwidth = ex-sx - 40;
	if (var_screeninfo.xres < 1280)
		slim=1;

	//mwidth = 620;
	startx = sx + (((ex-sx) - mwidth)/2);
	starty = sy + (((ey-sy) - 505)/2);
	return(0);
}

/******************************************************************************
 * plugin_exec
 ******************************************************************************/

int main()
{
	long rccode=(-1);

	csmon_read_config();

	if (csmon_init()) return;

	csmon_disconnect();

	if (!num_server)
		csmon_message(1, "Konfiguration", "Kein Server definiert");
	else if (csmon_getpin(pin)) while (1)
	{
		struct timeval tv;
		fd_set fds;

		if (csmon_chkcon(cur_server)>0)
		{
			time_t timenow;
			if ((timenow=time(NULL))>logsent+3)
			{
				csmon_send("status");
				csmon_send("log on");
				logsent=timenow;
			}
		}

		tv.tv_sec = 3;
		tv.tv_usec = 0;
		FD_ZERO(&fds);
		if (sfd) FD_SET(sfd, &fds);
		FD_SET(rc, &fds);
		select(((sfd>rc) ? sfd : rc)+1, &fds, 0, 0, &tv);

		if ((FD_ISSET(rc, &fds)) && ((rccode=csmon_getrc())>=0))
			if (csmon_chk_rc(rccode))
				break;

		if (sfd && FD_ISSET(sfd, &fds))
			csmon_chk_receive();
	}

	csmon_disconnect();
	close(fb);
	close(rc);
	FTC_Manager_Done(manager);
	FT_Done_FreeType(library);
	free(lbb);
	munmap(lfb, fix_screeninfo.smem_len);
	return;
}
