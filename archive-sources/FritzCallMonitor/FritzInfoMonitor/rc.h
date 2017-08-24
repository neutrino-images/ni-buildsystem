
#ifndef __rc_h__
#define __rc_h__

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

//rc stuff
#include <linux/input.h>

class Crc
{
	public:
		Crc();
		~Crc();
		static Crc* getInstance();

		long int getrc();
		void Cleanup (void);
	private:
		int	rc;
		struct input_event ev;

		int GetRCCode();
};
#endif
