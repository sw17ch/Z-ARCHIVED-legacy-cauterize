#ifndef CAUTERIZE_UTIL_H
#define CAUTERIZE_UTIL_H

#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))
#define MIN(a, b) (((a) < (b)) ? (a) : (b))

/* Buidling Cauterize files as a DLL. */

#if defined(BUILDING_DLL) || defined(USING_DLL)
  #if !defined(_WIN32)
    #error "Can only build DLL in Windows."
  #endif

  #define CALLCONV __stdcall
#endif

#if defined(BUILDING_DLL)
  #define DLLDECL __declspec(dllexport)
#elif defined(USING_DLL)
  #define DLLDECL __declspec(dllimport)
#endif

#ifndef DLLDECL
#define DLLDECL
#endif

#ifndef CALLCONV
#define CALLCONV
#endif

#endif /* CAUTERIZE_UTIL_H */
