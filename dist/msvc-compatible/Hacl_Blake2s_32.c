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


#include "Hacl_Blake2s_32.h"

static inline void
blake2s_update_block(uint32_t *wv, uint32_t *hash, bool flag, uint64_t totlen, uint8_t *d)
{
  uint32_t m_w[16U] = { 0U };
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)16U; i++)
  {
    uint32_t *os = m_w;
    uint8_t *bj = d + i * (uint32_t)4U;
    uint32_t u = load32_le(bj);
    uint32_t r = u;
    uint32_t x = r;
    os[i] = x;
  }
  uint32_t mask[4U] = { 0U };
  uint32_t wv_14;
  if (flag)
  {
    wv_14 = (uint32_t)0xFFFFFFFFU;
  }
  else
  {
    wv_14 = (uint32_t)0U;
  }
  uint32_t wv_15 = (uint32_t)0U;
  mask[0U] = (uint32_t)totlen;
  mask[1U] = (uint32_t)(totlen >> (uint32_t)32U);
  mask[2U] = wv_14;
  mask[3U] = wv_15;
  memcpy(wv, hash, (uint32_t)4U * (uint32_t)4U * sizeof (uint32_t));
  uint32_t *wv3 = wv + (uint32_t)3U * (uint32_t)4U;
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
  {
    uint32_t *os = wv3;
    uint32_t x = wv3[i] ^ mask[i];
    os[i] = x;
  }
  for (uint32_t i0 = (uint32_t)0U; i0 < (uint32_t)10U; i0++)
  {
    uint32_t start_idx = i0 % (uint32_t)10U * (uint32_t)16U;
    KRML_CHECK_SIZE(sizeof (uint32_t), (uint32_t)4U * (uint32_t)4U);
    uint32_t *m_st = alloca((uint32_t)4U * (uint32_t)4U * sizeof (uint32_t));
    memset(m_st, 0U, (uint32_t)4U * (uint32_t)4U * sizeof (uint32_t));
    uint32_t *r00 = m_st + (uint32_t)0U * (uint32_t)4U;
    uint32_t *r10 = m_st + (uint32_t)1U * (uint32_t)4U;
    uint32_t *r20 = m_st + (uint32_t)2U * (uint32_t)4U;
    uint32_t *r30 = m_st + (uint32_t)3U * (uint32_t)4U;
    uint32_t s0 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx];
    uint32_t s1 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx + (uint32_t)1U];
    uint32_t s2 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx + (uint32_t)2U];
    uint32_t s3 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx + (uint32_t)3U];
    uint32_t s4 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx + (uint32_t)4U];
    uint32_t s5 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx + (uint32_t)5U];
    uint32_t s6 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx + (uint32_t)6U];
    uint32_t s7 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx + (uint32_t)7U];
    uint32_t s8 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx + (uint32_t)8U];
    uint32_t s9 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx + (uint32_t)9U];
    uint32_t s10 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx + (uint32_t)10U];
    uint32_t s11 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx + (uint32_t)11U];
    uint32_t s12 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx + (uint32_t)12U];
    uint32_t s13 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx + (uint32_t)13U];
    uint32_t s14 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx + (uint32_t)14U];
    uint32_t s15 = Hacl_Impl_Blake2_Constants_sigmaTable[start_idx + (uint32_t)15U];
    uint32_t uu____0 = m_w[s2];
    uint32_t uu____1 = m_w[s4];
    uint32_t uu____2 = m_w[s6];
    r00[0U] = m_w[s0];
    r00[1U] = uu____0;
    r00[2U] = uu____1;
    r00[3U] = uu____2;
    uint32_t uu____3 = m_w[s3];
    uint32_t uu____4 = m_w[s5];
    uint32_t uu____5 = m_w[s7];
    r10[0U] = m_w[s1];
    r10[1U] = uu____3;
    r10[2U] = uu____4;
    r10[3U] = uu____5;
    uint32_t uu____6 = m_w[s10];
    uint32_t uu____7 = m_w[s12];
    uint32_t uu____8 = m_w[s14];
    r20[0U] = m_w[s8];
    r20[1U] = uu____6;
    r20[2U] = uu____7;
    r20[3U] = uu____8;
    uint32_t uu____9 = m_w[s11];
    uint32_t uu____10 = m_w[s13];
    uint32_t uu____11 = m_w[s15];
    r30[0U] = m_w[s9];
    r30[1U] = uu____9;
    r30[2U] = uu____10;
    r30[3U] = uu____11;
    uint32_t *x = m_st + (uint32_t)0U * (uint32_t)4U;
    uint32_t *y = m_st + (uint32_t)1U * (uint32_t)4U;
    uint32_t *z = m_st + (uint32_t)2U * (uint32_t)4U;
    uint32_t *w = m_st + (uint32_t)3U * (uint32_t)4U;
    uint32_t a = (uint32_t)0U;
    uint32_t b0 = (uint32_t)1U;
    uint32_t c0 = (uint32_t)2U;
    uint32_t d10 = (uint32_t)3U;
    uint32_t r01 = Hacl_Impl_Blake2_Constants_rTable_S[0U];
    uint32_t r12 = Hacl_Impl_Blake2_Constants_rTable_S[1U];
    uint32_t r21 = Hacl_Impl_Blake2_Constants_rTable_S[2U];
    uint32_t r31 = Hacl_Impl_Blake2_Constants_rTable_S[3U];
    uint32_t *wv_a0 = wv + a * (uint32_t)4U;
    uint32_t *wv_b0 = wv + b0 * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a0;
      uint32_t x1 = wv_a0[i] + wv_b0[i];
      os[i] = x1;
    }
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a0;
      uint32_t x1 = wv_a0[i] + x[i];
      os[i] = x1;
    }
    uint32_t *wv_a1 = wv + d10 * (uint32_t)4U;
    uint32_t *wv_b1 = wv + a * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a1;
      uint32_t x1 = wv_a1[i] ^ wv_b1[i];
      os[i] = x1;
    }
    uint32_t *r110 = wv_a1;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = r110;
      uint32_t x2 = r110[i];
      uint32_t x1 = x2 >> r01 | x2 << ((uint32_t)32U - r01);
      os[i] = x1;
    }
    uint32_t *wv_a2 = wv + c0 * (uint32_t)4U;
    uint32_t *wv_b2 = wv + d10 * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a2;
      uint32_t x1 = wv_a2[i] + wv_b2[i];
      os[i] = x1;
    }
    uint32_t *wv_a3 = wv + b0 * (uint32_t)4U;
    uint32_t *wv_b3 = wv + c0 * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a3;
      uint32_t x1 = wv_a3[i] ^ wv_b3[i];
      os[i] = x1;
    }
    uint32_t *r111 = wv_a3;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = r111;
      uint32_t x2 = r111[i];
      uint32_t x1 = x2 >> r12 | x2 << ((uint32_t)32U - r12);
      os[i] = x1;
    }
    uint32_t *wv_a4 = wv + a * (uint32_t)4U;
    uint32_t *wv_b4 = wv + b0 * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a4;
      uint32_t x1 = wv_a4[i] + wv_b4[i];
      os[i] = x1;
    }
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a4;
      uint32_t x1 = wv_a4[i] + y[i];
      os[i] = x1;
    }
    uint32_t *wv_a5 = wv + d10 * (uint32_t)4U;
    uint32_t *wv_b5 = wv + a * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a5;
      uint32_t x1 = wv_a5[i] ^ wv_b5[i];
      os[i] = x1;
    }
    uint32_t *r112 = wv_a5;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = r112;
      uint32_t x2 = r112[i];
      uint32_t x1 = x2 >> r21 | x2 << ((uint32_t)32U - r21);
      os[i] = x1;
    }
    uint32_t *wv_a6 = wv + c0 * (uint32_t)4U;
    uint32_t *wv_b6 = wv + d10 * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a6;
      uint32_t x1 = wv_a6[i] + wv_b6[i];
      os[i] = x1;
    }
    uint32_t *wv_a7 = wv + b0 * (uint32_t)4U;
    uint32_t *wv_b7 = wv + c0 * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a7;
      uint32_t x1 = wv_a7[i] ^ wv_b7[i];
      os[i] = x1;
    }
    uint32_t *r113 = wv_a7;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = r113;
      uint32_t x2 = r113[i];
      uint32_t x1 = x2 >> r31 | x2 << ((uint32_t)32U - r31);
      os[i] = x1;
    }
    uint32_t *r13 = wv + (uint32_t)1U * (uint32_t)4U;
    uint32_t *r22 = wv + (uint32_t)2U * (uint32_t)4U;
    uint32_t *r32 = wv + (uint32_t)3U * (uint32_t)4U;
    uint32_t *r114 = r13;
    uint32_t x00 = r114[1U];
    uint32_t x10 = r114[((uint32_t)1U + (uint32_t)1U) % (uint32_t)4U];
    uint32_t x20 = r114[((uint32_t)1U + (uint32_t)2U) % (uint32_t)4U];
    uint32_t x30 = r114[((uint32_t)1U + (uint32_t)3U) % (uint32_t)4U];
    r114[0U] = x00;
    r114[1U] = x10;
    r114[2U] = x20;
    r114[3U] = x30;
    uint32_t *r115 = r22;
    uint32_t x01 = r115[2U];
    uint32_t x11 = r115[((uint32_t)2U + (uint32_t)1U) % (uint32_t)4U];
    uint32_t x21 = r115[((uint32_t)2U + (uint32_t)2U) % (uint32_t)4U];
    uint32_t x31 = r115[((uint32_t)2U + (uint32_t)3U) % (uint32_t)4U];
    r115[0U] = x01;
    r115[1U] = x11;
    r115[2U] = x21;
    r115[3U] = x31;
    uint32_t *r116 = r32;
    uint32_t x02 = r116[3U];
    uint32_t x12 = r116[((uint32_t)3U + (uint32_t)1U) % (uint32_t)4U];
    uint32_t x22 = r116[((uint32_t)3U + (uint32_t)2U) % (uint32_t)4U];
    uint32_t x32 = r116[((uint32_t)3U + (uint32_t)3U) % (uint32_t)4U];
    r116[0U] = x02;
    r116[1U] = x12;
    r116[2U] = x22;
    r116[3U] = x32;
    uint32_t a0 = (uint32_t)0U;
    uint32_t b = (uint32_t)1U;
    uint32_t c = (uint32_t)2U;
    uint32_t d1 = (uint32_t)3U;
    uint32_t r0 = Hacl_Impl_Blake2_Constants_rTable_S[0U];
    uint32_t r1 = Hacl_Impl_Blake2_Constants_rTable_S[1U];
    uint32_t r23 = Hacl_Impl_Blake2_Constants_rTable_S[2U];
    uint32_t r33 = Hacl_Impl_Blake2_Constants_rTable_S[3U];
    uint32_t *wv_a = wv + a0 * (uint32_t)4U;
    uint32_t *wv_b8 = wv + b * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a;
      uint32_t x1 = wv_a[i] + wv_b8[i];
      os[i] = x1;
    }
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a;
      uint32_t x1 = wv_a[i] + z[i];
      os[i] = x1;
    }
    uint32_t *wv_a8 = wv + d1 * (uint32_t)4U;
    uint32_t *wv_b9 = wv + a0 * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a8;
      uint32_t x1 = wv_a8[i] ^ wv_b9[i];
      os[i] = x1;
    }
    uint32_t *r117 = wv_a8;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = r117;
      uint32_t x2 = r117[i];
      uint32_t x1 = x2 >> r0 | x2 << ((uint32_t)32U - r0);
      os[i] = x1;
    }
    uint32_t *wv_a9 = wv + c * (uint32_t)4U;
    uint32_t *wv_b10 = wv + d1 * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a9;
      uint32_t x1 = wv_a9[i] + wv_b10[i];
      os[i] = x1;
    }
    uint32_t *wv_a10 = wv + b * (uint32_t)4U;
    uint32_t *wv_b11 = wv + c * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a10;
      uint32_t x1 = wv_a10[i] ^ wv_b11[i];
      os[i] = x1;
    }
    uint32_t *r118 = wv_a10;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = r118;
      uint32_t x2 = r118[i];
      uint32_t x1 = x2 >> r1 | x2 << ((uint32_t)32U - r1);
      os[i] = x1;
    }
    uint32_t *wv_a11 = wv + a0 * (uint32_t)4U;
    uint32_t *wv_b12 = wv + b * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a11;
      uint32_t x1 = wv_a11[i] + wv_b12[i];
      os[i] = x1;
    }
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a11;
      uint32_t x1 = wv_a11[i] + w[i];
      os[i] = x1;
    }
    uint32_t *wv_a12 = wv + d1 * (uint32_t)4U;
    uint32_t *wv_b13 = wv + a0 * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a12;
      uint32_t x1 = wv_a12[i] ^ wv_b13[i];
      os[i] = x1;
    }
    uint32_t *r119 = wv_a12;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = r119;
      uint32_t x2 = r119[i];
      uint32_t x1 = x2 >> r23 | x2 << ((uint32_t)32U - r23);
      os[i] = x1;
    }
    uint32_t *wv_a13 = wv + c * (uint32_t)4U;
    uint32_t *wv_b14 = wv + d1 * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a13;
      uint32_t x1 = wv_a13[i] + wv_b14[i];
      os[i] = x1;
    }
    uint32_t *wv_a14 = wv + b * (uint32_t)4U;
    uint32_t *wv_b = wv + c * (uint32_t)4U;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = wv_a14;
      uint32_t x1 = wv_a14[i] ^ wv_b[i];
      os[i] = x1;
    }
    uint32_t *r1110 = wv_a14;
    for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
    {
      uint32_t *os = r1110;
      uint32_t x2 = r1110[i];
      uint32_t x1 = x2 >> r33 | x2 << ((uint32_t)32U - r33);
      os[i] = x1;
    }
    uint32_t *r14 = wv + (uint32_t)1U * (uint32_t)4U;
    uint32_t *r2 = wv + (uint32_t)2U * (uint32_t)4U;
    uint32_t *r3 = wv + (uint32_t)3U * (uint32_t)4U;
    uint32_t *r11 = r14;
    uint32_t x03 = r11[3U];
    uint32_t x13 = r11[((uint32_t)3U + (uint32_t)1U) % (uint32_t)4U];
    uint32_t x23 = r11[((uint32_t)3U + (uint32_t)2U) % (uint32_t)4U];
    uint32_t x33 = r11[((uint32_t)3U + (uint32_t)3U) % (uint32_t)4U];
    r11[0U] = x03;
    r11[1U] = x13;
    r11[2U] = x23;
    r11[3U] = x33;
    uint32_t *r1111 = r2;
    uint32_t x04 = r1111[2U];
    uint32_t x14 = r1111[((uint32_t)2U + (uint32_t)1U) % (uint32_t)4U];
    uint32_t x24 = r1111[((uint32_t)2U + (uint32_t)2U) % (uint32_t)4U];
    uint32_t x34 = r1111[((uint32_t)2U + (uint32_t)3U) % (uint32_t)4U];
    r1111[0U] = x04;
    r1111[1U] = x14;
    r1111[2U] = x24;
    r1111[3U] = x34;
    uint32_t *r1112 = r3;
    uint32_t x0 = r1112[1U];
    uint32_t x1 = r1112[((uint32_t)1U + (uint32_t)1U) % (uint32_t)4U];
    uint32_t x2 = r1112[((uint32_t)1U + (uint32_t)2U) % (uint32_t)4U];
    uint32_t x3 = r1112[((uint32_t)1U + (uint32_t)3U) % (uint32_t)4U];
    r1112[0U] = x0;
    r1112[1U] = x1;
    r1112[2U] = x2;
    r1112[3U] = x3;
  }
  uint32_t *s0 = hash + (uint32_t)0U * (uint32_t)4U;
  uint32_t *s1 = hash + (uint32_t)1U * (uint32_t)4U;
  uint32_t *r0 = wv + (uint32_t)0U * (uint32_t)4U;
  uint32_t *r1 = wv + (uint32_t)1U * (uint32_t)4U;
  uint32_t *r2 = wv + (uint32_t)2U * (uint32_t)4U;
  uint32_t *r3 = wv + (uint32_t)3U * (uint32_t)4U;
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
  {
    uint32_t *os = s0;
    uint32_t x = s0[i] ^ r0[i];
    os[i] = x;
  }
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
  {
    uint32_t *os = s0;
    uint32_t x = s0[i] ^ r2[i];
    os[i] = x;
  }
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
  {
    uint32_t *os = s1;
    uint32_t x = s1[i] ^ r1[i];
    os[i] = x;
  }
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
  {
    uint32_t *os = s1;
    uint32_t x = s1[i] ^ r3[i];
    os[i] = x;
  }
}

void
Hacl_Blake2s_32_blake2s(
  uint32_t nn,
  uint8_t *output,
  uint32_t ll,
  uint8_t *d,
  uint32_t kk,
  uint8_t *k
)
{
  uint32_t stlen = (uint32_t)4U * (uint32_t)4U;
  uint32_t stzero = (uint32_t)0U;
  KRML_CHECK_SIZE(sizeof (uint32_t), stlen);
  uint32_t *b = alloca(stlen * sizeof (uint32_t));
  for (uint32_t _i = 0U; _i < stlen; ++_i)
    b[_i] = stzero;
  uint64_t prev0;
  if (kk == (uint32_t)0U)
  {
    prev0 = (uint64_t)(uint32_t)0U;
  }
  else
  {
    prev0 = (uint64_t)(uint32_t)64U;
  }
  KRML_CHECK_SIZE(sizeof (uint32_t), stlen);
  uint32_t *b1 = alloca(stlen * sizeof (uint32_t));
  for (uint32_t _i = 0U; _i < stlen; ++_i)
    b1[_i] = stzero;
  uint8_t b20[64U] = { 0U };
  uint32_t *r0 = b + (uint32_t)0U * (uint32_t)4U;
  uint32_t *r11 = b + (uint32_t)1U * (uint32_t)4U;
  uint32_t *r21 = b + (uint32_t)2U * (uint32_t)4U;
  uint32_t *r3 = b + (uint32_t)3U * (uint32_t)4U;
  uint32_t iv0 = Hacl_Impl_Blake2_Constants_ivTable_S[0U];
  uint32_t iv1 = Hacl_Impl_Blake2_Constants_ivTable_S[1U];
  uint32_t iv2 = Hacl_Impl_Blake2_Constants_ivTable_S[2U];
  uint32_t iv3 = Hacl_Impl_Blake2_Constants_ivTable_S[3U];
  uint32_t iv4 = Hacl_Impl_Blake2_Constants_ivTable_S[4U];
  uint32_t iv5 = Hacl_Impl_Blake2_Constants_ivTable_S[5U];
  uint32_t iv6 = Hacl_Impl_Blake2_Constants_ivTable_S[6U];
  uint32_t iv7 = Hacl_Impl_Blake2_Constants_ivTable_S[7U];
  r21[0U] = iv0;
  r21[1U] = iv1;
  r21[2U] = iv2;
  r21[3U] = iv3;
  r3[0U] = iv4;
  r3[1U] = iv5;
  r3[2U] = iv6;
  r3[3U] = iv7;
  uint32_t kk_shift_8 = kk << (uint32_t)8U;
  uint32_t iv0_ = iv0 ^ ((uint32_t)0x01010000U ^ (kk_shift_8 ^ nn));
  r0[0U] = iv0_;
  r0[1U] = iv1;
  r0[2U] = iv2;
  r0[3U] = iv3;
  r11[0U] = iv4;
  r11[1U] = iv5;
  r11[2U] = iv6;
  r11[3U] = iv7;
  if (!(kk == (uint32_t)0U))
  {
    memcpy(b20, k, kk * sizeof (uint8_t));
    uint64_t totlen = (uint64_t)(uint32_t)0U + (uint64_t)(uint32_t)64U;
    uint8_t *b3 = b20 + (uint32_t)0U * (uint32_t)64U;
    blake2s_update_block(b1, b, false, totlen, b3);
  }
  Lib_Memzero0_memzero(b20, (uint32_t)64U * sizeof (b20[0U]));
  uint32_t nb0 = ll / (uint32_t)64U;
  uint32_t rem0 = ll % (uint32_t)64U;
  K___uint32_t_uint32_t scrut;
  if (rem0 == (uint32_t)0U && nb0 > (uint32_t)0U)
  {
    uint32_t nb_ = nb0 - (uint32_t)1U;
    uint32_t rem_ = (uint32_t)64U;
    scrut = ((K___uint32_t_uint32_t){ .fst = nb_, .snd = rem_ });
  }
  else
  {
    scrut = ((K___uint32_t_uint32_t){ .fst = nb0, .snd = rem0 });
  }
  uint32_t nb = scrut.fst;
  uint32_t rem = scrut.snd;
  for (uint32_t i = (uint32_t)0U; i < nb; i++)
  {
    uint64_t totlen = prev0 + (uint64_t)((i + (uint32_t)1U) * (uint32_t)64U);
    uint8_t *b2 = d + i * (uint32_t)64U;
    blake2s_update_block(b1, b, false, totlen, b2);
  }
  uint8_t b21[64U] = { 0U };
  uint8_t *last = d + ll - rem;
  memcpy(b21, last, rem * sizeof (uint8_t));
  uint64_t totlen = prev0 + (uint64_t)ll;
  blake2s_update_block(b1, b, true, totlen, b21);
  Lib_Memzero0_memzero(b21, (uint32_t)64U * sizeof (b21[0U]));
  uint32_t double_row = (uint32_t)2U * (uint32_t)4U * (uint32_t)4U;
  KRML_CHECK_SIZE(sizeof (uint8_t), double_row);
  uint8_t *b2 = alloca(double_row * sizeof (uint8_t));
  memset(b2, 0U, double_row * sizeof (uint8_t));
  uint8_t *first = b2;
  uint8_t *second = b2 + (uint32_t)4U * (uint32_t)4U;
  uint32_t *row0 = b + (uint32_t)0U * (uint32_t)4U;
  uint32_t *row1 = b + (uint32_t)1U * (uint32_t)4U;
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
  {
    store32_le(first + i * (uint32_t)4U, row0[i]);
  }
  for (uint32_t i = (uint32_t)0U; i < (uint32_t)4U; i++)
  {
    store32_le(second + i * (uint32_t)4U, row1[i]);
  }
  uint8_t *final = b2;
  memcpy(output, final, nn * sizeof (uint8_t));
  Lib_Memzero0_memzero(b2, double_row * sizeof (b2[0U]));
  Lib_Memzero0_memzero(b1, stlen * sizeof (b1[0U]));
  Lib_Memzero0_memzero(b, stlen * sizeof (b[0U]));
}

