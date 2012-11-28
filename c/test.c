#include <stdio.h>
#include <stdlib.h>

#include "cauterize.h"
#include "greatest.h"

GREATEST_MAIN_DEFS();

TEST t_CauterizeInit_works() {
  CAUTERIZE_STATUS_T s = CA_ERR_GENERAL;
  struct Cauterize m;
  uint8_t buffer[64] = { 0 };

  s = CauterizeInit(&m, buffer, sizeof(buffer));

  ASSERT_EQ(CA_OK, s);
  ASSERT_EQ(m.size, 64);
  ASSERT_EQ(m.used, 0);
  ASSERT_EQ(m.pos, 0);

  PASS();
}

TEST t_CauterizeAppend_works() {
  CAUTERIZE_STATUS_T s = CA_ERR_GENERAL;
  struct Cauterize m;
  uint8_t buffer[64] = { 0 };
  char data[] = "Hello World";

  s = CauterizeInit(&m, buffer, sizeof(buffer));
  ASSERT_EQ(CA_OK, s);

  s = CauterizeAppend(&m, (uint8_t*)data, sizeof(data));
  ASSERT_EQ(CA_OK, s);
  ASSERT_EQ(m.used, sizeof(data));
  ASSERT_STR_EQ(data, (char*)m.buffer);

  PASS();
}

TEST t_CauterizeAppend_works_again() {
  CAUTERIZE_STATUS_T s = CA_ERR_GENERAL;
  struct Cauterize m;
  uint8_t buffer[64] = { 0 };

  char data_1[3] = "ABC";
  char data_2[] = "DEF";

  s = CauterizeInit(&m, buffer, sizeof(buffer));
  ASSERT_EQ(CA_OK, s);

  ASSERT_EQ(CA_OK, CauterizeAppend(&m, (uint8_t*)data_1, sizeof(data_1)));
  ASSERT_EQ(CA_OK, CauterizeAppend(&m, (uint8_t*)data_2, sizeof(data_2)));

  ASSERT_EQ(sizeof(data_1) + sizeof(data_2), m.used);
  ASSERT_STR_EQ("ABCDEF", (char*)m.buffer);

  PASS();
}

TEST t_CauterizeAppend_checks_space_needs() {
  CAUTERIZE_STATUS_T s = CA_ERR_GENERAL;
  struct Cauterize m;
  uint8_t buffer[64] = { 0 };
  char data[] = "Hello World";

  s = CauterizeInit(&m, buffer, sizeof(data) - 5);
  ASSERT_EQ(CA_OK, s);

  s = CauterizeAppend(&m, (uint8_t*)data, sizeof(data));
  ASSERT_EQ(CA_ERR_NOT_ENOUGH_SPACE, s);
  ASSERT_EQ(m.used, 0);

  PASS();
}

TEST t_CauterizeRead_works() {
  CAUTERIZE_STATUS_T s = CA_ERR_GENERAL;
  struct Cauterize m;
  uint8_t buffer[64] = { 0 };
  char data[] = "Hello World";

  ASSERT_EQ(CA_OK, CauterizeInit(&m, buffer, sizeof(buffer)));
  ASSERT_EQ(CA_OK, CauterizeAppend(&m, (uint8_t*)data, sizeof(data)));

  char dest[64] = {0};

  s = CauterizeRead(&m, (uint8_t*)dest, 5);
  ASSERT_EQ(CA_OK, s);
  ASSERT_EQ(5, m.pos);
  ASSERT_STR_EQ("Hello", dest);

  PASS();
}

TEST t_CauterizeRead_works_again() {
  CAUTERIZE_STATUS_T s = CA_ERR_GENERAL;
  struct Cauterize m;
  uint8_t buffer[64] = { 0 };
  char data[] = "Hello World";

  ASSERT_EQ(CA_OK, CauterizeInit(&m, buffer, sizeof(buffer)));
  ASSERT_EQ(CA_OK, CauterizeAppend(&m, (uint8_t*)data, sizeof(data)));

  char dest[64] = {0};

  ASSERT_EQ(CA_OK, CauterizeRead(&m, (uint8_t*)dest, 5));

  s = CauterizeRead(&m, (uint8_t*)dest, 6);
  ASSERT_EQ(CA_OK, s);
  ASSERT_EQ(11, m.pos);
  ASSERT_STR_EQ(" World", dest);

  PASS();
}

TEST t_CauterizeRead_checks_data_needs() {
  CAUTERIZE_STATUS_T s = CA_ERR_GENERAL;
  struct Cauterize m;
  uint8_t buffer[32] = { 0 };
  char data[] = "Hello World";

  ASSERT_EQ(CA_OK, CauterizeInit(&m, buffer, sizeof(buffer)));
  ASSERT_EQ(CA_OK, CauterizeAppend(&m, (uint8_t*)data, sizeof(data)));

  char dest[64] = {0};

  s = CauterizeRead(&m, (uint8_t*)dest, sizeof(dest));
  ASSERT_EQ(CA_ERR_NOT_ENOUGH_DATA, s);
  ASSERT_EQ(0, m.pos);

  PASS();
}

GREATEST_SUITE(marshal) {
  RUN_TEST(t_CauterizeInit_works);
  RUN_TEST(t_CauterizeAppend_works);
  RUN_TEST(t_CauterizeAppend_works_again);
  RUN_TEST(t_CauterizeAppend_checks_space_needs);
  RUN_TEST(t_CauterizeRead_works);
  RUN_TEST(t_CauterizeRead_works_again);
  RUN_TEST(t_CauterizeRead_checks_data_needs);
}

int main(int argc, char * argv[]) {
  GREATEST_MAIN_BEGIN();
  RUN_SUITE(marshal);
  GREATEST_MAIN_END();
}
