module Hacl.Impl.Curve25519.Fields

open FStar.HyperStack
open FStar.HyperStack.All
open FStar.Mul

open Lib.IntTypes
open Lib.Buffer

module ST = FStar.HyperStack.ST

module F26 = Hacl.Impl.Curve25519.Field26
module F51 = Hacl.Impl.Curve25519.Field51
module F64 = Hacl.Impl.Curve25519.Field64
module P = NatPrime

type field_spec =
  | M26
  | M51
  | M64


unfold
let limb (s:field_spec) =
  match s with
  | M26 -> uint64
  | M51 -> uint64
  | M64 -> uint64

unfold
let limb_zero (s:field_spec) : limb s=
  match s with
  | M26 -> u64 0
  | M51 -> u64 0
  | M64 -> u64 0

unfold
let nlimb (s:field_spec) : size_t =
  match s with
  | M26 -> 10ul
  | M51 -> 5ul
  | M64 -> 4ul

unfold
let wide (s:field_spec) =
  match s with
  | M26 -> uint64
  | M51 -> uint128
  | M64 -> uint64


unfold
let wide_zero (s:field_spec) : wide s=
  match s with
  | M26 -> u64 0
  | M51 -> u128 0
  | M64 -> u64 0

unfold
let nwide (s:field_spec) : size_t =
  match s with
  | M26 -> 10ul
  | M51 -> 5ul
  | M64 -> 8ul

type felem (s:field_spec) = lbuffer (limb s) (nlimb s)
type felem2 (s:field_spec) = lbuffer (limb s) (nlimb s +. nlimb s)
type felem_wide (s:field_spec) = lbuffer (wide s) (nwide s)
type felem_wide2 (s:field_spec) = lbuffer (wide s) (nwide s +. nwide s)

noextract
val as_nat: #s:field_spec -> h:mem -> e:felem s -> GTot nat
let as_nat #s h e =
  match s with
  | M26 -> F26.as_nat h e
  | M51 -> F51.as_nat h e
  | M64 -> F64.as_nat h e

noextract
val feval: #s:field_spec -> h:mem -> e:felem s -> GTot P.felem
let feval #s h e =
  match s with
  | M26 -> admit()
  | M51 -> F51.fevalh h e
  | M64 -> F64.fevalh h e

inline_for_extraction
val create_felem:
    s:field_spec
  -> StackInline (felem s)
    (requires fun h -> True)
    (ensures  fun h0 f h1 ->
      stack_allocated f h0 h1 (Seq.create (v (nlimb s)) (limb_zero s)) /\
      as_nat h1 f == 0)
let create_felem s =
  match s with
  | M26 -> (F26.create_felem ()) <: felem s
  | M51 -> (F51.create_felem ()) <: felem s
  | M64 -> (F64.create_felem ()) <: felem s

inline_for_extraction
val load_felem:
    #s:field_spec
  -> f:felem s
  -> u64s:lbuffer uint64 4ul
  -> Stack unit
    (requires fun h -> live h f /\ live h u64s)
    (ensures  fun h0 _ h1 -> modifies (loc f) h0 h1)
let load_felem #s f b =
  match s with
  | M26 -> F26.load_felem f b
  | M51 -> F51.load_felem f b
  | M64 -> F64.load_felem f b

inline_for_extraction
val store_felem:
    #s:field_spec
  -> b:lbuffer uint64 4ul
  -> f:felem s
  -> Stack unit
    (requires (fun h -> live h f /\ live h b))
    (ensures (fun h0 _ h1 -> modifies (loc b |+| loc f) h0 h1))
let store_felem #s b f =
  match s with
  | M26 -> F26.store_felem b f
  | M51 -> F51.store_felem b f
  | M64 -> F64.store_felem b f

inline_for_extraction
val set_zero:
    #s:field_spec
  -> f:felem s
  -> Stack unit
    (requires fun h -> live h f)
    (ensures  fun h0 _ h1 ->
      modifies (loc f) h0 h1 /\
      as_nat h1 f == 0)
let set_zero #s f =
  match s with
  | M26 -> F26.set_zero f
  | M51 -> F51.set_zero f
  | M64 -> F64.set_zero f

inline_for_extraction
val set_one:
    #s:field_spec
  -> f:felem s
  -> Stack unit
    (requires fun h -> live h f)
    (ensures  fun h0 _ h1 ->
      modifies (loc f) h0 h1 /\
      as_nat h1 f == 1)
let set_one #s f =
  match s with
  | M26 -> F26.set_one f
  | M51 -> F51.set_one f
  | M64 -> F64.set_one f

inline_for_extraction
val copy_felem:
    #s:field_spec
  -> f:felem s
  -> f':felem s
  -> Stack unit
    (requires fun h -> live h f /\ live h f' /\ disjoint f f')
    (ensures  fun h0 _ h1 ->
      modifies (loc f) h0 h1 /\
      as_nat h1 f == as_nat h0 f')
let copy_felem #s f f' =
  match s with
  | M26 -> F26.copy_felem f f'
  | M51 -> F51.copy_felem f f'
  | M64 -> F64.copy_felem f f'

val fadd_fsub_pre: #s:field_spec -> h:mem -> f1:felem s -> f2:felem s -> Type0
let fadd_fsub_pre #s h f1 f2 =
  match s with
  | M26 -> True
  | M51 -> F51.felem_fits h f1 (1, 2, 1, 1, 1) /\ F51.felem_fits h f2 (1, 2, 1, 1, 1)
  | M64 -> True

val fadd_post: #s:field_spec -> h:mem -> out:felem s -> Type0
let fadd_post #s h out =
  match s with
  | M26 -> True
  | M51 -> F51.felem_fits h out (2, 4, 2, 2, 2)
  | M64 -> True

inline_for_extraction
val fadd:
    #s:field_spec
  -> out:felem s
  -> f1:felem s
  -> f2:felem s
  -> Stack unit
    (requires fun h -> live h out /\ live h f1 /\ live h f2 /\ fadd_fsub_pre h f1 f2)
    (ensures  fun h0 _ h1 ->
      modifies (loc out) h0 h1 /\ fadd_post h1 out /\
      feval h1 out == P.fadd (feval h0 f1) (feval h0 f2))
let fadd #s out f1 f2=
  match s with
  | M26 -> admit(); F26.fadd out f1 f2
  | M51 -> F51.fadd out f1 f2
  | M64 -> F64.fadd out f1 f2

val fsub_post:#s:field_spec -> h:mem -> out:felem s -> Type0
let fsub_post #s h out =
  match s with
  | M26 -> True
  | M51 -> F51.felem_fits h out (9, 10, 9, 9, 9)
  | M64 -> True

inline_for_extraction
val fsub:
    #s:field_spec
  -> out:felem s
  -> f1:felem s
  -> f2:felem s
  -> Stack unit
    (requires fun h ->
      live h out /\ live h f1 /\ live h f2 /\
      fadd_fsub_pre h f1 f2)
    (ensures fun h0 _ h1 ->
      modifies (loc out) h0 h1 /\ fsub_post h1 out /\
      feval h1 out == P.fsub (feval h0 f1) (feval h0 f2))
let fsub #s out f1 f2=
  match s with
  | M26 -> admit(); F26.fsub out f1 f2
  | M51 -> F51.fsub out f1 f2
  | M64 -> F64.fsub out f1 f2

val fmul_pre:#s:field_spec -> h:mem -> f1:felem s -> f2:felem s -> Type0
let fmul_pre #s h f1 f2 =
  match s with
  | M26 -> True
  | M51 -> F51.felem_fits h f1 (9, 10, 9, 9, 9) /\ F51.felem_fits h f2 (9, 10, 9, 9, 9)
  | M64 -> True

val fmul_fsqr_post:#s:field_spec -> h:mem -> out:felem s -> Type0
let fmul_fsqr_post #s h out =
  match s with
  | M26 -> True
  | M51 -> F51.felem_fits h out (1, 2, 1, 1, 1)
  | M64 -> True

inline_for_extraction
val fmul:
    #s:field_spec
  -> out:felem s
  -> f1:felem s
  -> f2:felem s
  -> tmp:felem_wide2 s
  -> Stack unit
    (requires fun h ->
      live h out /\ live h f1 /\ live h f2 /\ live h tmp /\ fmul_pre h f1 f2)
    (ensures fun h0 _ h1 ->
      modifies (loc out |+| loc tmp) h0 h1 /\ fmul_fsqr_post h1 out /\
      feval h1 out == P.fmul (feval h0 f1) (feval h0 f2))
let fmul #s out f1 f2 tmp =
  match s with
  | M26 -> admit(); F26.fmul out f1 f2
  | M51 -> F51.fmul out f1 f2
  | M64 -> F64.fmul out f1 f2 tmp

val fmul2_pre:#s:field_spec -> h:mem -> f1:felem2 s -> f2:felem2 s -> Type0
let fmul2_pre #s h f1 f2 =
  match s with
  | M26 -> True
  | M51 ->
      let f10 = gsub f1 0ul 5ul in
      let f11 = gsub f1 5ul 5ul in
      let f20 = gsub f2 0ul 5ul in
      let f21 = gsub f2 5ul 5ul in
      F51.felem_fits h f10 (9, 10, 9, 9, 9) /\
      F51.felem_fits h f11 (9, 10, 9, 9, 9) /\
      F51.felem_fits h f20 (9, 10, 9, 9, 9) /\
      F51.felem_fits h f21 (9, 10, 9, 9, 9)
  | M64 -> True

val fmul2_fsqr2_post:#s:field_spec -> h:mem -> out:felem2 s -> Type0
let fmul2_fsqr2_post #s h out =
  match s with
  | M26 -> True
  | M51 ->
      let out0 = gsub out 0ul 5ul in
      let out1 = gsub out 5ul 5ul in
      F51.felem_fits h out0 (1, 2, 1, 1, 1) /\
      F51.felem_fits h out1 (1, 2, 1, 1, 1)
  | M64 -> True

#set-options "--max_fuel 0 --max_ifuel 1"

inline_for_extraction
val fmul2:
    #s:field_spec
  -> out:felem2 s
  -> f1:felem2 s
  -> f2:felem2 s
  -> tmp:felem_wide2 s
  -> Stack unit
    (requires fun h ->
      live h out /\ live h f1 /\ live h f2 /\ live h tmp /\ fmul2_pre h f1 f2)
    (ensures  fun h0 _ h1 ->
      modifies (loc out |+| loc tmp) h0 h1 /\ fmul2_fsqr2_post h1 out /\
     (let out0 = gsub out 0ul (nlimb s) in
      let out1 = gsub out (nlimb s) (nlimb s) in
      let f10 = gsub f1 0ul (nlimb s) in
      let f11 = gsub f1 (nlimb s) (nlimb s) in
      let f20 = gsub f2 0ul (nlimb s) in
      let f21 = gsub f2 (nlimb s) (nlimb s) in
      feval h1 out0 == P.fmul (feval h0 f10) (feval h0 f20) /\
      feval h1 out1 == P.fmul (feval h0 f11) (feval h0 f21)))
let fmul2 #s out f1 f2 tmp =
  match s with
  | M26 -> admit(); F26.fmul2 out f1 f2
  | M51 -> F51.fmul2 out f1 f2
  | M64 -> F64.fmul2 out f1 f2 tmp

val fmul1_pre:#s:field_spec -> h:mem -> f1:felem s -> f2:uint64 -> Type0
let fmul1_pre #s h f1 f2 =
  match s with
  | M26 -> True
  | M51 -> F51.felem_fits h f1 (9, 10, 9, 9, 9) /\ F51.felem_fits1 f2 1
  | M64 -> v f2 < pow2 17

inline_for_extraction
val fmul1:
    #s:field_spec
  -> out:felem s
  -> f1:felem s
  -> f2:uint64
  -> Stack unit
    (requires fun h -> live h out /\ live h f1 /\ fmul1_pre h f1 f2)
    (ensures  fun h0 _ h1 ->
      modifies (loc out) h0 h1 /\ fmul_fsqr_post h1 out /\
      feval h1 out == (feval h0 f1 * v f2) % P.prime)
let fmul1 #s out f1 f2 =
  match s with
  | M26 -> admit(); F26.fmul1 out f1 f2
  | M51 -> F51.fmul1 out f1 f2
  | M64 -> F64.fmul1 out f1 f2

val fsqr_pre:#s:field_spec -> h:mem -> f:felem s -> Type0
let fsqr_pre #s h f =
  match s with
  | M26 -> True
  | M51 -> F51.felem_fits h f (9, 10, 9, 9, 9)
  | M64 -> True

inline_for_extraction
val fsqr:
    #s:field_spec
  -> out:felem s
  -> f1:felem s
  -> tmp:felem_wide2 s
  -> Stack unit
    (requires fun h -> live h out /\ live h f1 /\ live h tmp /\ fsqr_pre h f1)
    (ensures  fun h0 _ h1 ->
      modifies (loc out |+| loc tmp) h0 h1 /\ fmul_fsqr_post h1 out /\
      feval h1 out == P.fmul (feval h0 f1) (feval h0 f1))
let fsqr #s out f1 tmp =
  match s with
  | M26 -> admit(); F26.fsqr out f1
  | M51 -> F51.fsqr out f1
  | M64 -> F64.fsqr out f1 tmp

val fsqr2_pre:#s:field_spec -> h:mem -> f:felem2 s -> Type0
let fsqr2_pre #s h f =
  match s with
  | M26 -> True
  | M51 ->
      let f1 = gsub f 0ul 5ul in
      let f2 = gsub f 5ul 5ul in
      F51.felem_fits h f1 (9, 10, 9, 9, 9) /\
      F51.felem_fits h f2 (9, 10, 9, 9, 9)
  | M64 -> True

inline_for_extraction
val fsqr2:
    #s:field_spec
  -> out:felem2 s
  -> f:felem2 s
  -> tmp:felem_wide2 s
  -> Stack unit
    (requires fun h -> live h out /\ live h f /\ live h tmp /\ fsqr2_pre h f)
    (ensures  fun h0 _ h1 ->
      modifies (loc out |+| loc tmp) h0 h1 /\ fmul2_fsqr2_post h1 out /\
     (let out1 = gsub out 0ul (nlimb s) in
      let out2 = gsub out (nlimb s) (nlimb s) in
      let f1 = gsub f 0ul (nlimb s) in
      let f2 = gsub f (nlimb s) (nlimb s) in
      feval h1 out1 == P.fmul (feval h0 f1) (feval h0 f1) /\
      feval h1 out2 == P.fmul (feval h0 f2) (feval h0 f2)))
let fsqr2 #s out f tmp =
  match s with
  | M26 -> admit();F26.fsqr2 out f
  | M51 -> F51.fsqr2 out f
  | M64 -> F64.fsqr2 out f tmp

inline_for_extraction
val cswap2: #s:field_spec -> bit:uint64 -> p1:felem2 s -> p2:felem2 s -> Stack unit
    (requires (fun h0 -> live h0 p1 /\ live h0 p2))
    (ensures (fun h0 _ h1 -> modifies (loc p1 |+| loc p2) h0 h1))
[@CInline]
let cswap2 #s bit p0 p1 =
  match s with
  | M26 -> admit()
  | M51 -> F51.cswap2 bit p0 p1
  | M64 -> F64.cswap2 bit p0 p1
