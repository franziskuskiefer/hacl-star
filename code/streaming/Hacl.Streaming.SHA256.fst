module Hacl.Streaming.SHA256

open FStar.HyperStack.ST
open FStar.Integers

/// A streaming version of SHA256.

#set-options "--max_fuel 0 --max_ifuel 0 --z3rlimit 100"

module HS = FStar.HyperStack
module B = LowStar.Buffer
module G = FStar.Ghost
module S = FStar.Seq
module U32 = FStar.UInt32
module U64 = FStar.UInt64
module F = Hacl.Streaming.Functor

open LowStar.BufferOps
open FStar.Mul

inline_for_extraction noextract
let uint8 = Lib.IntTypes.uint8

inline_for_extraction noextract
let uint32 = Lib.IntTypes.uint32

open Spec.Hash.Definitions

/// Maximum input length, but fitting on a 64-bit integer (since the streaming
/// module doesn't bother taking into account lengths that are greater than
/// that).
inline_for_extraction noextract
let max_input_length64 a: x:nat { 0 < x /\ x < pow2 64 /\ x <= max_input_length a } =
  let _ = allow_inversion hash_alg in
  match a with
  | MD5 | SHA1
  | SHA2_224 | SHA2_256 -> assert_norm (0 < pow2 61 - 1 && pow2 61 < pow2 64); pow2 61 - 1
  | SHA2_384 | SHA2_512 -> assert_norm (pow2 64 < pow2 125 - 1); pow2 64 - 1

let t = s:B.buffer uint32 { B.length s == state_word_length SHA2_256 }

let concat_blocks_modulo (block_len: pos) (s1 s2: S.seq uint8): Lemma
  (requires
    S.length s1 % block_len = 0 /\
    S.length s2 % block_len = 0)
  (ensures
    S.length (S.append s1 s2) % block_len = 0)
=
  let input = S.append s1 s2 in
  let input1 = s1 in
  let input2 = s2 in
  calc (==) {
    S.length input % block_len;
  (==) { S.lemma_len_append input1 input2 }
    (S.length input1 + S.length input2) % block_len;
  (==) {
    FStar.Math.Lemmas.modulo_distributivity (S.length input1) (S.length input2) (block_len)
  }
    (S.length input1 % block_len + S.length input2 % block_len) % block_len;
  (==) { (* hyp *) }
    0 % block_len;
  (==) { }
    0;
  }

// Local redefinition to have the shape desired by the type class.
let update_multi_associative (i: hash_alg) (s: words_state i) (input1 input2: S.seq uint8):
  Lemma
  (requires (
    S.length input1 % (block_length i) = 0 /\
    S.length input2 % (block_length i) = 0))
  (ensures (
    let input = S.append input1 input2 in
    S.length input % (block_length i) = 0 /\
    Spec.Agile.Hash.(update_multi i (update_multi i s input1) input2 ==
      update_multi i s input)))
  [ SMTPat Spec.Agile.Hash.(update_multi i (update_multi i s input1) input2) ]
=
  concat_blocks_modulo (block_length i) input1 input2;
  Spec.Hash.Lemmas.update_multi_associative' i s input1 input2

inline_for_extraction noextract
let hacl_sha2_256: Hacl.Streaming.Interface.block unit =
  Hacl.Streaming.Interface.Block
    (fun _ -> t)
    (fun #_ h s -> B.loc_addr_of_buffer s)
    (fun #_ h s -> B.freeable s)
    (fun #_ h s -> B.live h s)
    (fun _ _ -> ())
    (fun _ -> words_state SHA2_256)
    (fun #_ h s -> B.as_seq h s)
    (fun () -> max_input_length64 SHA2_256)
    (fun () -> Hacl.Hash.Definitions.hash_len SHA2_256)
    (fun () -> Hacl.Hash.Definitions.block_len SHA2_256)
    (fun () -> Spec.Agile.Hash.(init SHA2_256))
    (fun () -> Spec.Agile.Hash.(update_multi SHA2_256))
    (fun () -> Spec.Hash.Incremental.(update_last SHA2_256))
    (fun () -> Spec.Hash.PadFinish.(finish SHA2_256))
    (fun () s -> Spec.Agile.Hash.(hash SHA2_256 s))
    (fun _ _ -> ())
    (fun _ _ _ _ -> ())
    (fun _ input -> Spec.Hash.Lemmas.hash_is_hash_incremental SHA2_256 input)
    (fun #_ h s -> ())
    (fun #_ l s h0 h1 -> ())
    (fun #_ l s h0 h1 -> ())
    (fun () -> B.alloca (Lib.IntTypes.u32 0) 8ul)
    (fun () r -> B.malloc r (Lib.IntTypes.u32 0) 8ul)
    (fun _ s -> Hacl.Hash.SHA2.init_256 s)
    (fun _ s blocks len -> Hacl.Hash.SHA2.update_multi_256 s blocks (len `U32.div` Hacl.Hash.Definitions.(block_len SHA2_256)))
    (fun _ s last total_len ->
      [@inline_let]
      let block_len64 = 64UL in
      assert_norm (U64.v block_len64 == block_length SHA2_256);
      let last_len: len_t SHA2_256 = U64.(total_len `rem` block_len64) in
      let prev_len = U64.(total_len `sub` last_len) in
      let last_len = FStar.Int.Cast.Full.uint64_to_uint32 last_len in
      assert (U64.v prev_len % block_length SHA2_256 = 0);
      Hacl.Hash.SHA2.update_last_256 s prev_len last last_len)
    (fun _ s dst -> Hacl.Hash.SHA2.finish_256 s dst)
    (fun _ s -> B.free s)
    (fun _ src dst -> B.blit src 0ul dst 0ul 8ul)

/// An instantiation of the streaming functor for a specialized hash algorithm.
///
/// Some remarks:
///
/// - rather than copy/pasting the type class above, we could make it generic
///   over the hash algorithm, but still get specialized instances
/// - we don't bother with using the abstraction feature since we verified
///   clients like miTLS go through EverCrypt.Hash.Incremental

let create_in = F.create_in hacl_sha2_256 () t
let init = F.init hacl_sha2_256 (G.hide ()) t
let update = F.update hacl_sha2_256 (G.hide ()) t
let finish = F.mk_finish hacl_sha2_256 () t
let free = F.free hacl_sha2_256 (G.hide ()) t
