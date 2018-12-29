#include "stdint.h"
#include "stdio.h"
#include "stdbool.h"
#include "Lib_PrintBuffer.h"

void Lib_PrintBuffer_print_bytes(uint32_t len, uint8_t* buffer) {
  for (uint32_t i = 0; i < len; i++){
    printf("%02x ", buffer[i]);
  }
  printf("\n");
}

void Lib_PrintBuffer_print_compare(uint32_t len, uint8_t* buffer1, uint8_t* buffer2) {
  for (uint32_t i = 0; i < len; i++){
    printf("%02x ", buffer1[i]);
  }
  printf("\n");
  for (uint32_t i = 0; i < len; i++){
    printf("%02x ", buffer2[i]);
  }
  printf("\n");
}

void Lib_PrintBuffer_print_compare_display(uint32_t len, uint8_t* buffer1, uint8_t* buffer2) {
  Lib_PrintBuffer_print_compare(len, buffer1, buffer2);
  uint8_t res = 0;
  for (uint32_t i = 0; i < len; i++) {
    res |= buffer1[i] ^ buffer2[i];
  }
  if (res == 0) {
    printf("Success !\n");
  } else {
    printf("Failure !\n");
  }
  printf("\n");
}

bool Lib_PrintBuffer_result_compare_display(uint32_t len, uint8_t* buffer1, uint8_t* buffer2) {
  Lib_PrintBuffer_print_compare(len, buffer1, buffer2);
  uint8_t res = 0;
  for (uint32_t i = 0; i < len; i++) {
    res |= buffer1[i] ^ buffer2[i];
  }
  if (res == 0) {
    printf("Success !\n\n");
    return true;
  } else {
    printf("Failure !\n\n");
    return false;
  }
}

