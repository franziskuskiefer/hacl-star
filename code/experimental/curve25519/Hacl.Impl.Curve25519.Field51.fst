module Hacl.Impl.Curve25519.Field51

open FStar.HyperStack
open FStar.HyperStack.All
open FStar.Mul

open Lib.Sequence
open Lib.IntTypes
open Lib.Buffer

include Hacl.Spec.Curve25519.Field51
include Hacl.Spec.Curve25519.Field51.Definition

module P = NatPrime
module S = Hacl.Spec.Curve25519.Field51.Definition
module ST = FStar.HyperStack.ST

#reset-options "--z3rlimit 20"

let felem = lbuffer uint64 5ul
let felem2 = lbuffer uint64 10ul
let felem_wide = lbuffer uint128 5ul

noextract
val as_nat: h:mem -> e:felem -> GTot nat
let as_nat h e =
  let s = as_seq h e in
  let s0 = s.[0] in
  let s1 = s.[1] in
  let s2 = s.[2] in
  let s3 = s.[3] in
  let s4 = s.[4] in
  S.as_nat5 (s0, s1, s2, s3, s4)

noextract
val wide_as_nat: h:mem -> e:felem_wide -> GTot nat
let wide_as_nat h e =
  let s = as_seq h e in
  let s0 = s.[0] in
  let s1 = s.[1] in
  let s2 = s.[2] in
  let s3 = s.[3] in
  let s4 = s.[4] in
  S.wide_as_nat5 (s0, s1, s2, s3, s4)

noextract
val fevalh: h:mem -> f:felem -> GTot P.felem
let fevalh h f = (as_nat h f) % P.prime

noextract
val feval_wideh: h:mem -> f:felem_wide -> GTot P.felem
let feval_wideh h f = (wide_as_nat h f) % P.prime

noextract
val felem_fits: h:mem -> f:felem -> m:S.scale64_5 -> Type0
let felem_fits h f m =
  let s = as_seq h f in
  let s0 = s.[0] in
  let s1 = s.[1] in
  let s2 = s.[2] in
  let s3 = s.[3] in
  let s4 = s.[4] in
  S.felem_fits5 (s0, s1, s2, s3, s4) m

noextract
val felem_wide_fits: h:mem -> f:felem_wide -> m:S.scale128_5 -> Type0
let felem_wide_fits h f m =
  let s = as_seq h f in
  let s0 = s.[0] in
  let s1 = s.[1] in
  let s2 = s.[2] in
  let s3 = s.[3] in
  let s4 = s.[4] in
  S.felem_wide_fits5 (s0, s1, s2, s3, s4) m


inline_for_extraction
val create_felem:
  unit -> StackInline felem
  (requires fun _ -> True)
  (ensures  fun h0 f h1 ->
    stack_allocated f h0 h1 (Seq.create 5 (u64 0)) /\
    as_nat h1 f == 0)
let create_felem () = create 5ul (u64 0)

inline_for_extraction
val create_wide:
  unit -> StackInline felem_wide
  (requires fun _ -> True)
  (ensures  fun h0 f h1 ->
    stack_allocated f h0 h1 (Seq.create 5 (u128 0)) /\
    wide_as_nat h1 f == 0)
let create_wide () = create 5ul (u128 0)

inline_for_extraction
val set_bit1:
    f:felem
  -> i:size_t{v i < 255}
  -> Stack unit
    (requires fun h -> live h f)
    (ensures  fun h0 _ h1 -> modifies (loc f) h0 h1)
let set_bit1 f i =
  f.(i /. size 51) <- f.(i /. size 51) |. (u64 1 <<. (i %. size 51))

inline_for_extraction
val set_bit0:
    f:felem
  -> i:size_t{v i < 255}
  -> Stack unit
    (requires fun h -> live h f)
    (ensures  fun h0 _ h1 -> modifies (loc f) h0 h1)
let set_bit0 f i =
  f.(i /. size 51) <- f.(i /. size 51) &. lognot (u64 1 <<. (i %. size 51))

inline_for_extraction
val set_zero:
  f:felem -> Stack unit
  (requires fun h -> live h f)
  (ensures  fun h0 _ h1 ->
    modifies (loc f) h0 h1 /\
    as_nat h1 f == 0)
let set_zero f =
  f.(0ul) <- u64 0;
  f.(1ul) <- u64 0;
  f.(2ul) <- u64 0;
  f.(3ul) <- u64 0;
  f.(4ul) <- u64 0

inline_for_extraction
val set_one:
  f:felem -> Stack unit
  (requires fun h -> live h f)
  (ensures  fun h0 _ h1 ->
    modifies (loc f) h0 h1 /\
    as_nat h1 f == 1)
let set_one f =
  f.(0ul) <- u64 1;
  f.(1ul) <- u64 0;
  f.(2ul) <- u64 0;
  f.(3ul) <- u64 0;
  f.(4ul) <- u64 0

inline_for_extraction
val copy_felem:
    f1:felem
  -> f2:felem
  -> Stack unit
    (requires fun h ->
      live h f1 /\ live h f2 /\ disjoint f1 f2)
    (ensures  fun h0 _ h1 ->
      modifies (loc f1) h0 h1 /\
      as_nat h1 f1 == as_nat h0 f2)
let copy_felem f1 f2 =
  f1.(size 0) <- f2.(size 0);
  f1.(size 1) <- f2.(size 1);
  f1.(size 2) <- f2.(size 2);
  f1.(size 3) <- f2.(size 3);
  f1.(size 4) <- f2.(size 4)

#set-options "--max_fuel 0 --max_ifuel 0"

val fadd:
    out:felem
  -> f1:felem
  -> f2:felem
  -> Stack unit
    (requires fun h ->
      live h f1 /\ live h f2 /\ live h out /\
      felem_fits h f1 (1, 2, 1, 1, 1) /\
      felem_fits h f2 (1, 2, 1, 1, 1))
    (ensures fun h0 _ h1 ->
      modifies (loc out) h0 h1 /\
      felem_fits h1 out (2, 4, 2, 2, 2) /\
      fevalh h1 out == P.fadd (fevalh h0 f1) (fevalh h0 f2))
[@ CInline]
let fadd out f1 f2 =
  let h0 = ST.get () in
  let f10 = f1.(0ul) in
  let f20 = f2.(0ul) in
  let f11 = f1.(1ul) in
  let f21 = f2.(1ul) in
  let f12 = f1.(2ul) in
  let f22 = f2.(2ul) in
  let f13 = f1.(3ul) in
  let f23 = f2.(3ul) in
  let f14 = f1.(4ul) in
  let f24 = f2.(4ul) in
  out.(0ul) <- f10 +! f20;
  out.(1ul) <- f11 +! f21;
  out.(2ul) <- f12 +! f22;
  out.(3ul) <- f13 +! f23;
  out.(4ul) <- f14 +! f24;
  let h1 = ST.get () in
  assert (as_nat h1 out == as_nat h0 f1 + as_nat h0 f2);
  FStar.Math.Lemmas.lemma_mod_plus_distr_l
    (as_nat h0 f1) (as_nat h0 f2) P.prime;
  FStar.Math.Lemmas.lemma_mod_plus_distr_r
    (as_nat h0 f1 % P.prime) (as_nat h0 f2) P.prime

val fsub:
    out:felem
  -> f1:felem
  -> f2:felem
  -> Stack unit
    (requires fun h ->
      live h f1 /\ live h f2 /\ live h out /\
      felem_fits h f1 (1, 2, 1, 1, 1) /\
      felem_fits h f2 (1, 2, 1, 1, 1))
    (ensures  fun h0 _ h1 ->
      modifies (loc out) h0 h1 /\
      felem_fits h1 out (9, 10, 9, 9, 9) /\
      fevalh h1 out == P.fsub (fevalh h0 f1) (fevalh h0 f2))
[@ CInline]
let fsub out f1 f2 =
  let f10 = f1.(0ul) in
  let f20 = f2.(0ul) in
  let f11 = f1.(1ul) in
  let f21 = f2.(1ul) in
  let f12 = f1.(2ul) in
  let f22 = f2.(2ul) in
  let f13 = f1.(3ul) in
  let f23 = f2.(3ul) in
  let f14 = f1.(4ul) in
  let f24 = f2.(4ul) in
  out.(0ul) <- f10 +! u64 0x3fffffffffff68 -! f20;
  out.(1ul) <- f11 +! u64 0x3ffffffffffff8 -! f21;
  out.(2ul) <- f12 +! u64 0x3ffffffffffff8 -! f22;
  out.(3ul) <- f13 +! u64 0x3ffffffffffff8 -! f23;
  out.(4ul) <- f14 +! u64 0x3ffffffffffff8 -! f24;
  lemma_fsub (f10, f11, f12, f13, f14) (f20, f21, f22, f23, f24)

val fmul:
    out:felem
  -> f1:felem
  -> f2:felem
  -> Stack unit
    (requires fun h ->
      live h out /\ live h f1 /\ live h f2 /\
      felem_fits h f1 (9, 10, 9, 9, 9) /\
      felem_fits h f2 (9, 10, 9, 9, 9))
    (ensures  fun h0 _ h1 ->
      modifies (loc out) h0 h1 /\
      felem_fits h1 out (1, 2, 1, 1, 1) /\
      fevalh h1 out == P.fmul (fevalh h0 f1) (fevalh h0 f2))
[@ CInline]
let fmul out f1 f2 =
  let f10 = f1.(size 0) in
  let f11 = f1.(size 1) in
  let f12 = f1.(size 2) in
  let f13 = f1.(size 3) in
  let f14 = f1.(size 4) in

  let f20 = f2.(size 0) in
  let f21 = f2.(size 1) in
  let f22 = f2.(size 2) in
  let f23 = f2.(size 3) in
  let f24 = f2.(size 4) in

  let (o0,o1,o2,o3,o4) = fmul5 (f10,f11,f12,f13,f14) (f20,f21,f22,f23,f24) in
  out.(size 0) <- o0;
  out.(size 1) <- o1;
  out.(size 2) <- o2;
  out.(size 3) <- o3;
  out.(size 4) <- o4

val fmul2:
    out:felem2
  -> f1:felem2
  -> f2:felem2
  -> Stack unit
    (requires fun h ->
      let f10 = gsub f1 0ul 5ul in
      let f11 = gsub f1 5ul 5ul in
      let f20 = gsub f2 0ul 5ul in
      let f21 = gsub f2 5ul 5ul in
      felem_fits h f10 (9, 10, 9, 9, 9) /\
      felem_fits h f11 (9, 10, 9, 9, 9) /\
      felem_fits h f20 (9, 10, 9, 9, 9) /\
      felem_fits h f21 (9, 10, 9, 9, 9) /\
      live h out /\ live h f1 /\ live h f2)
    (ensures  fun h0 _ h1 -> modifies (loc out) h0 h1 /\
     (let out0 = gsub out 0ul 5ul in
      let out1 = gsub out 5ul 5ul in
      let f10 = gsub f1 0ul 5ul in
      let f11 = gsub f1 5ul 5ul in
      let f20 = gsub f2 0ul 5ul in
      let f21 = gsub f2 5ul 5ul in
      felem_fits h1 out0 (1, 2, 1, 1, 1) /\
      felem_fits h1 out1 (1, 2, 1, 1, 1) /\
      fevalh h1 out0 == P.fmul (fevalh h0 f10) (fevalh h0 f20) /\
      fevalh h1 out1 == P.fmul (fevalh h0 f11) (fevalh h0 f21)))
[@ CInline]
let fmul2 out f1 f2 =
  let f10 = f1.(size 0) in
  let f11 = f1.(size 1) in
  let f12 = f1.(size 2) in
  let f13 = f1.(size 3) in
  let f14 = f1.(size 4) in

  let f20 = f2.(size 0) in
  let f21 = f2.(size 1) in
  let f22 = f2.(size 2) in
  let f23 = f2.(size 3) in
  let f24 = f2.(size 4) in

  let f30 = f1.(size 5) in
  let f31 = f1.(size 6) in
  let f32 = f1.(size 7) in
  let f33 = f1.(size 8) in
  let f34 = f1.(size 9) in

  let f40 = f2.(size 5) in
  let f41 = f2.(size 6) in
  let f42 = f2.(size 7) in
  let f43 = f2.(size 8) in
  let f44 = f2.(size 9) in

  let ((o10,o11,o12,o13,o14), (o20,o21,o22,o23,o24)) =
    fmul25 (f10,f11,f12,f13,f14) (f20,f21,f22,f23,f24)
     (f30,f31,f32,f33,f34) (f40,f41,f42,f43,f44) in

  out.(size 0) <- o10;
  out.(size 1) <- o11;
  out.(size 2) <- o12;
  out.(size 3) <- o13;
  out.(size 4) <- o14;

  out.(size 5) <- o20;
  out.(size 6) <- o21;
  out.(size 7) <- o22;
  out.(size 8) <- o23;
  out.(size 9) <- o24

val fmul1:
    out:felem
  -> f1:felem
  -> f2:uint64
  -> Stack unit
    (requires fun h ->
      live h out /\ live h f1 /\
      felem_fits h f1 (9, 10, 9, 9, 9) /\
      S.felem_fits1 f2 1)
    (ensures  fun h0 _ h1 ->
      modifies (loc out) h0 h1 /\
      felem_fits h1 out (1, 2, 1, 1, 1) /\
      fevalh h1 out == (fevalh h0 f1 * v f2) % P.prime)
[@ CInline]
let fmul1 out f1 f2 =
  let f10 = f1.(size 0) in
  let f11 = f1.(size 1) in
  let f12 = f1.(size 2) in
  let f13 = f1.(size 3) in
  let f14 = f1.(size 4) in
  let (o0,o1,o2,o3,o4) = fmul15 (f10,f11,f12,f13,f14) f2 in
  out.(size 0) <- o0;
  out.(size 1) <- o1;
  out.(size 2) <- o2;
  out.(size 3) <- o3;
  out.(size 4) <- o4

val fsqr:
     out:felem
  -> f:felem
  -> Stack unit
    (requires fun h ->
      live h out /\ live h f /\
      felem_fits h f (9, 10, 9, 9, 9))
    (ensures  fun h0 _ h1 ->
      modifies (loc out) h0 h1 /\
      felem_fits h1 out (1, 2, 1, 1, 1) /\
      fevalh h1 out == P.fsqr (fevalh h0 f))
[@ CInline]
let fsqr out f =
  let f0 = f.(0ul) in
  let f1 = f.(1ul) in
  let f2 = f.(2ul) in
  let f3 = f.(3ul) in
  let f4 = f.(4ul) in
  let (o0,o1,o2,o3,o4) = fsqr5 (f0,f1,f2,f3,f4) in
  out.(size 0) <- o0;
  out.(size 1) <- o1;
  out.(size 2) <- o2;
  out.(size 3) <- o3;
  out.(size 4) <- o4

val fsqr2:
    out:felem2
  -> f:felem2
  -> Stack unit
    (requires fun h ->
      live h out /\ live h f /\
     (let f1 = gsub f 0ul 5ul in
      let f2 = gsub f 5ul 5ul in
      felem_fits h f1 (9, 10, 9, 9, 9) /\
      felem_fits h f2 (9, 10, 9, 9, 9)))
    (ensures  fun h0 _ h1 ->
      modifies (loc out) h0 h1 /\
     (let out1 = gsub out 0ul 5ul in
      let out2 = gsub out 5ul 5ul in
      let f1 = gsub f 0ul 5ul in
      let f2 = gsub f 5ul 5ul in
      felem_fits h1 out1 (1, 2, 1, 1, 1) /\
      felem_fits h1 out2 (1, 2, 1, 1, 1) /\
      fevalh h1 out1 == P.fsqr (fevalh h0 f1) /\
      fevalh h1 out2 == P.fsqr (fevalh h0 f2)))
[@ CInline]
let fsqr2 out f =
  let f10 = f.(0ul) in
  let f11 = f.(1ul) in
  let f12 = f.(2ul) in
  let f13 = f.(3ul) in
  let f14 = f.(4ul) in

  let f20 = f.(5ul) in
  let f21 = f.(6ul) in
  let f22 = f.(7ul) in
  let f23 = f.(8ul) in
  let f24 = f.(9ul) in

  let ((o10,o11,o12,o13,o14),(o20,o21,o22,o23,o24)) =
    fsqr25 (f10,f11,f12,f13,f14) (f20,f21,f22,f23,f24) in
  out.(size 0) <- o10;
  out.(size 1) <- o11;
  out.(size 2) <- o12;
  out.(size 3) <- o13;
  out.(size 4) <- o14;

  out.(size 5) <- o20;
  out.(size 6) <- o21;
  out.(size 7) <- o22;
  out.(size 8) <- o23;
  out.(size 9) <- o24

inline_for_extraction
val load_felem:
    f:felem
  -> u64s:lbuffer uint64 4ul
  -> Stack unit
    (requires fun h -> live h u64s /\ live h f)
    (ensures  fun h0 _ h1 -> modifies (loc f) h0 h1)
let load_felem f u64s =
  let f0l = u64s.(0ul) &. S.mask51 in
  let f0h = u64s.(0ul) >>. 51ul in
  let f1l = (u64s.(1ul) &. u64 0x3fffffffff) <<. 13ul in
  let f1h = u64s.(1ul) >>. 38ul in
  let f2l = (u64s.(2ul) &. u64 0x1ffffff) <<. 26ul in
  let f2h = u64s.(2ul) >>. 25ul in
  let f3l = (u64s.(3ul) &. u64 0xfff) <<. 39ul in
  let f3h = u64s.(3ul) >>. 12ul in
  f.(size 0) <- f0l;
  f.(size 1) <- f0h ^. f1l;
  f.(size 2) <- f1h ^. f2l;
  f.(size 3) <- f2h ^. f3l;
  f.(size 4) <- f3h

let uint64_eq_mask (a:uint64) (b:uint64) : uint64 =
  let x = a ^. b in
  let minus_x = (lognot x) +. (u64 1) in
  let x_or_minus_x = x |. minus_x in
  let xnx = x_or_minus_x >>. 63ul in
  let c = xnx -. (u64 1) in
  c

let uint64_gte_mask (a:uint64) (b:uint64) : uint64 =
  let x = a in
  let y = b in
  let x_xor_y = logxor x y in
  let x_sub_y = x -. y in
  let x_sub_y_xor_y = x_sub_y ^. y in
  let q = logor x_xor_y x_sub_y_xor_y in
  let x_xor_q = logxor x q in
  let x_xor_q_ = shift_right x_xor_q 63ul in
  let c = sub_mod x_xor_q_ (u64 1) in
  c

val store_felem:
    u64s:lbuffer uint64 4ul
  -> f:felem
  -> Stack unit
    (requires fun h -> live h f /\ live h u64s)
    (ensures  fun h0 _ h1 -> modifies (loc u64s) h0 h1)
let store_felem u64s f =
  let f0 = f.(0ul) in
  let f1 = f.(1ul) in
  let f2 = f.(2ul) in
  let f3 = f.(3ul) in
  let f4 = f.(4ul) in
  let (f0, f1, f2, f3, f4) = carry_felem5 (f0, f1, f2, f3, f4) in
  let (f0, f1, f2, f3, f4) = carry_felem5 (f0, f1, f2, f3, f4) in
  let m0 = uint64_gte_mask f0 (u64 0x7ffffffffffed) in
  let m1 = uint64_eq_mask f1 (u64 0x7ffffffffffff) in
  let m2 = uint64_eq_mask f2 (u64 0x7ffffffffffff) in
  let m3 = uint64_eq_mask f3 (u64 0x7ffffffffffff) in
  let m4 = uint64_eq_mask f4 (u64 0x7ffffffffffff) in
  let mask = m0 &. m1 &. m2 &. m3 &. m4 in
  let f0 = f0 -. (mask &. u64 0x7ffffffffffed) in
  let f1 = f1 -. (mask &. u64 0x7ffffffffffff) in
  let f2 = f2 -. (mask &. u64 0x7ffffffffffff) in
  let f3 = f3 -. (mask &. u64 0x7ffffffffffff) in
  let f4 = f4 -. (mask &. u64 0x7ffffffffffff) in
  let f0 = f0 ^. (f1 <<. 51ul) in
  let f1 = (f1 >>. 13ul) ^. (f2 <<. 38ul) in
  let f2 = (f2 >>. 26ul) ^. (f3 <<. 25ul) in
  let f3 = (f3 >>. 39ul) ^. (f4 <<. 12ul) in
  u64s.(0ul) <- f0;
  u64s.(1ul) <- f1;
  u64s.(2ul) <- f2;
  u64s.(3ul) <- f3


[@CInline]
val cswap2: bit:uint64 -> p1:felem2 -> p2:felem2 -> Stack unit
    (requires (fun h0 -> live h0 p1 /\ live h0 p2))
    (ensures (fun h0 _ h1 -> modifies (loc p1 |+| loc p2) h0 h1))
[@CInline]
let cswap2 bit p0 p1 =
    let mask = u64 0 -. bit in
    let h0 = ST.get() in
    loop2 h0 10ul p0 p1
    (fun h -> (fun i s -> s))
    (fun i ->
         let dummy = mask &. (p0.(i) ^. p1.(i)) in
         p0.(i) <- p0.(i) ^. dummy;
         p1.(i) <- p1.(i) ^. dummy;
	 admit())
