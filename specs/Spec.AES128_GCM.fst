module Spec.AES128_GCM

open FStar.Mul
open Lib.IntTypes
open Lib.RawIntTypes
open Lib.Sequence
open Lib.ByteSequence
open Lib.LoopCombinators

module AES = Spec.AES
module GF = Spec.GF128

#set-options "--z3rlimit 25 --max_fuel 1"

(* Constants *)
let size_key: size_nat = 16
let size_block: size_nat = 16
let size_nonce: size_nat = 12
let size_tag: size_nat = size_block

(* Types *)
type key = lbytes size_key
type nonce = lbytes size_nonce
type tag = lbytes size_tag


inline_for_extraction
let padlen (x:size_nat) = ((size_block - x % size_block) % size_block)


val ghash:
    text: bytes {length text <= max_size_t /\ length text + padlen (length text) <= max_size_t}
  -> aad: bytes{length aad <= max_size_t /\ length aad + padlen (length aad) <= max_size_t}
  -> gf_key: GF.key
  -> tag_key: GF.key ->
  Tot GF.tag

let ghash text aad gf_key tag_key =
  (* gmul input: A || 0^v || C || 0^u || ceil(len(A))_64 || ceil(len(C))_64 *)
  let alen = length aad in
  let tlen = length text in
  let aad_pad = create (padlen alen) (u8 0) in
  let text_pad = create (padlen tlen) (u8 0) in
  let aad_len_bytes : lseq uint8 8 = nat_to_bytes_be 8 (alen * 8) in
  let text_len_bytes : lseq uint8 8 = nat_to_bytes_be 8 (tlen * 8) in
  let st = GF.init gf_key in
  let st = GF.poly ((to_lseq aad) @| aad_pad) st in
  let st = GF.poly ((to_lseq text) @| text_pad) st in
  let st = GF.poly (aad_len_bytes @| text_len_bytes) st in
  let tag = GF.finish st tag_key in
  tag

val gcm:
    k: AES.aes_key AES.AES128
  -> n: nonce
  -> m: bytes{length m <= max_size_t /\ length m + padlen (length m) <= max_size_t}
  -> aad: bytes {length aad <= max_size_t /\ length aad + padlen (length aad) <= max_size_t} ->
  Tot Spec.GF128.tag


let gcm k n m aad =
  let nlen = length n in
  let tag_key = AES.aes_ctr_key_block1 AES.AES128 k nlen n in
  let gf_key = AES.aes_ctr_key_block0 AES.AES128 k size_nonce (create size_nonce (u8 0)) in
  let mac = ghash m aad gf_key tag_key in
  mac


val aead_encrypt:
    k: key
  -> n: nonce
  -> m: bytes{length m <= max_size_t /\ length m + size_block <= max_size_t /\ length m + padlen (length m) <= max_size_t}
  -> aad: bytes {length aad <= max_size_t /\ length aad + padlen (length aad) <= max_size_t} ->
  Tot (lbytes (length m + size_block))

let aead_encrypt k n m aad =
  let mlen = length m in
  let nonce = create size_nonce (u8 0) in
  let nonce = update_sub nonce 0 size_nonce n in
  let c = AES.aes128_ctr_encrypt_bytes k size_nonce nonce 2 m in
  let mac = gcm k nonce c aad in
  let result = create (mlen + size_block) (u8 0) in
  let result = update_slice result 0 mlen c in
  let result = update_slice result mlen (mlen + size_block) mac in
  result


val aead_decrypt:
    k: key
  -> n: nonce
  -> c: bytes{length c + size_block <= max_size_t}
  -> mac: tag
  -> aad: bytes{length aad <= max_size_t /\ length aad + padlen (length aad) <= max_size_t} ->
  Tot (option (lbytes (length c)))

let aead_decrypt k n c tag aad =
  let clen = length c in
  let nonce = create size_nonce (u8 0) in
  let nonce = update_sub nonce 0 size_nonce n in
  let computed_tag = gcm k nonce c aad in
  if lbytes_eq computed_tag tag then
    Some (AES.aes128_ctr_encrypt_bytes k size_nonce nonce 2 c)
  else None
