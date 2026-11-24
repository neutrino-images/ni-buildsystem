/*
 * Native window of the Mali fbdev EGL platform (libMali.so of the HiSilicon
 * boxes): what eglCreateWindowSurface() takes as EGLNativeWindowType.
 * The driver archive ships no headers; Qt's eglfs_mali integration builds
 * the same structure itself, its configure test only needs this name.
 */

#ifndef _FBDEV_WINDOW_H_
#define _FBDEV_WINDOW_H_

#ifdef __cplusplus
extern "C" {
#endif

typedef struct fbdev_window
{
	unsigned short width;
	unsigned short height;
} fbdev_window;

#ifdef __cplusplus
}
#endif

#endif /* _FBDEV_WINDOW_H_ */
