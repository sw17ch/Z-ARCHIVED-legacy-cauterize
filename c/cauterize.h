#ifndef CAUTERIZE_H
#define CAUTERIZE_H

#include <stdint.h>
#include <stddef.h>

typedef uint32_t CAUTERIZE_STATUS_T;

#define CA_OK                    (0)
#define CA_ERR_ASSERT            (1)
#define CA_ERR_NOT_ENOUGH_SPACE  (2)
#define CA_ERR_NOT_ENOUGH_DATA   (3)
#define CA_ERR_GENERAL           (UINT32_MAX)

struct Cauterize {
  size_t size; // Size of the buffer in bytes
  size_t used; // Number of used bytes in the buffer
  size_t pos; // The next byte to be read
  uint8_t * buffer; // Buffer to hold data
};

CAUTERIZE_STATUS_T CauterizeInit(struct Cauterize * m, uint8_t * buffer, size_t length);
CAUTERIZE_STATUS_T CauterizeAppend(struct Cauterize * m, uint8_t * src, size_t length);
CAUTERIZE_STATUS_T CauterizeRead(struct Cauterize * m, uint8_t * dst, size_t length);


#endif /* CAUTERIZE_H */
