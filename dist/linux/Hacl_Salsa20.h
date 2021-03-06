/* MIT License
 *
 * Copyright (c) 2016-2020 INRIA, CMU and Microsoft Corporation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */


#if defined(__cplusplus)
extern "C" {
#endif

#include "libintvector.h"
#include "kremlin/internal/types.h"
#include "kremlin/lowstar_endianness.h"
#include <string.h>
#include "kremlin/internal/target.h"


#ifndef __Hacl_Salsa20_H
#define __Hacl_Salsa20_H

#include "Hacl_Kremlib.h"

void Hacl_Salsa20_salsa20_encrypt(u32 len, u8 *out, u8 *text, u8 *key, u8 *n, u32 ctr);

void Hacl_Salsa20_salsa20_decrypt(u32 len, u8 *out, u8 *cipher, u8 *key, u8 *n, u32 ctr);

void Hacl_Salsa20_salsa20_key_block0(u8 *out, u8 *key, u8 *n);

void Hacl_Salsa20_hsalsa20(u8 *out, u8 *key, u8 *n);

#define __Hacl_Salsa20_H_DEFINED
#endif

#if defined(__cplusplus)
}
#endif

