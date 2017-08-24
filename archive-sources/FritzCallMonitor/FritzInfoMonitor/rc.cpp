
#include <fcntl.h>
#include <unistd.h>
#include <cstdio> 
#include <cstdlib>

#include "globals.h"

#include "rc.h"

Crc* Crc::getInstance()
{
	static Crc* instance = NULL;
	if(!instance)
		instance = new Crc();
	return instance;
}

Crc::Crc()
{
	rc = -1;

	/* open Remote Control */
	rc = open ( "/dev/input/nevis_ir", O_RDONLY );
	if ( rc == -1 )
	{
		perror ( "<open remote control>" );
		exit ( 1 );
	}

	// lock keyboard-conversions, this is done by the plugin itself
	fclose(fopen(KBLCKFILE,"w"));
}

Crc::~Crc()
{
	Cleanup();
}


void Crc::Cleanup (void)
{
	// enable keyboard-conversion again
	unlink(KBLCKFILE);

	close(rc);
}

long Crc::getrc()
{
	//get rc socket
	fd_set fds;
	FD_ZERO(&fds);
	FD_SET(rc, &fds);
	select(rc+1, &fds, 0, 0, 0);
	if (FD_ISSET(rc, &fds))
		return(GetRCCode());
	else
		return(-1);
}

int Crc::GetRCCode()
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
					case KEY_EXIT:		rcc=RC_HOME;	break;
					case KEY_HOME:		rcc=RC_HOME;	break;
					case KEY_PAGEUP:	rcc=RC_PAGEUP;	break;
					case KEY_PAGEDOWN:	rcc=RC_PAGEDOWN;break;
					case KEY_POWER:		rcc=RC_STANDBY;
				}
			}
		}
		else
			rc_last_key=KEY_RESERVED;
	}
	return(rcc);
}