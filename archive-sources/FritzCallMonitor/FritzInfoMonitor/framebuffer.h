
#ifndef __framebuffer_h__
#define __framebuffer_h__

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <stdint.h>
#include <linux/fb.h>

/* freetype stuff */
#define FONT "/share/fonts/pakenham.ttf"

#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_CACHE_H
#include FT_CACHE_SMALL_BITMAPS_H

#if ((defined(FREETYPE_MAJOR)) && (((FREETYPE_MAJOR == 2) && (((FREETYPE_MINOR == 1) && (FREETYPE_PATCH >= 9)) || (FREETYPE_MINOR > 1))) || (FREETYPE_MAJOR > 2)))
#define FTC_Manager_Lookup_Face FTC_Manager_LookupFace
#define _FTC_SBit_Cache_Lookup(a,b,c,d)	FTC_SBitCache_Lookup(a,b,c,d,NULL)
#else
#define _FTC_SBit_Cache_Lookup(a,b,c,d)	FTC_SBit_Cache_Lookup(a,b,c,d)
#endif


class Cfb
{
	public:
		Cfb();
		~Cfb();
		static Cfb* getInstance();

		int	init();
		int	RenderChar(FT_ULong currentchar, int sx, int sy, int ex, int color);
		int	GetStringLen(const char *string);
		void	RenderString(const char *string, int sx, int sy, int maxwidth, int layout, int size, int color);
		void	RenderBox(int sx, int sy, int ex, int ey, int mode, int color);
		void	RenderCircle(int sx, int sy, int color);
		void	HorLine(int x, int y, int l, int color);
		void	SetPixel(int x, int y, int c);
		void	PaintIcon(unsigned char *icon, int sx, int sy);
		void	FBPaint(void);
		void	FBClear(void);
		void	Cleanup (void);

		int	GetRCCode();

		virtual void getDimensions(int* fb_ex, int* fb_sx, int* fb_ey, int* fb_sy){*fb_ex=ex; *fb_sx=sx; *fb_ey=ey; *fb_sy=sy;};
		virtual void getStartDimensions(int* fb_startx, int* fb_starty){*fb_startx=startx; *fb_starty=starty;};
		virtual int getYScreeninfo(){return var_screeninfo.yres;};

	private:
		CParser *	cpars;

		int	fb, startx, starty, sx, ex, sy, ey;

		struct fb_fix_screeninfo fix_screeninfo;
		struct fb_var_screeninfo var_screeninfo;
		unsigned char *lfb, *lbb;

		FT_Library		library;
		FTC_Manager		manager;
		FTC_SBitCache		cache;
		FTC_SBit		sbit;
		FTC_ImageTypeRec	desc;
		FT_Face			face;
		FT_UInt			prev_glyphindex;
		FT_Bool			use_kerning;

		static	FT_Error MyFaceRequester(FTC_FaceID face_id, FT_Library library, FT_Pointer request_data, FT_Face *aface);

		struct rawHeader
		{
			uint8_t width_lo;
			uint8_t width_hi;
			uint8_t height_lo;
			uint8_t height_hi;
			uint8_t transp;
		} __attribute__ ((packed));
};

#endif //__framebuffer_h__