module Poly1305_64

open FStar.Mul
open FStar.ST
open FStar.Ghost
open FStar.Seq
open FStar.HyperStack
open FStar.Endianness
open FStar.Buffer
open Hacl.Cast


module H8   = Hacl.UInt8
module Limb = Hacl.Bignum.Limb
module Wide = Hacl.Bignum.Wide
module U8   = FStar.UInt8
module U32  = FStar.UInt32
module U64  = FStar.UInt64
module I = Hacl.Impl.Poly1305_64
module S = Hacl.Spec.Poly1305_64
module Poly = Hacl.Standalone.Poly1305_64
       	      

(* Type Aliases *)
type uint8_p = Buffer.buffer Hacl.UInt8.t
type key = k:uint8_p{length k = 32}

type state = I.poly1305_state
type live_state (h:mem) (st:state) = I.live_st h st
type stable (h:mem) (st:state) = live_state h st /\ S.red_45 (as_seq h I.(st.h)) /\ S.red_44 (as_seq h I.(st.r))

private let get_key (st:state) = I.(st.r)
private let get_accumulator (st:state) = I.(st.h)

#reset-options "--initial_fuel 0 --max_fuel 0 --z3rlimit 100"

val alloc:
  unit -> StackInline state
    (requires (fun h -> True))
    (ensures (fun h0 st h1 -> modifies_0 h0 h1 /\ I.live_st h1 st /\ frameOf I.(st.h) == h0.tip
      /\ frameOf I.(st.r) = h0.tip /\ ~(contains h0 I.(st.r)) /\ ~(contains h0 I.(st.h))))
let alloc () =
  I.alloc()

val mk_state:
  r:buffer Hacl.UInt64.t{length r = 3} -> acc:buffer Hacl.UInt64.t{length acc = 3 /\ disjoint r acc} ->
  Stack state
    (requires (fun h -> live h r /\ live h acc))
    (ensures (fun h0 st h1 -> h0 == h1 /\ I.(st.r) == r /\ I.(st.h) == acc /\ I.live_st h1 st))
let mk_state r acc = I.mk_state r acc


val init:
  st:state ->
  k:uint8_p{length k >= 16} ->
  Stack unit
    (requires (fun h -> live h k /\ live_state h st))
    (ensures (fun h0 _ h1 -> modifies_2 (get_key st) (get_accumulator st) h0 h1 /\ stable h1 st))
let init st k =
  let _ = I.poly1305_init_ st (Buffer.sub k 0ul 16ul) in ()

let empty_log : I.log_t = Ghost.hide (Seq.createEmpty)

val update_block:
  st:state ->
  m:uint8_p{length m = 16} ->
  Stack unit
    (requires (fun h -> stable h st /\ live h m))
    (ensures  (fun h0 updated_log h1 -> modifies_1 (get_accumulator st) h0 h1 /\ stable h1 st))
let update_block st m =
  let _ = I.poly1305_update empty_log st m in ()


#reset-options "--initial_fuel 0 --max_fuel 0 --z3rlimit 100"

val update:
  st:state ->
  m:uint8_p ->
  len:FStar.UInt32.t{length m >= 16 * UInt32.v len} ->
  Stack unit
    (requires (fun h -> stable h st /\ live h m))
    (ensures  (fun h0 updated_log h1 -> modifies_1 (get_accumulator st) h0 h1 /\ stable h1 st))
let rec update st m len =
  if FStar.UInt32.(len =^ 0ul) then ()
  else
    let block = Buffer.sub m 0ul 16ul in
    let m'    = Buffer.offset m 16ul  in
    let len   = FStar.UInt32.(len -^ 1ul) in
    let _ = update_block st block in
    update st m' len

  
#reset-options "--initial_fuel 0 --max_fuel 0 --z3rlimit 10"

module A = Hacl.Spec.Bignum.AddAndMultiply

type before_finish h st = A.(live_state h st /\ bounds (as_seq h (get_accumulator st)) p44 p44 p42)


#reset-options "--initial_fuel 0 --max_fuel 0 --z3rlimit 100"

val update_last:
  st:state ->
  m:uint8_p ->
  len:UInt32.t{UInt32.v len < 16 /\ UInt32.v len <= length m} ->
  Stack unit
    (requires (fun h -> stable h st /\ live h m))
    (ensures  (fun h0 _ h1 -> modifies_1 (get_accumulator st) h0 h1 /\ before_finish h1 st))
let update_last st m len =
  I.poly1305_update_last empty_log st (Buffer.sub m 0ul len) (Int.Cast.uint32_to_uint64 len)


val finish:
  st:state ->
  mac:uint8_p{length mac = 16} ->
  k:uint8_p{length k = 16} ->
  Stack unit
    (requires (fun h -> before_finish h st /\ live h mac /\ live h k))
    (ensures (fun h0 _ h1 -> modifies_1 mac h0 h1))
let finish st mac k =
  I.poly1305_finish st mac k


val crypto_onetimeauth:
  output:uint8_p{length output = 16} ->
  input:uint8_p{disjoint input output} ->
  len:U64.t{U64.v len < pow2 32 /\ U64.v len = length input} ->
  k:uint8_p{disjoint output k /\ length k = 32} ->
  Stack unit
    (requires (fun h -> live h output /\ live h input /\ live h k))
    (ensures  (fun h0 _ h1 -> live h1 output /\ modifies_1 output h0 h1 /\ live h0 input /\ live h0 k
      /\ (let mac     = Hacl.Spec.Endianness.reveal_sbytes (as_seq h1 output) in
         let message = Hacl.Spec.Endianness.reveal_sbytes (as_seq h0 input) in
         let key     = Hacl.Spec.Endianness.reveal_sbytes (as_seq h0 k) in
         mac == Spec.Poly1305.poly1305 message key)))
let crypto_onetimeauth output input len k = Hacl.Standalone.Poly1305_64.crypto_onetimeauth output input len k


open Spec.Chacha20Poly1305
open Hacl.Spec.Endianness

#reset-options "--initial_fuel 0 --max_fuel 0 --z3rlimit 100"

val pad_16_bytes:
  input:uint8_p ->
  len:U32.t{length input = U32.v len /\ U32.v len < 16 /\ U32.v len > 0} ->
  StackInline (uint8_p)
    (requires (fun h -> live h input))
    (ensures (fun h0 output h1 -> live h0 input /\ live h1 output /\ frameOf output = h1.tip
      /\ modifies_0 h0 h1 /\ length output = 16
      /\ (let o = reveal_sbytes (as_seq h1 output) in let i = reveal_sbytes (as_seq h0 input) in
         o == Spec.Chacha20Poly1305.pad_16 i)))
let pad_16_bytes input len =
  let h0 = ST.get() in
  let b = Buffer.create (uint8_to_sint8 0uy) 16ul in
  Buffer.blit input 0ul b 0ul len;
  let h = ST.get() in
  no_upd_lemma_0 h0 h input;
  Seq.lemma_eq_intro (as_seq h input) (Seq.slice (as_seq h input) 0 (U32.v len));
  Seq.lemma_eq_intro (Seq.slice (as_seq h b) (U32.v len) 16) (Seq.create (16 - U32.v len) (uint8_to_sint8 0uy));
  Seq.lemma_eq_intro (reveal_sbytes (as_seq h b)) (Spec.Chacha20Poly1305.pad_16 (reveal_sbytes (as_seq h0 input)));
  b


private let lemma_div (x:nat) : Lemma (16 * (x / 16) <= x /\ 16 * (x / 16) >= 0) =
  Math.Lemmas.lemma_div_mod x 16

inline_for_extraction
let mul_div_16 (len:U32.t) : Tot (len':U32.t{U32.v len' = 16 * (U32.v len / 16)}) =
  lemma_div (U32.v len); Math.Lemmas.lemma_div_mod (U32.v len) 16;
  assert_norm(pow2 4 = 16);
  U32.(16ul *^ (len >>^ 4ul))

#reset-options "--initial_fuel 0 -max_fuel 0 --z3rlimit 100"

private let lemma_pad_last_modifies (h:mem) (acc:buffer Hacl.UInt64.t) : Lemma
  (modifies_1 acc h h) = lemma_intro_modifies_1 acc h h


private val pad_16_block: x:word{Seq.length x < 16 /\ Seq.length x > 0} -> Tot (lbytes 16)
let pad_16_block x = Spec.Chacha20Poly1305.pad_16 x


private val pad_last_spec:
  st:S.poly1305_state_{Hacl.Spe.Poly1305_64.invariant st} ->
  m:word{Seq.length m < 16 /\ Seq.length m > 0} ->
  GTot (st':S.poly1305_state_{Hacl.Spe.Poly1305_64.invariant st'
    /\ (let log  = S.MkState?.log st  in
       let log' = S.MkState?.log st'  in
       let m    = pad_16_block m in log' == Seq.cons m log)})
#reset-options "--initial_fuel 0 -max_fuel 0 --z3rlimit 5"
let pad_last_spec st m =
  let acc = S.MkState?.h st in
  let r   = S.MkState?.r st in
  let log = S.MkState?.log st in
  let m_16 = pad_16_block m in
  let st' = Hacl.Spe.Poly1305_64.poly1305_update_spec st (intro_sbytes (m_16)) in
  let acc' = S.MkState?.h st' in
  let r' = S.MkState?.r st' in
  let log' = S.MkState?.log st' in
  cut (log' == Seq.cons (m_16) log);
  Math.Lemmas.modulo_lemma (Hacl.Spec.Bignum.Bigint.seval r) (pow2 130 - 5);
  assert_norm (pow2 128 + pow2 128 < pow2 130 - 5); lemma_little_endian_is_bounded m_16;
  let b : Spec.Poly1305.elem = little_endian m_16 + pow2 128 in
  let b' = Spec.Poly1305.encode m_16 in
  Math.Lemmas.modulo_lemma b (pow2 130 - 5);
  cut (S.selem r = S.selem r');
  cut (S.selem acc' = Spec.Poly1305.((S.selem acc +@ b) *@ S.selem r));
  cut (S.selem acc' = Spec.Poly1305.((S.selem acc +@ encode m_16) *@ S.selem r));
  Hacl.Spe.Poly1305_64.lemma_poly1305_blocks_spec_1 (intro_sbytes m_16) log log' (S.selem acc) (Hacl.Spec.Bignum.Bigint.seval r) (S.selem acc');
  st'



val pad_last:
  log:I.log_t ->
  st:I.poly1305_state ->
  input:uint8_p{disjoint I.(st.h) input} ->
  len:U32.t{U32.v len = length input /\ U32.v len < 16} ->
  Stack I.log_t
    (requires (fun h -> I.live_st h st /\ live h input
      /\ (let r = as_seq h I.(st.r) in
         let acc = as_seq h I.(st.h) in
         let log = reveal log in
         Hacl.Spe.Poly1305_64.invariant (Hacl.Spec.Poly1305_64.MkState r acc log))
    ))
    (ensures (fun h0 updated_log h1 -> I.live_st h0 st /\ I.live_st h1 st /\ live h0 input
      /\ modifies_1 I.(st.h) h0 h1
      /\ (let r = as_seq h0 I.(st.r) in
         let acc = as_seq h0 I.(st.h) in
         let log = reveal log in
         let acc' = as_seq h1 I.(st.h) in
         let log' = reveal updated_log in
         let m    = reveal_sbytes (as_seq h0 input) in
         Hacl.Spe.Poly1305_64.invariant (Hacl.Spec.Poly1305_64.MkState r acc log)
         /\ Hacl.Spe.Poly1305_64.invariant (Hacl.Spec.Poly1305_64.MkState r acc' log')
         /\ (if U32.v len = 0 then log' == log
           else (let m = pad_16 m in Seq.length m = 16 /\ log' == Seq.cons m log)))
    ))
#reset-options "--initial_fuel 0 -max_fuel 0 --initial_ifuel 0 --max_ifuel 0 --z3rlimit 400"
let pad_last log st input len =
  push_frame();
  cut (U32.v len >= 0 /\ U32.v len < 16);
  let l =
  if U32.(len =^ 0ul) then (
    let h0 = ST.get() in
    lemma_pad_last_modifies h0 I.(st.h);
    log
  ) else (
    cut (U32.v len <> 0);
    cut (U32.v len < 16);
    cut (U32.v len > 0 /\ U32.v len < 16);
    let h0 = ST.get() in
    let b = pad_16_bytes input len in
    let h = ST.get() in
    Seq.lemma_eq_intro (as_seq h b) (Seq.slice (as_seq h b) 0 16);
    Hacl.Standalone.Poly1305_64.lemma_poly1305_blocks_spec_1 (S.MkState (as_seq h0 I.(st.r)) (as_seq h0 I.(st.h)) (reveal log)) (as_seq h b) 1uL;
    let l = I.poly1305_update log st b in
    let h1 = ST.get() in
    l
  ) in
  pop_frame();
  l


#reset-options "--initial_fuel 0 -max_fuel 0 --z3rlimit 5"


private val lemma_pad_16_:
  s:Seq.seq U8.t{Seq.length s % 16 = 0} ->
  Lemma (Spec.Poly1305.encode_bytes (pad_16 s) == Spec.Poly1305.encode_bytes s)
let lemma_pad_16_ s = ()


private val lemma_pad_16:
  h:mem ->
  b:uint8_p{live h b} ->
  len_16:U32.t{U32.v len_16 = 16 * (length b / 16)} ->
  rem_16:U32.t{U32.v rem_16 = length b % 16} ->
  Lemma (
    U32.v len_16 <= length b /\ U32.v rem_16 + U32.v len_16 = length b /\
    (let x = reveal_sbytes (as_seq h (Buffer.sub b 0ul len_16)) in
     let y = reveal_sbytes (as_seq h (Buffer.sub b len_16 rem_16)) in
     let b = reveal_sbytes (as_seq h b) in
     if U32.v rem_16 = 0 then Spec.Poly1305.encode_bytes (pad_16 b) == Spec.Poly1305.encode_bytes x
     else (Seq.length (pad_16 y) = 16
           /\ Spec.Poly1305.encode_bytes (pad_16 b) == Seq.cons (pad_16 y) (Spec.Poly1305.encode_bytes x))))
#reset-options "--initial_fuel 0 -max_fuel 0 --z3rlimit 100"
let lemma_pad_16 h b len_16 rem_16 =
  Math.Lemmas.lemma_div_mod (length b) 16;
  Seq.lemma_eq_intro (Seq.slice (as_seq h b) 0 (U32.v len_16)) (as_seq h (Buffer.sub b 0ul len_16));
  Seq.lemma_eq_intro (Seq.slice (as_seq h b) (U32.v len_16) (length b)) (as_seq h (Buffer.sub b len_16 rem_16));
  Hacl.Spec.Poly1305_64.Lemmas1.lemma_pad_16 (reveal_sbytes (as_seq h b)) (U32.v len_16) (U32.v rem_16)


#reset-options "--initial_fuel 0 -max_fuel 0 --z3rlimit 200"

val poly1305_blocks_init:
  st:I.poly1305_state ->
  input:uint8_p{disjoint I.(st.r) input /\ disjoint I.(st.h) input} ->
  len:U32.t{U32.v len = length input} ->
  k:uint8_p{length k = 32 /\ disjoint k I.(st.r) /\ disjoint k I.(st.h)} ->
  Stack I.log_t
    (requires (fun h -> I.live_st h st /\ live h input /\ live h k))
    (ensures (fun h0 log h1 -> I.live_st h1 st /\ live h0 input /\ live h0 k
      /\ modifies_2 I.(st.r) I.(st.h) h0 h1
      /\ (let r   = as_seq h1 I.(st.r) in
         let acc = as_seq h1 I.(st.h) in
         let log = reveal log in
         let m   = reveal_sbytes (as_seq h0 input) in
         let kr  = reveal_sbytes (as_seq h0 (Buffer.sub k 0ul 16ul)) in
         Hacl.Spe.Poly1305_64.invariant (Hacl.Spec.Poly1305_64.MkState r acc log)
         /\ S.seval r = Spec.Poly1305.encode_r kr
         /\ log == Spec.Poly1305.encode_bytes (pad_16 m))
    ))
#reset-options "--initial_fuel 0 -max_fuel 0 --z3rlimit 200"
let poly1305_blocks_init st input len k =
  let len_16 = U32.(len >>^ 4ul) in
  let rem_16 = U32.(len &^ 15ul)  in
  assert_norm(pow2 4 = 16);
  UInt.logand_mask (U32.v len) 4;
  Math.Lemmas.lemma_div_mod (U32.v len) 16;
  lemma_div (U32.v len);
  let kr = Buffer.sub k 0ul 16ul in
  let len' = mul_div_16 len in
  let part_input = Buffer.sub input 0ul len' in
  let last_block = Buffer.offset input len' in
  cut (length last_block = U32.v rem_16);
  let h0 = ST.get() in
  let l = Poly.poly1305_partial st part_input (Int.Cast.uint32_to_uint64 len_16) kr in
  let h1 = ST.get() in
  let l' = pad_last l st last_block rem_16 in
  let h2 = ST.get() in
  lemma_pad_16 h0 input len' rem_16;
  l'


#reset-options "--initial_fuel 0 --max_fuel 0 --z3rlimit 500"

val poly1305_blocks_continue:
  log:I.log_t ->
  st:I.poly1305_state ->
  input:uint8_p{disjoint I.(st.h) input} ->
  len:U32.t{U32.v len = length input} ->
  Stack I.log_t
    (requires (fun h -> I.live_st h st /\ live h input
      /\ (let r = as_seq h I.(st.r) in
         let acc = as_seq h I.(st.h) in
         let log = reveal log in
         Hacl.Spe.Poly1305_64.invariant (Hacl.Spec.Poly1305_64.MkState r acc log))
    ))
    (ensures (fun h0 log' h1 -> I.live_st h0 st /\ I.live_st h1 st /\ live h0 input
      /\ modifies_1 I.(st.h) h0 h1
      /\ (let r = as_seq h0 I.(st.r) in
         let acc = as_seq h0 I.(st.h) in
         let log = reveal log in
         let acc' = as_seq h1 I.(st.h) in
         let log' = reveal log' in
         let m    = reveal_sbytes (as_seq h0 input) in
         Hacl.Spe.Poly1305_64.invariant (Hacl.Spec.Poly1305_64.MkState r acc log)
         /\ Hacl.Spe.Poly1305_64.invariant (Hacl.Spec.Poly1305_64.MkState r acc' log')
         /\ log' == Seq.append (Spec.Poly1305.encode_bytes (pad_16 m)) log)
    ))
#reset-options "--initial_fuel 0 --max_fuel 0 --z3rlimit 1000"
let poly1305_blocks_continue log st input len =
  let len_16 = U32.(len >>^ 4ul) in
  let rem_16 = U32.(len &^ 15ul)  in
  assert_norm(pow2 4 = 16);
  UInt.logand_mask (U32.v len) 4;
  Math.Lemmas.lemma_div_mod (U32.v len) 16;
  lemma_div (U32.v len);
  let len' = mul_div_16 len in
  let part_input = Buffer.sub input 0ul len' in
  let last_block = Buffer.offset input len' in
  let h0 = ST.get() in
  let l = Hacl.Standalone.Poly1305_64.poly1305_blocks log st part_input (Int.Cast.uint32_to_uint64 len_16) in
  let h1 = ST.get() in
  let l' = pad_last l st last_block rem_16 in
  let h2 = ST.get() in
  lemma_pad_16 h0 input len' rem_16;
  Seq.lemma_eq_intro (Seq.append (Spec.Poly1305.encode_bytes (pad_16 (reveal_sbytes (as_seq h0 input))))
                                 (reveal log))
                     (reveal l');
  l'


#reset-options "--initial_fuel 0 --max_fuel 0 --z3rlimit 50"

[@ "substitute"]
val poly1305_blocks_finish_:
  log:I.log_t ->
  st:I.poly1305_state ->
  input:uint8_p{disjoint I.(st.h) input /\ length input = 16} ->
  Stack I.log_t
    (requires (fun h -> I.live_st h st /\ live h input
      /\ (let r = as_seq h I.(st.r) in
         let acc = as_seq h I.(st.h) in
         let log = reveal log in
         Hacl.Spe.Poly1305_64.invariant (Hacl.Spec.Poly1305_64.MkState r acc log))
    ))
    (ensures (fun h0 log' h1 -> I.live_st h0 st /\ live h0 input /\ modifies_1 I.(st.h) h0 h1
      /\ I.live_st h1 st
      /\ (let r    = as_seq h0 I.(st.r) in
         let acc  = as_seq h0 I.(st.h) in
         let acc' = as_seq h1 I.(st.h) in
         let log  = reveal log         in
         let log' = reveal log'        in
         let m    = reveal_sbytes (as_seq h0 input)    in
         Hacl.Spe.Poly1305_64.invariant (Hacl.Spec.Poly1305_64.MkState r acc log)
         /\ Hacl.Spe.Poly1305_64.invariant (Hacl.Spec.Poly1305_64.MkState r acc' log')
         /\ log' == Seq.cons m log
         /\ Hacl.Spec.Bignum.Bigint.seval acc' < pow2 130 - 5
         /\ Hacl.Spec.Bignum.AddAndMultiply.bounds acc' S.p44 S.p44 S.p42)
    ))
#reset-options "--initial_fuel 0 --max_fuel 0 --z3rlimit 1000"
[@ "substitute"]
let poly1305_blocks_finish_ log st input =
  let h = ST.get() in
  Seq.lemma_eq_intro (as_seq h input) (Seq.slice (as_seq h input) 0 16);
  Math.Lemmas.modulo_lemma (Hacl.Spec.Bignum.Bigint.seval (as_seq h I.(st.r))) (pow2 130 - 5);
  Hacl.Standalone.Poly1305_64.lemma_poly1305_blocks_spec_1 (S.MkState (as_seq h I.(st.r)) (as_seq h I.(st.h)) (reveal log)) (as_seq h input) 1uL;
  let log' = I.poly1305_update log st input in
  Hacl.Spe.Poly1305_64.poly_def_1 (reveal log') (Hacl.Spec.Bignum.Bigint.seval (as_seq h I.(st.r)));
  cut (reveal log' == Seq.cons (reveal_sbytes (as_seq h input)) (reveal log));
  I.poly1305_update_last log' st (Buffer.offset input 16ul) 0uL;
  log'


#reset-options "--initial_fuel 0 --max_fuel 0 --z3rlimit 50"

val poly1305_blocks_finish:
  log:I.log_t ->
  st:I.poly1305_state ->
  input:uint8_p{disjoint I.(st.h) input /\ length input = 16} ->
  mac:uint8_p{disjoint I.(st.h) mac /\ disjoint mac input /\ length mac = 16} ->
  key_s:uint8_p{disjoint key_s I.(st.h) /\ disjoint key_s mac /\ length key_s = 16} ->
  Stack unit
    (requires (fun h -> I.live_st h st /\ live h input /\ live h mac /\ live h key_s
      /\ (let r = as_seq h I.(st.r) in
         let acc = as_seq h I.(st.h) in
         let log = reveal log in
         Hacl.Spe.Poly1305_64.invariant (Hacl.Spec.Poly1305_64.MkState r acc log))
    ))
    (ensures (fun h0 _ h1 -> I.live_st h0 st /\ live h0 key_s /\ live h0 input
      /\ modifies_2 mac I.(st.h) h0 h1 /\ live h1 mac
      /\ (let mac = as_seq h1 mac in
         let r   = (as_seq h0 I.(st.r)) in
         let acc = as_seq h0 I.(st.h) in
         let log = reveal log in
         let m   = reveal_sbytes (as_seq h0 input) in
         let k   = Hacl.Spec.Endianness.hlittle_endian (as_seq h0 key_s) in
         Hacl.Spe.Poly1305_64.invariant (Hacl.Spec.Poly1305_64.MkState r acc log)
         /\ Hacl.Spec.Endianness.hlittle_endian mac
           == (Spec.Poly1305.poly (Seq.cons m log) (Hacl.Spec.Bignum.Bigint.seval r) + k) % pow2 128)
    ))
#reset-options "--initial_fuel 0 --max_fuel 0 --z3rlimit 100"
let poly1305_blocks_finish log st input mac key_s =
  let h = ST.get() in
  let _ = poly1305_blocks_finish_ log st input in
  let h' = ST.get() in
  Math.Lemmas.modulo_lemma (Hacl.Spec.Bignum.Bigint.seval (as_seq h' I.(st.h))) (pow2 130 - 5);
  cut (Hacl.Spec.Bignum.Bigint.seval (as_seq h' I.(st.h)) = Spec.Poly1305.poly (Seq.cons (reveal_sbytes (as_seq h input)) (reveal log)) (Hacl.Spec.Bignum.Bigint.seval (as_seq h I.(st.r))));
  I.poly1305_finish st mac key_s
