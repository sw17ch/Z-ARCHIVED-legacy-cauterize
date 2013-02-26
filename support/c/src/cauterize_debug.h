#ifndef CAUTERIZE_DEBUG_H
#define CAUTERIZE_DEBUG_H

#ifndef CAUTERIZE_C
  #error "You should not include cauterize_debug.h."
#endif

#ifndef NDEBUG

#include <stdio.h>
#define CA_ASSERT_PRINT(msg) \
  fprintf(stderr, "ASSERT: %s (%s:%d)\n", msg, __FILE__, __LINE__);

#define CA_ASSERT(cond) CA_ASSERTm(#cond, cond)
#define CA_ASSERTm(msg, cond) \
  do { \
    if(!(cond)) { \
      CA_ASSERT_PRINT(msg); \
      return CA_ERR_ASSERT; \
    } \
  } while(0)

#else

#define CA_ASSERT(cond)

#endif

#endif /* CAUTERIZE_DEBUG_H */
