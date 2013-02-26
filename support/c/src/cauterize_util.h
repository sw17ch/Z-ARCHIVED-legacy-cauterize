#ifndef CAUTERIZE_UTIL_H
#define CAUTERIZE_UTIL_H

#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))
#define MIN(a, b) (((a) < (b)) ? (a) : (b))

/* Buidling Cauterize files as a DLL. */

#if defined(BUILDING_DLL)
#define DLLDECL __declspec(dllexport)
#elif defined(USING_DLL)
#define DLLDECL __declspec(dllimport)
#else
#define DLLDECL
#endif

#if defined(_WIN32)
#define CALLCONV __stdcall
#else
#define CALLCONV
#endif

#endif /* CAUTERIZE_UTIL_H */
