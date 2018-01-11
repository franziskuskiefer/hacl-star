module Spec.Hash

open FStar.Mul
open Spec.Lib.IntTypes
open Spec.Lib.IntSeq

#reset-options "--max_fuel 0 --z3rlimit 25"

type algorithm =
  | SHA2_224
  | SHA2_256
  | SHA2_384
  | SHA2_512

val hash_w: a:algorithm -> Type0
val size_block: a:algorithm -> size_nat
// size_hash enforces some constraints from HMAC and HKDF
val size_hash: a:algorithm -> s:size_nat{0 < s /\ s < size_block a /\ s + size_block a <= max_size_t /\ 255 * s <= max_size_t}

val max_input: a:algorithm -> n:nat{size_hash a + size_block a < n}

val init: a:algorithm -> Tot (hash_w a)
val update_block: a:algorithm -> block:lbytes (size_block a) -> hash:hash_w a -> Tot (hash_w a)
val update_multi: a:algorithm -> n:size_nat{n * (size_block a) <= max_size_t} -> blocks:lbytes (n * (size_block a)) -> hash:hash_w a -> Tot (hash_w a)
val update_last: a:algorithm -> n:size_nat -> len:size_nat{len < size_block a /\ len + n * size_block a <= max_input a} -> last:lbytes len -> hash:hash_w a -> Tot (hash_w a)
val finish: a:algorithm -> hash:hash_w a -> Tot (lbytes (size_hash a))
val hash: a:algorithm -> len:size_nat{len < max_input a} -> input:lbytes len -> Tot (lbytes (size_hash a))

