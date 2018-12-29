module Hacl.Impl.Curve25519.Generic

open FStar.HyperStack
open FStar.HyperStack.All

open Lib.IntTypes
open Lib.Buffer
open Lib.ByteBuffer

open Hacl.Impl.Curve25519.Fields

include Hacl.Impl.Curve25519.Finv

module ST = FStar.HyperStack.ST

module F26 = Hacl.Impl.Curve25519.Field26
module F51 = Hacl.Impl.Curve25519.Field51
module F64 = Hacl.Impl.Curve25519.Field64

#set-options "--z3rlimit 50 --max_fuel 2 --max_ifuel 2"
#set-options "--debug Hacl.Impl.Curve25519.Generic --debug_level ExtractNorm"

inline_for_extraction noextract
val footprint: h0:mem ->
	     l:Ghost.erased LowStar.Buffer.loc ->
	     impl: (unit -> Stack unit
			   (requires (fun h -> modifies (Ghost.reveal l) h0 h))
			   (ensures (fun h _ h' -> modifies (Ghost.reveal l) h h'))) ->
	     Stack unit
	      (requires (fun h -> modifies (Ghost.reveal l) h0 h))
	      (ensures (fun _ _ h -> modifies (Ghost.reveal l) h0 h))
inline_for_extraction noextract
let footprint h0 l impl = impl()

unfold let scalar = lbuffer uint64 4ul
unfold let point (s:field_spec) = lbuffer (limb s) (2ul *. nlimb s)

(* NEEDED ONLY FOR WRAPPERS *)
unfold let point26 = lbuffer uint64 20ul
unfold let point51 = lbuffer uint64 10ul
unfold let point64 = lbuffer uint64 8ul
(* NEEDED ONLY FOR WRAPPERS *)


inline_for_extraction
val decode_scalar: o:scalar -> i:lbuffer uint8 32ul -> Stack unit
			 (requires fun h0 -> live h0 o /\ live h0 i /\ disjoint o i)
			 (ensures fun h0 _ h1 -> modifies (loc o) h0 h1)
inline_for_extraction
let decode_scalar o i =
  uints_from_bytes_le #U64 o i;
  o.(0ul) <- o.(0ul) &. u64 0xfffffffffffffff8;
  o.(3ul) <- o.(3ul) &. u64 0x7fffffffffffffff;
  o.(3ul) <- o.(3ul) |. u64 0x4000000000000000

inline_for_extraction
val scalar_bit: s:scalar -> n:size_t{v n < 256} -> Stack uint64
			 (requires fun h0 -> live h0 s)
			 (ensures fun h0 r h1 -> h0 == h1)
inline_for_extraction
let scalar_bit s n = (s.(n /. 64ul) >>. (n %. 64ul)) &. (u64 1)

inline_for_extraction
val decode_point_: #s:field_spec -> o:point s -> i:lbuffer uint8 32ul -> Stack unit
				  (requires fun h0 -> live h0 o /\ live h0 i /\ disjoint o i)
				 (ensures fun h0 _ h1 -> modifies (loc o) h0 h1)

inline_for_extraction
let decode_point_ #s o i =
  push_frame();
  let tmp = create 4ul (u64 0) in
  uints_from_bytes_le #U64 tmp i;
  tmp.(3ul) <- tmp.(3ul) &. u64 0x7fffffffffffffff;
  let x : felem s = sub o 0ul (nlimb s) in
  let z : felem s = sub o (nlimb s) (nlimb s) in
  set_one z;
  load_felem x tmp;
  pop_frame()

(* WRAPPER to Prevent Inlining *)
inline_for_extraction
let decode_point_26 (o:point26) i = decode_point_ #M26 o i
inline_for_extraction
let decode_point_51 (o:point51) i = decode_point_ #M51 o i
inline_for_extraction
let decode_point_64 (o:point64) i = decode_point_ #M64 o i
inline_for_extraction
val decode_point: #s:field_spec -> o:point s -> i:lbuffer uint8 32ul -> Stack unit
				  (requires fun h0 -> live h0 o /\ live h0 i /\ disjoint o i)
				 (ensures fun h0 _ h1 -> modifies (loc o) h0 h1)

inline_for_extraction
let decode_point #s o i =
  match s with
  | M26 -> decode_point_26 o i
  | M51 -> decode_point_51 o i
  | M64 -> decode_point_64 o i
(* WRAPPER to Prevent Inlining *)


inline_for_extraction
val encode_point_: #s:field_spec -> o:lbuffer uint8 32ul -> i:point s  -> Stack unit
				  (requires fun h0 -> live h0 o /\ live h0 i /\ disjoint o i)
				 (ensures fun h0 _ h1 -> modifies (loc o) h0 h1)

inline_for_extraction
let encode_point_ #s o i =
  push_frame();
  let x : felem s = sub i 0ul (nlimb s) in
  let z : felem s = sub i (nlimb s) (nlimb s) in
  let tmp = create_felem s in
  let u64s = create 4ul (u64 0) in
  let tmp_w = create (2ul *. nwide s) (wide_zero s) in
  admit();  
  finv #s tmp z tmp_w;
  fmul #s tmp tmp x tmp_w;
  store_felem u64s tmp;
  uints_to_bytes_le #U64 4ul o u64s;
  pop_frame()

(* WRAPPER to Prevent Inlining *)
inline_for_extraction
let encode_point_26 o (i:point26) = encode_point_ #M26 o i
inline_for_extraction
let encode_point_51 o (i:point51) = encode_point_ #M51 o i
inline_for_extraction
let encode_point_64 o (i:point64) = encode_point_ #M64 o i
inline_for_extraction
val encode_point: #s:field_spec -> o:lbuffer uint8 32ul -> i:point s  -> Stack unit
				  (requires fun h0 -> live h0 o /\ live h0 i /\ disjoint o i)
				 (ensures fun h0 _ h1 -> modifies (loc o) h0 h1)
inline_for_extraction
let encode_point #s o i =
  match s with
  | M26 -> encode_point_26 o i
  | M51 -> encode_point_51 o i
  | M64 -> encode_point_64 o i
(* WRAPPER to Prevent Inlining *)


inline_for_extraction
val point_add_and_double_: #s:field_spec -> q:point s -> nq: point s -> nq_p1:point s ->
			   tmp1:lbuffer (limb s) (4ul *. nlimb s) ->
			   tmp2:felem_wide2 s ->
    Stack unit
    (requires fun h0 -> live h0 q /\ live h0 nq /\ live h0 nq_p1 /\ live h0 tmp1 /\ live h0 tmp2)
    (ensures fun h0 _ h1 -> modifies (loc nq |+| loc nq_p1 |+| loc tmp1 |+| loc tmp2) h0 h1)
inline_for_extraction
let point_add_and_double_ #s q nq nq_p1 tmp1 tmp2 =
   let x1 = sub q 0ul (nlimb s) in
   let z1 = sub q (nlimb s) (nlimb s) in
   let x2 = sub nq 0ul (nlimb s) in
   let z2 = sub nq (nlimb s) (nlimb s) in
   let x3 = sub nq_p1 0ul (nlimb s) in
   let z3 = sub nq_p1 (nlimb s) (nlimb s) in
   let a : felem s = sub tmp1 0ul (nlimb s) in
   let b : felem s = sub tmp1 (nlimb s) (nlimb s) in
   let d : felem s = sub tmp1 (2ul *. nlimb s) (nlimb s) in
   let c : felem s = sub tmp1 (3ul *. nlimb s) (nlimb s) in
   let ab : felem2 s = sub tmp1 0ul (2ul *. nlimb s) in
   let dc : felem2 s = sub tmp1 (2ul *. nlimb s) (2ul *. nlimb s) in
   let gloc = Ghost.hide (loc nq |+| loc nq_p1 |+| loc tmp1 |+| loc tmp2) in
   let h0 = ST.get() in
   admit();
   footprint h0 gloc (fun () -> fadd a x2 z2); // a = x2 + z2
   footprint h0 gloc (fun () -> fsub b x2 z2); // b = x2 - z2
   footprint h0 gloc (fun () -> fadd c x3 z3); // c = x3 + z3
   footprint h0 gloc (fun () -> fsub d x3 z3); // d = x3 - z3

   (* CAN RUN IN PARALLEL *)
//   footprint h0 gloc (fun () -> fmul d d a);   // d = da = d * a
//   footprint h0 gloc (fun () -> fmul c c b);   // c = cb = c * b
   footprint h0 gloc (fun () -> fmul2 dc dc ab tmp2);   // d|c = d*a|c*b

   footprint h0 gloc (fun () -> fadd x3 d c);  // x3 = da + cb
   footprint h0 gloc (fun () -> fsub z3 d c);  // z3 = da - cb

   (* CAN RUN IN PARALLEL *)
//   footprint h0 gloc (fun () -> fsqr d a);     // d = aa = a^2
//   footprint h0 gloc (fun () -> fsqr c b);     // c = bb = b^2
   footprint h0 gloc (fun () -> fsqr2 dc ab tmp2);     // d|c = aa | bb

   //moving the following line gave me a 2k speedup.
   (* CAN RUN IN PARALLEL *)
//   footprint h0 gloc (fun () -> fsqr x3 x3);   // x3 = (da + cb) ^ 2
//   footprint h0 gloc (fun () -> fsqr z3 z3);   // z3 = (da - cb) ^ 2
   footprint h0 gloc (fun () -> fsqr2 nq_p1 nq_p1 tmp2);   // x3|z3 = x3*x3|z3*z3

   copy_felem a c;                           // a = bb
   footprint h0 gloc (fun () -> fsub c d c);   // c = e = aa - bb
   footprint h0 gloc (fun () -> fmul1 b c (u64 121665)); // b = e * 121665
   footprint h0 gloc (fun () -> fadd b b d);   // b = (e * 121665) + aa

   (* CAN RUN IN PARALLEL *)
//   footprint h0 gloc (fun () -> fmul x2 d a);  // x2 = aa * bb
//   footprint h0 gloc (fun () -> fmul z2 c b);  // z2 = e * (aa + (e * 121665))
   footprint h0 gloc (fun () -> fmul2 nq dc ab tmp2);  // x2|z2 = aa * bb | e * (aa + (e * 121665))
   // moving the following line gives a 2k speedup
   footprint h0 gloc (fun () -> fmul z3 z3 x1 tmp2) // z3 = x1 * (da - cb) ^ 2

(* WRAPPER to Prevent Inlining *)
[@CInline]
let point_add_and_double_26  (q:point26) (nq:point26) (nq_p1:point26) tmp1 tmp2 = point_add_and_double_ #M26 q nq nq_p1 tmp1 tmp2
[@CInline]
let point_add_and_double_51  (q:point51) (nq:point51) (nq_p1:point51) tmp1 tmp2 = point_add_and_double_ #M51 q nq nq_p1 tmp1 tmp2
[@CInline]
let point_add_and_double_64  (q:point64) (nq:point64) (nq_p1:point64) tmp1 tmp2 = point_add_and_double_ #M64 q nq nq_p1 tmp1 tmp2
inline_for_extraction
val point_add_and_double: #s:field_spec -> q:point s -> nq: point s -> nq_p1:point s ->
			   tmp1:lbuffer (limb s) (4ul *. nlimb s) ->
			   tmp2:felem_wide2 s -> Stack unit
				(requires fun h0 -> live h0 q /\ live h0 nq /\ live h0 nq_p1 /\ live h0 tmp1 /\ live h0 tmp2)
				(ensures fun h0 _ h1 -> modifies (loc nq |+| loc nq_p1 |+| loc tmp1 |+| loc tmp2) h0 h1)
inline_for_extraction
let point_add_and_double #s q nq nq_p1 tmp1 tmp2 =
  match s with
  | M26 -> point_add_and_double_26 q nq nq_p1 tmp1 tmp2
  | M51 -> point_add_and_double_51 q nq nq_p1 tmp1 tmp2
  | M64 -> point_add_and_double_64 q nq nq_p1 tmp1 tmp2
(* WRAPPER to Prevent Inlining *)

inline_for_extraction
val point_double_: #s:field_spec -> nq: point s ->
		   tmp1:lbuffer (limb s) (4ul *. nlimb s) ->
		   tmp2:felem_wide2 s ->
		   Stack unit
				(requires fun h0 -> live h0 nq /\ live h0 tmp1 /\ live h0 tmp2)
				(ensures fun h0 _ h1 -> modifies (loc nq |+| loc tmp1 |+| loc tmp2) h0 h1)
inline_for_extraction
let point_double_ #s nq tmp1 tmp2 =
   push_frame();
   let x2 = sub nq 0ul (nlimb s) in
   let z2 = sub nq (nlimb s) (nlimb s) in
   let a : felem s = sub tmp1 0ul (nlimb s) in
   let b : felem s = sub tmp1 (nlimb s) (nlimb s) in
   let d : felem s = sub tmp1 (2ul *. nlimb s) (nlimb s) in
   let c : felem s = sub tmp1 (3ul *. nlimb s) (nlimb s) in
   let ab : felem2 s = sub tmp1 0ul (2ul *. nlimb s) in
   let dc : felem2 s = sub tmp1 (2ul *. nlimb s) (2ul *. nlimb s) in
   let gloc = Ghost.hide (loc nq |+| loc tmp1 |+| loc tmp2) in
   let h0 = ST.get() in
   admit();
   footprint h0 gloc (fun () -> fadd a x2 z2); // a = x2 + z2
   footprint h0 gloc (fun () -> fsub b x2 z2); // b = x2 - z2

   (* CAN RUN IN PARALLEL *)
//   footprint h0 gloc (fun () -> fsqr d a);     // d = aa = a^2
//   footprint h0 gloc (fun () -> fsqr c b);     // c = bb = b^2
   footprint h0 gloc (fun () -> fsqr2 dc ab tmp2);     // d|c = aa | bb

   copy_felem a c;                           // a = bb
   footprint h0 gloc (fun () -> fsub c d c);   // c = e = aa - bb
   footprint h0 gloc (fun () -> fmul1 b c (u64 121665)); // b = e * 121665
   footprint h0 gloc (fun () -> fadd b b d);   // b = (e * 121665) + aa

   (* CAN RUN IN PARALLEL *)
//   footprint h0 gloc (fun () -> fmul x2 d a);  // x2 = aa * bb
//   footprint h0 gloc (fun () -> fmul z2 c b);  // z2 = e * (aa + (e * 121665))
   footprint h0 gloc (fun () -> fmul2 nq dc ab tmp2);  // x2|z2 = aa * bb | e * (aa + (e * 121665))
   pop_frame()

(* WRAPPER to Prevent Inlining *)
[@CInline]
let point_double_26  (nq:point26) tmp1 tmp2 = point_double_ #M26 nq  tmp1 tmp2
[@CInline]
let point_double_51  (nq:point51) tmp1 tmp2 = point_double_ #M51 nq tmp1 tmp2
[@CInline]
let point_double_64  (nq:point64) tmp1 tmp2 = point_double_ #M64 nq tmp1 tmp2
inline_for_extraction
val point_double: #s:field_spec -> nq: point s ->
		   tmp1:lbuffer (limb s) (4ul *. nlimb s) ->
		   tmp2:felem_wide2 s -> Stack unit
				(requires fun h0 -> live h0 nq /\ live h0 tmp1 /\ live h0 tmp2)
				(ensures fun h0 _ h1 -> modifies (loc nq |+| loc tmp1 |+| loc tmp2) h0 h1)
inline_for_extraction
let point_double #s nq tmp1 tmp2 =
  match s with
  | M26 -> point_double_26 nq tmp1 tmp2
  | M51 -> point_double_51 nq tmp1 tmp2
  | M64 -> point_double_64 nq tmp1 tmp2
(* WRAPPER to Prevent Inlining *)




inline_for_extraction
val montgomery_ladder_: #s:field_spec -> o:point s -> k:scalar -> i:point s -> Stack unit
			  (requires (fun h0 -> live h0 o /\ live h0 k /\ live h0 i))
			  (ensures (fun h0 _ h1 -> modifies (loc o) h0 h1))

inline_for_extraction
let montgomery_ladder_ #s out key init =
  push_frame();
  admit();
  let p01 = create (4ul *. nlimb s) (limb_zero s) in
  let p0 : point s = sub p01 0ul (2ul *. nlimb s) in
  let p1 : point s = sub p01 (2ul *. nlimb s) (2ul *. nlimb s) in
  copy p1 init;
  let x0 : felem s = sub p0 0ul (nlimb s) in
  let z0 : felem s = sub p0 (nlimb s) (nlimb s) in
  set_one x0;
  let swap = create 1ul (u64 0) in
  let tmp1 = create (4ul *. nlimb s) (limb_zero s) in
  let tmp2 = create (2ul *. nwide s) (wide_zero s) in
  let h0 = ST.get() in
  //Got about 1K speedup by removing 4 iterations here.
  //First iteration can be skipped because top bit of scalar is 0
  loop2 h0 252ul p01 swap
    (fun h -> (fun i s -> s))
    (fun i ->
         let bit = scalar_bit key (254ul -. i) in
	 let sw = swap.(0ul) ^. bit in
         cswap2 #s sw p0 p1;
         point_add_and_double #s init p0 p1 tmp1 tmp2;
	 swap.(0ul) <- bit;
	 admit());
  cswap2 #s swap.(0ul) p0 p1;
  //Last three iterations are point doublings because the bottom 3 bits are 0
  point_double p0 tmp1 tmp2;
  point_double p0 tmp1 tmp2;
  point_double p0 tmp1 tmp2;
  copy out p0;
  pop_frame()

(* WRAPPER to Prevent Inlining *)
[@CInline]
let montgomery_ladder_26 (out:point26) key (init:point26) = montgomery_ladder_ #M26 out key init
[@CInline]
let montgomery_ladder_51 (out:point51) key (init:point51) = montgomery_ladder_ #M51 out key init
[@CInline]
let montgomery_ladder_64 (out:point64) key (init:point64) = montgomery_ladder_ #M64 out key init
inline_for_extraction
val montgomery_ladder: #s:field_spec -> o:point s -> k:scalar -> i:point s -> Stack unit
			  (requires (fun h0 -> live h0 o /\ live h0 k /\ live h0 i))
			  (ensures (fun h0 _ h1 -> modifies (loc o) h0 h1))
let montgomery_ladder #s out key init =
  match s with
  | M26 -> montgomery_ladder_26 out key init
  | M51 -> montgomery_ladder_51 out key init
  | M64 -> montgomery_ladder_64 out key init
(* WRAPPER to Prevent Inlining *)

inline_for_extraction
val scalarmult: #s:field_spec
    -> o:lbuffer uint8 32ul
    -> k:lbuffer uint8 32ul
    -> i:lbuffer uint8 32ul ->
    Stack unit
    (requires (fun h0 -> live h0 o /\ live h0 k /\ live h0 i))
    (ensures (fun h0 _ h1 -> modifies (loc o) h0 h1))

inline_for_extraction
let scalarmult #s out priv pub =
    push_frame ();
    let scalar = create 4ul (u64 0) in
    decode_scalar scalar priv;
    let init = create (2ul *. nlimb s) (limb_zero s) in
    decode_point #s init pub;
    montgomery_ladder #s init scalar init;
    encode_point #s out init;
    pop_frame()

inline_for_extraction noextract
let l : List.Tot.llist byte_t 32 =
  [@inline_let]
  let l_ = [9uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy;
	    0uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy;
	    0uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy;
	    0uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy] in
  assert_norm (List.Tot.length l_ == 32);
  l_

let g25519 : x:ilbuffer byte_t 32ul{recallable x /\ witnessed x (Seq.of_list l)}=
  [@inline_let]
  let l_ = [9uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy;
	    0uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy;
	    0uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy;
	    0uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy; 0uy] in
  assert_norm (List.Tot.length l_ == 32);
  createL_global l

inline_for_extraction
val secret_to_public: #s:field_spec
    -> o:lbuffer uint8 32ul
    -> i:lbuffer uint8 32ul ->
    Stack unit
    (requires (fun h0 -> live h0 o /\ live h0 i))
    (ensures (fun h0 _ h1 -> modifies (loc o) h0 h1))
inline_for_extraction
let secret_to_public #s pub priv =
  push_frame ();
  recall_contents g25519 (Seq.of_list l);
  let basepoint = create 32ul (u8 0) in
  mapT 32ul basepoint secret g25519;
  scalarmult #s pub priv basepoint;
  pop_frame()
