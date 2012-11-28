#ifndef CAUTERIZE_H
#define CAUTERIZE_H

#include <stdint.h>
#include <stddef.h>

typedef uint32_t CAUTERIZE_STATUS_T;

#define MS_OK                    (0)
#define MS_ERR_ASSERT            (1)
#define MS_ERR_NOT_ENOUGH_SPACE  (2)
#define MS_ERR_NOT_ENOUGH_DATA   (3)
#define MS_ERR_GENERAL           (UINT32_MAX)

struct Marshal {
  size_t size; // Size of the buffer in bytes
  size_t used; // Number of used bytes in the buffer
  size_t pos; // The next byte to be read
  uint8_t * buffer; // Buffer to hold data
};

CAUTERIZE_STATUS_T MarshalInit(struct Marshal * m, uint8_t * buffer, size_t length);
CAUTERIZE_STATUS_T MarshalAppend(struct Marshal * m, uint8_t * src, size_t length);
CAUTERIZE_STATUS_T MarshalRead(struct Marshal * m, uint8_t * dst, size_t length);


#endif /* CAUTERIZE_H */
