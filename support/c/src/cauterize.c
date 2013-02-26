#define CAUTERIZE_C

#include "cauterize.h"
#include "cauterize_util.h"
#include "cauterize_debug.h"

#include <string.h>

#define S CALLCONV CAUTERIZE_STATUS_T DLLDECL
#define T struct Cauterize


S CauterizeInitAppend( struct Cauterize * m, uint8_t * buffer, size_t length)
{
  CA_ASSERT(NULL != m);
  CA_ASSERT(NULL != buffer);

  m->size = length;
  m->used = 0;
  m->pos = 0;
  m->buffer = buffer;

  return CA_OK;
}

S CauterizeInitRead( struct Cauterize * m, uint8_t * buffer, size_t used)
{
  CA_ASSERT(NULL != m);
  CA_ASSERT(NULL != buffer);

  m->size = used;
  m->used = used;
  m->pos = 0;
  m->buffer = buffer;

  return CA_OK;
}

S CauterizeAppend(T * m, uint8_t * src, size_t length)
{
  CA_ASSERT(NULL != m);
  CA_ASSERT(NULL != src);

  size_t needed = m->used + length;

  if (needed > m->size)
    return CA_ERR_NOT_ENOUGH_SPACE;

  uint8_t * dest = &m->buffer[m->used];
  memcpy(dest, src, length);
  m->used += length;

  return CA_OK;
}

S CauterizeRead(T * m, uint8_t * dst, size_t length)
{
  CA_ASSERT(NULL != m);
  CA_ASSERT(NULL != dst);
  CA_ASSERT(m->used >= m->pos);

  size_t available = m->used - m->pos;

  if (length > available)
    return CA_ERR_NOT_ENOUGH_DATA;

  uint8_t * src = &m->buffer[m->pos];
  memcpy(dst, src, length);
  m->pos += length;

  return CA_OK;
}

#undef S
#undef T
#undef CAUTERIZE_C
