#include <stdio.h>
#include <stdlib.h>

#include "cauterize.h"
#include "greatest.h"

GREATEST_MAIN_DEFS();

TEST t_MarshalInit_works() {
  CAUTERIZE_STATUS_T s = MS_ERR_GENERAL;
  struct Marshal m;
  uint8_t buffer[64] = { 0 };

  s = MarshalInit(&m, buffer, sizeof(buffer));

  ASSERT_EQ(MS_OK, s);
  ASSERT_EQ(m.size, 64);
  ASSERT_EQ(m.used, 0);
  ASSERT_EQ(m.pos, 0);

  PASS();
}

TEST t_MarshalAppend_works() {
  CAUTERIZE_STATUS_T s = MS_ERR_GENERAL;
  struct Marshal m;
  uint8_t buffer[64] = { 0 };
  char data[] = "Hello World";

  s = MarshalInit(&m, buffer, sizeof(buffer));
  ASSERT_EQ(MS_OK, s);

  s = MarshalAppend(&m, (uint8_t*)data, sizeof(data));
  ASSERT_EQ(MS_OK, s);
  ASSERT_EQ(m.used, sizeof(data));
  ASSERT_STR_EQ(data, (char*)m.buffer);

  PASS();
}

TEST t_MarshalAppend_works_again() {
  CAUTERIZE_STATUS_T s = MS_ERR_GENERAL;
  struct Marshal m;
  uint8_t buffer[64] = { 0 };

  char data_1[3] = "ABC";
  char data_2[] = "DEF";

  s = MarshalInit(&m, buffer, sizeof(buffer));
  ASSERT_EQ(MS_OK, s);

  ASSERT_EQ(MS_OK, MarshalAppend(&m, (uint8_t*)data_1, sizeof(data_1)));
  ASSERT_EQ(MS_OK, MarshalAppend(&m, (uint8_t*)data_2, sizeof(data_2)));

  ASSERT_EQ(sizeof(data_1) + sizeof(data_2), m.used);
  ASSERT_STR_EQ("ABCDEF", (char*)m.buffer);

  PASS();
}

TEST t_MarshalAppend_checks_space_needs() {
  CAUTERIZE_STATUS_T s = MS_ERR_GENERAL;
  struct Marshal m;
  uint8_t buffer[64] = { 0 };
  char data[] = "Hello World";

  s = MarshalInit(&m, buffer, sizeof(data) - 5);
  ASSERT_EQ(MS_OK, s);

  s = MarshalAppend(&m, (uint8_t*)data, sizeof(data));
  ASSERT_EQ(MS_ERR_NOT_ENOUGH_SPACE, s);
  ASSERT_EQ(m.used, 0);

  PASS();
}

TEST t_MarshalRead_works() {
  CAUTERIZE_STATUS_T s = MS_ERR_GENERAL;
  struct Marshal m;
  uint8_t buffer[64] = { 0 };
  char data[] = "Hello World";

  ASSERT_EQ(MS_OK, MarshalInit(&m, buffer, sizeof(buffer)));
  ASSERT_EQ(MS_OK, MarshalAppend(&m, (uint8_t*)data, sizeof(data)));

  char dest[64] = {0};

  s = MarshalRead(&m, (uint8_t*)dest, 5);
  ASSERT_EQ(MS_OK, s);
  ASSERT_EQ(5, m.pos);
  ASSERT_STR_EQ("Hello", dest);

  PASS();
}

TEST t_MarshalRead_works_again() {
  CAUTERIZE_STATUS_T s = MS_ERR_GENERAL;
  struct Marshal m;
  uint8_t buffer[64] = { 0 };
  char data[] = "Hello World";

  ASSERT_EQ(MS_OK, MarshalInit(&m, buffer, sizeof(buffer)));
  ASSERT_EQ(MS_OK, MarshalAppend(&m, (uint8_t*)data, sizeof(data)));

  char dest[64] = {0};

  ASSERT_EQ(MS_OK, MarshalRead(&m, (uint8_t*)dest, 5));

  s = MarshalRead(&m, (uint8_t*)dest, 6);
  ASSERT_EQ(MS_OK, s);
  ASSERT_EQ(11, m.pos);
  ASSERT_STR_EQ(" World", dest);

  PASS();
}

TEST t_MarshalRead_checks_data_needs() {
  CAUTERIZE_STATUS_T s = MS_ERR_GENERAL;
  struct Marshal m;
  uint8_t buffer[32] = { 0 };
  char data[] = "Hello World";

  ASSERT_EQ(MS_OK, MarshalInit(&m, buffer, sizeof(buffer)));
  ASSERT_EQ(MS_OK, MarshalAppend(&m, (uint8_t*)data, sizeof(data)));

  char dest[64] = {0};

  s = MarshalRead(&m, (uint8_t*)dest, sizeof(dest));
  ASSERT_EQ(MS_ERR_NOT_ENOUGH_DATA, s);
  ASSERT_EQ(0, m.pos);

  PASS();
}

GREATEST_SUITE(marshal) {
  RUN_TEST(t_MarshalInit_works);
  RUN_TEST(t_MarshalAppend_works);
  RUN_TEST(t_MarshalAppend_works_again);
  RUN_TEST(t_MarshalAppend_checks_space_needs);
  RUN_TEST(t_MarshalRead_works);
  RUN_TEST(t_MarshalRead_works_again);
  RUN_TEST(t_MarshalRead_checks_data_needs);
}

int main(int argc, char * argv[]) {
  GREATEST_MAIN_BEGIN();
  RUN_SUITE(marshal);
  GREATEST_MAIN_END();
}
