#ifndef CAUTERIZE_H
#define CAUTERIZE_H

#include <stdint.h>
#include <stddef.h>

#include "cauterize_util.h"

typedef enum cauterize_status {
  CA_OK                    = 0,
  CA_ERR_ASSERT            = 1,
  CA_ERR_NOT_ENOUGH_SPACE  = 2,
  CA_ERR_NOT_ENOUGH_DATA   = 3,
  CA_ERR_INVALID_LENGTH    = 4,
  CA_ERR_INVALUD_TYPE_TAG  = 5,
  CA_ERR_INVALID_ENUM_VAL  = 6,
  CA_ERR_GENERAL           = UINT32_MAX,
} CAUTERIZE_STATUS_T;

struct Cauterize {
  size_t size; // Size of the buffer in bytes
  size_t used; // Number of used bytes in the buffer
  size_t pos; // The next byte to be read
  uint8_t * buffer; // Buffer to hold data
};

#ifdef __cplusplus
extern "C" {
#endif

CALLCONV CAUTERIZE_STATUS_T DLLDECL CauterizeInitAppend(
    struct Cauterize * m,
    uint8_t * buffer,
    size_t length);

CALLCONV CAUTERIZE_STATUS_T DLLDECL CauterizeInitRead(
    struct Cauterize * m,
    uint8_t * buffer,
    size_t used);

CALLCONV CAUTERIZE_STATUS_T DLLDECL CauterizeAppend(
    struct Cauterize * m,
    uint8_t * src,
    size_t length);

CALLCONV CAUTERIZE_STATUS_T DLLDECL CauterizeRead(
    struct Cauterize * m,
    uint8_t * dst,
    size_t length);

#ifdef __cplusplus
}
#endif

#define CA_MAX(a,b) ((a) > (b) ? (a) : (b))

#endif /* CAUTERIZE_H */
