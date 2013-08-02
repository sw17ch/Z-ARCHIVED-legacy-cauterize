#include "example_project_config.h"

CAUTERIZE_STATUS_T spec_Pack_uint8_buffer(struct Cauterize * dst, struct uint8_buffer * src)
{
  CAUTERIZE_STATUS_T err;

  if (src->length > ARRAY_SIZE(src->data)) { return CA_ERR_INVALID_LENGTH; }
  if (CA_OK != (err = Pack_uint8(dst, &src->length))) { return err; }

  return CauterizeAppend(dst, src->data, src->length * sizeof(src->data[0]));
}
