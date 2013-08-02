#ifndef EXAMPLE_PROJECT_CONFIG_H
#define EXAMPLE_PROJECT_CONFIG_H

#include "example_project.h"

/* We're going to define a specialized version of Pack_uint8_buffer which packs
 * the entire buffer at once. We know this is okay since we're guaranteed not
 * to have any padding between the bytes in the array. */
#define SPECIALIZED_Pack_uint8_buffer spec_Pack_uint8_buffer

CAUTERIZE_STATUS_T spec_Pack_uint8_buffer(
    struct Cauterize * dst,
    struct uint8_buffer * src);

#endif /* EXAMPLE_PROJECT_CONFIG_H */
