
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/mman.h>

#include "parser.h"
#include "globals.h"

#include "framebuffer.h"

const char circle[]={
	9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
	9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
	9,9,1,1,1,1,1,1,1,1,1,1,1,9,9,
	9,9,1,1,1,1,1,1,1,1,1,1,1,9,9,
	9,9,1,1,1,1,1,1,1,1,1,1,1,9,9,
	9,9,1,1,1,1,1,1,1,1,1,1,1,9,9,
	9,9,1,1,1,1,1,1,1,1,1,1,1,9,9,
	9,9,1,1,1,1,1,1,1,1,1,1,1,9,9,
	9,9,1,1,1,1,1,1,1,1,1,1,1,9,9,
	9,9,1,1,1,1,1,1,1,1,1,1,1,9,9,
	9,9,1,1,1,1,1,1,1,1,1,1,1,9,9,
	9,9,1,1,1,1,1,1,1,1,1,1,1,9,9,
	9,9,1,1,1,1,1,1,1,1,1,1,1,9,9,
	9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
	9,9,9,9,9,9,9,9,9,9,9,9,9,9,9
};

Cfb* Cfb::getInstance()
{
	static Cfb* instance = NULL;
	if(!instance)
		instance = new Cfb();
	return instance;
}

Cfb::Cfb()
{
	cpars = CParser::getInstance();

	memset(&lfb, 0, sizeof(lfb));
	memset(&lbb, 0, sizeof(lbb));
}

Cfb::~Cfb()
{
	Cleanup();
}

int Cfb::init()
{
	FT_Error error;

	fb = sx = ex = sy = ey = -1;

	// open Framebuffer
	fb=open ( "/dev/fb/0", O_RDWR );

	// init framebuffer
	if(ioctl(fb, FBIOGET_FSCREENINFO, &fix_screeninfo) == -1)
	{
		printf("[%s] <FBIOGET_FSCREENINFO failed>\n",BASENAME);
		return(2);
	}

	if(ioctl(fb, FBIOGET_VSCREENINFO, &var_screeninfo) == -1)
	{
		printf("[%s] <FBIOGET_VSCREENINFO failed>\n",BASENAME);
		return(2);
	}

	if(!(lfb = (unsigned char*)mmap(0, fix_screeninfo.smem_len, PROT_READ | PROT_WRITE, MAP_SHARED, fb, 0)))
	{
		printf("[%s] <mapping of Framebuffer failed>\n",BASENAME);
		return(2);
	}

	// init fontlibrary
	if((error = FT_Init_FreeType(&library)))
	{
		printf("[%s] <FT_Init_FreeType failed with Errorcode 0x%.2X>",BASENAME, error);
		munmap(lfb, fix_screeninfo.smem_len);
		return(2);
	}

	if((error = FTC_Manager_New(library, 1, 2, 0, &MyFaceRequester, this, &manager)))
	{
		printf("[%s] <FTC_Manager_New failed with Errorcode 0x%.2X>\n",BASENAME, error);
		FT_Done_FreeType(library);
		munmap(lfb, fix_screeninfo.smem_len);
		return(2);
	}

	if((error = FTC_SBitCache_New(manager, &cache)))
	{
		printf("[%s] <FTC_SBitCache_New failed with Errorcode 0x%.2X>\n",BASENAME, error);
		FTC_Manager_Done(manager);
		FT_Done_FreeType(library);
		munmap(lfb, fix_screeninfo.smem_len);
		return(2);
	}

	if((error = FTC_Manager_Lookup_Face(manager, (char *)FONT, &face)))
	{
		printf("[%s] <FTC_Manager_Lookup_Face failed with Errorcode 0x%.2X>\n",BASENAME, error);
		FTC_Manager_Done(manager);
		FT_Done_FreeType(library);
		munmap(lfb, fix_screeninfo.smem_len);
		return(2);
	}

	use_kerning = FT_HAS_KERNING(face);

	desc.face_id = (char *)FONT;

	desc.flags = FT_LOAD_MONOCHROME;


	// init backbuffer
	if(!(lbb = (unsigned char*)malloc(fix_screeninfo.line_length*var_screeninfo.yres)))
	{
		printf("[%s] <allocating of Backbuffer failed>\n",BASENAME);
		FTC_Manager_Done(manager);
		FT_Done_FreeType(library);
		munmap(lfb, fix_screeninfo.smem_len);
		return(2);
	}

	// volle Bildschirmauflösung reservieren (Parameter: buffer, color, size in bytes)
	memset(lbb, 0, fix_screeninfo.line_length*var_screeninfo.yres);
	printf("[%s] - init: FB %dx%dx%d stride %d\n",BASENAME, var_screeninfo.xres, var_screeninfo.yres, var_screeninfo.bits_per_pixel, fix_screeninfo.line_length);;

	cpars->read_neutrino_osd_conf(&ex,&sx,&ey,&sy,NEUTRINOCONF);
	if((ex == -1) || (sx == -1) || (ey == -1) || (sy == -1))
	{
		sx = 80;
		ex = var_screeninfo.xres - 80;
		sy = 80;
		ey = var_screeninfo.yres - 80;
	}

	int mwidth = ex-sx;
	int mheight = ey-sy;

	//mwidth = 620;
	startx = sx + (((ex-sx) - mwidth)/2);
	starty = sy + (((ey-sy) - mheight)/2);

	//vyres = var_screeninfo.yres;

	return(0);
}

/******************************************************************************
 * MyFaceRequester
 ******************************************************************************/
FT_Error Cfb::MyFaceRequester(FTC_FaceID face_id, FT_Library library, FT_Pointer request_data, FT_Face *aface)
{
	FT_Error result;

	result = FT_New_Face(library, (char *)face_id, 0, aface);

	if(!result)
	{
		printf("[%s] - <Font \"%s\" loaded>\n",BASENAME, (char*)face_id);
	}
	else
	{
		printf("[%s] <Font \"%s\" failed>\n",BASENAME, (char*)face_id);
	}

	return result;
}

/******************************************************************************
 * RenderChar
 ******************************************************************************/
int Cfb::RenderChar(FT_ULong currentchar, int sx, int sy, int ex, int color)
{
	int row, pitch, bit, x = 0, y = 0;
	FT_Error error;
	FT_UInt glyphindex;
	FT_Vector kerning;
	FTC_Node anode;

	//load char
	if(!(glyphindex = FT_Get_Char_Index(face, currentchar)))
	{
		printf("[%s] <FT_Get_Char_Index for Char \"%#.2X\" failed: \"undefined character code\">\n",BASENAME, (int)currentchar);
		return 0;
	}

	if((error = FTC_SBitCache_Lookup(cache, &desc, glyphindex, &sbit, &anode)))
	{
		printf("[%s] <FTC_SBitCache_Lookup for Char \"%#.2X\" failed with Errorcode 0x%.2X>\n",BASENAME, (int)currentchar, error);
		return 0;
	}

	if(use_kerning)
	{
		FT_Get_Kerning(face, prev_glyphindex, glyphindex, ft_kerning_default, &kerning);

		prev_glyphindex = glyphindex;
		kerning.x >>= 6;
	}
	else
	{
		kerning.x = 0;
	}

	// render char
	if(color != -1) /* don't render char, return charwidth only */
	{
		if(sx + sbit->xadvance >= ex)
		{
			return -1; /* limit to maxwidth */
		}

		for(row = 0; row < sbit->height; row++)
		{
			for(pitch = 0; pitch < sbit->pitch; pitch++)
			{
				for(bit = 7; bit >= 0; bit--)
				{
					if(pitch*8 + 7-bit >= sbit->width)
					{
						break; /* render needed bits only */
					}

					if((sbit->buffer[row * sbit->pitch + pitch]) & 1<<bit)
					{
						memcpy ( lbb + startx*4 + sx*4 + ( sbit->left + kerning.x + x ) *4 + fix_screeninfo.line_length* ( starty + sy - sbit->top + y ),cpars->bgra[color],4 );
					}

					x++;
				}
			}

			x = 0;
			y++;
		}
	}

	// return charwidth
	return sbit->xadvance + kerning.x;
}

/******************************************************************************
 * GetStringLen
 ******************************************************************************/
int Cfb::GetStringLen(const char *string)
{
	int stringlen = 0;

	// reset kerning

		prev_glyphindex = 0;

	// calc len

		while(*string != '\0')
		{
			stringlen += RenderChar(*string, -1, -1, -1, -1);
			string++;
		}

	return stringlen;
}

/******************************************************************************
 * RenderString
 ******************************************************************************/
void Cfb::RenderString(const char *string, int sx, int sy, int maxwidth, int layout, int size, int color)
{
	int stringlen, ex, charwidth;

	// set size

		if(size == SMALL)
		{
			desc.width = desc.height = 26;
		}
		else if(size == NORMAL)
		{
			desc.width = desc.height = 32;
		}
		else
		{
			desc.width = desc.height = 40;
		}

	// set alignment

		if(layout != LEFT)
		{
			stringlen = GetStringLen(string);

			switch(layout)
			{
				case CENTER:
					if(stringlen < maxwidth)
					{
						sx += (maxwidth - stringlen)/2;
					}

					break;

				case RIGHT:

					if(stringlen < maxwidth)
					{
						sx += maxwidth - stringlen;
					}
			}
		}

	// reset kerning

		prev_glyphindex = 0;

	// render string

		ex = sx + maxwidth;

		while(*string != '\0')
		{
			if((charwidth = RenderChar(*string, sx, sy, ex, color)) == -1)
			{
				return; /* string > maxwidth */
			}

			sx += charwidth;
			string++;
		}
}

/******************************************************************************
 * RenderBox
 ******************************************************************************/
void Cfb::RenderBox(int sx, int sy, int ex, int ey, int mode, int color)
{
	int loop;

	if(mode == FILL)
	{
		for(; sy <= ey; sy++)
		{
			HorLine(sx, sy, ex-sx+1, color);
		}
	}
	else
	{
		// hor lines
		for(loop = sx; loop <= ex; loop++)
		{
			SetPixel(loop, sy  , color);
			SetPixel(loop, sy+1, color);
			SetPixel(loop, ey-1, color);
			SetPixel(loop, ey  , color);  
		}

		// ver lines
		for(loop = sy; loop <= ey; loop++)
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
void Cfb::RenderCircle(int sx, int sy, int color)
{
	int x, y;

	for (y=0; y<15; y++)
		for (x=0; x<15; x++)
			if (circle[x+y*15])
			{
				if (circle[x+y*15] == 1)
					SetPixel(sx + x, sy + y, color);
				else
					SetPixel(sx + x, sy + y, (int)circle[x+y*15]);
			}
}

/******************************************************************************
 * HorLine / SetPixel / PaintIcon
 ******************************************************************************/
//#define SetPixel(x, y, c)  memcpy(lbb + ((startx + (x))<<2) + fix_screeninfo.line_length*(starty + (y)), bgra[c], 4)
void Cfb::HorLine(int x, int y, int l, int color)
{
	for (l+=x; x<l; x++)
		SetPixel(x, y, color);
}

void Cfb::SetPixel(int x, int y, int c)
{
	memcpy(lbb + ((startx + (x))<<2) + fix_screeninfo.line_length*(starty + (y)), cpars->bgra[c], 4);
}

void Cfb::PaintIcon(unsigned char *icon, int sx, int sy)
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

void Cfb::FBPaint(void)
{
	memcpy(lfb, lbb, fix_screeninfo.line_length*var_screeninfo.yres);
}

void Cfb::FBClear(void)
{
	RenderBox(0, 0, ex-sx, ey-sy, FILL, 0);
}

/******************************************************************************
 * Cleanup
 ******************************************************************************/
void Cfb::Cleanup (void)
{
	FTC_Manager_Done(manager);
	FT_Done_FreeType(library);

	free(lbb);
	munmap(lfb, fix_screeninfo.smem_len);

	close(fb);
}

