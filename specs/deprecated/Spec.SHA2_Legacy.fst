module Spec.SHA2_Legacy

open FStar.Mul
open Lib.IntTypes
open Lib.Sequence
open Lib.ByteSequence
open Lib.LoopCombinators
#set-options "--z3rlimit  25"

(* Definition: Hash algorithm parameters *)
noeq type parameters =
  | MkParameters:
    wt:       inttype{wt = U32 \/ wt = U64} ->
	 opTable:  lseq (rotval wt) 12 ->
	 kSize:    size_nat{kSize > 16} ->
	 kTable:   lseq (uint_t wt SEC) kSize ->
	 h0:       lseq (uint_t wt SEC) 8 ->
	 size_hash: nat {0 < size_hash /\ size_hash <= 8 * numbytes wt} ->
	 parameters

(* Definition: Type for the total length encoded in the padding *)
let lenType p = match p.wt with
| U32 -> U64
| U64 -> U128

(* Definition: Number of bytes required to store the total length *)
let lenSize p = numbytes (lenType p)

(* Definition: Algorithm constants *)
let size_block_w = 16
let size_hash_w = 8
let size_block p :size_nat = size_block_w * numbytes p.wt
let size_hash p :size_nat = p.size_hash

(* Definition: Maximum input size in bytes *)
let max_input p : n:nat = (maxint (lenType p) + 1) / 8

(* Definition: Types for block and hash as sequences of words *)
type block_w p = lseq (uint_t p.wt SEC) 16
type hash_w p = lseq (uint_t p.wt SEC) size_hash_w
type ws_w p = lseq (uint_t p.wt SEC) p.kSize

(* Definition of permutation functions *)
let _Ch p (x:uint_t p.wt SEC) (y:uint_t p.wt SEC) (z:uint_t p.wt SEC) : uint_t p.wt SEC = ((x &. y) ^. ((~. x) &. z))
let _Maj p (x:uint_t p.wt SEC) (y:uint_t p.wt SEC) (z:uint_t p.wt SEC) = (x &. y) ^. ((x &. z) ^. (y &. z))
let _Sigma0 p (x:uint_t p.wt SEC) = (x >>>. p.opTable.[0]) ^. ((x >>>. p.opTable.[1]) ^. (x >>>. p.opTable.[2]))
let _Sigma1 p (x:uint_t p.wt SEC) = (x >>>. p.opTable.[3]) ^. ((x >>>. p.opTable.[4]) ^. (x >>>. p.opTable.[5]))
let _sigma0 p (x:uint_t p.wt SEC) = (x >>>. p.opTable.[6]) ^. ((x >>>. p.opTable.[7]) ^. (x >>. p.opTable.[8]))
let _sigma1 p (x:uint_t p.wt SEC) = (x >>>. p.opTable.[9]) ^. ((x >>>. p.opTable.[10]) ^. (x >>. p.opTable.[11]))

(* Definition of the scheduling function (part 1) *)
let step_ws0 (p:parameters) (b:block_w p) (i:size_nat{i < 16}) (s:ws_w p) : Tot (ws_w p) =
  s.[i] <- b.[i]

(* Definition of the scheduling function (part 2) *)
let step_ws1 (p:parameters) (i:size_nat{i >= 16 /\ i < p.kSize}) (s:ws_w p) : Tot (ws_w p) =
  let t16 = s.[i - 16] in
  let t15 = s.[i - 15] in
  let t7  = s.[i - 7] in
  let t2  = s.[i - 2] in
  let s1 = _sigma1 p t2 in
  let s0 = _sigma0 p t15 in
  s.[i] <- s1 +. (t7 +. (s0 +. t16))

(* Definition of the loop over the scheduling function (part 1) *)
let loop_ws0 p b s = repeati 16 (step_ws0 p b) s

(* Definition of the loop over the scheduling function (part 2) *)
let loop_ws1 p s = repeati (p.kSize - 16) (fun i -> step_ws1 p (i + 16)) s

(* Definition of the core scheduling function *)
let ws (p:parameters) (b:block_w p) : Tot (ws_w p) =
  let s = create p.kSize (nat_to_uint #p.wt #SEC 0) in
  let s = loop_ws0 p b s in
  let s = loop_ws1 p s in
  s

(* Definition of the core shuffling function *)
let shuffle_core (p:parameters) (wsTable:ws_w p) (t:size_nat{t < p.kSize}) (hash:hash_w p) : Tot (hash_w p) =
  let a0 = hash.[0] in
  let b0 = hash.[1] in
  let c0 = hash.[2] in
  let d0 = hash.[3] in
  let e0 = hash.[4] in
  let f0 = hash.[5] in
  let g0 = hash.[6] in
  let h0 = hash.[7] in

  let t1 = h0 +. (_Sigma1 p e0) +. ((_Ch p e0 f0 g0) +. (p.kTable.[t] +. wsTable.[t])) in
  let t2 = (_Sigma0 p a0) +. (_Maj p a0 b0 c0) in

  let hash = hash.[0] <- (t1 +. t2) in
  let hash = hash.[1] <- a0 in
  let hash = hash.[2] <- b0 in
  let hash = hash.[3] <- c0 in
  let hash = hash.[4] <- (d0 +. t1) in
  let hash = hash.[5] <- e0 in
  let hash = hash.[6] <- f0 in
  let hash = hash.[7] <- g0 in
  hash

(* Definition of the full shuffling function *)
let shuffle (p:parameters) (wsTable:ws_w p) (hash:hash_w p) : Tot (hash_w p) =
  repeati p.kSize (shuffle_core p wsTable) hash

(* Definition of the core compression function *)
let compress (p:parameters) (block:block_w p) (hash0:hash_w p) : Tot (hash_w p) =
  let wsTable: ws_w p = ws p block in
  let hash1: hash_w p = shuffle p wsTable hash0 in
  map2 (fun x y -> x +. y) hash0 hash1

(* Definition of the truncation function *)
let truncate (p:parameters) (hash:hash_w p) : lbytes (size_hash p) =
  let hash_final = uints_to_bytes_be hash in
  let h = slice hash_final 0 p.size_hash in
  h

(* Definition of the function returning the number of padding blocks for a single input block *)
let number_blocks_padding_single (p:parameters) (len:size_nat{len < size_block p}) : size_nat =
  if len < size_block p - numbytes (lenType p) then 1 else 2

(* Definition of the function returning the number of padding blocks *)
let number_blocks_padding (p:parameters) (len:size_nat{len < max_input p}) : size_nat =
  let n = len / size_block p in
  let r = len % size_block p in
  let nr = number_blocks_padding_single p r in
  n + nr

(* Definition of the padding function for a single input block *)
let pad_single
  (p:parameters)
  (n:size_nat)
  (len:size_nat{len < size_block p /\ len + n * size_block p <= max_input p})
  (last:lbytes len) :
  Tot (block:lbytes (size_block p * number_blocks_padding_single p len)) =

  let nr = number_blocks_padding_single p len in
  let plen : size_nat = nr * size_block p in
  // Create the padding and copy the partial block inside
  let padding : lbytes plen = create plen (u8 0) in
  let padding = repeati #(lbytes plen) len (fun i s -> s.[i] <- last.[i]) padding in
  // Write the 0x80 byte and the zeros in the padding
  let padding = padding.[len] <- u8 0x80 in
  // Encode and write the total length in bits at the end of the padding
  let tlen = n * size_block p + len in
  let tlenbits = tlen * 8 in
  let x = nat_to_uint #(lenType p) #SEC tlenbits in
  let encodedlen = uint_to_bytes_be x in
  let padding = update_slice padding (plen - numbytes (lenType p)) plen encodedlen in
  padding

(* Definition of the padding function *)
let pad
  (p:parameters)
  (n:size_nat)
  (len:size_nat{len < max_input p
               /\ (size_block p * number_blocks_padding p len) <= max_size_t
               /\ n + (len / size_block p) <= max_size_t})
  (last:lbytes len) :
  Tot (block:lbytes (size_block p * number_blocks_padding p len)) =

  let nb = len / size_block p in
  let nr = len % size_block p in
  let plen : size_nat = size_block p * number_blocks_padding p len in
  // Separate the full blocks from the remainder of the data
  // then apply the padding function to the remainder
  let pos_fb = nb * size_block p in
  let rem = slice last pos_fb len in
  let rem_blocks = pad_single p (n + nb) nr rem in
  // Creating the padding and write the last data in the padding
  let padding : lbytes plen = create plen  (u8 0) in
  let padding = update_slice padding 0 pos_fb (slice last 0 pos_fb) in
  let padding = update_slice padding pos_fb plen rem_blocks in
  padding

(* Definition of the SHA2 state *)
let len_block_nat (p:parameters) = l:size_nat{l < size_block p}
noeq type state (p:parameters) =
  {
    hash:lseq (uint_t p.wt SEC) size_hash_w;
    blocks:lbytes (2 * size_block p);
    len_block:len_block_nat p;
    n:size_nat;
  }

(* Ghost function to access the abstract state from the interface *)
let get_st_n #p (st:state p) = st.n
let get_st_len_block #p (st:state p) = st.len_block

(* Definition of the initialization function for convenience *)
let init (p:parameters) : Tot (state p) =
  {hash = p.h0; blocks = create (2 * size_block p) (u8 0); len_block = 0; n = 0}

(* Definition of the single block update function *)
let update_block (p:parameters) (block:lbytes (size_block p)) (st:state p{(st.n + 1) * (size_block p) <= max_input p /\ st.n + 1 <= max_size_t}) : Tot (st1:state p)(*{st1.n = st.n + 1 /\ st1.len_block = st.len_block})*) =
  let bw = uints_from_bytes_be block in
    {st with n = st.n + 1; hash = compress p bw st.hash }

(* Definition of the compression function iterated over multiple blocks *)
let update_multi (p:parameters) (n:size_nat{n * size_block p <= max_size_t}) (blocks:lbytes (n * size_block p)) (st:state p{st.n + n <= max_size_t}) : Tot (st1:state p)(* {st1.n = st.n + n})*) =
  let bl = size_block p in
  let h =
    repeati #(hash_w p) n (fun i h ->
      let block = sub blocks (i * bl) bl in
      let bw = uints_from_bytes_be block in
      compress p bw h
    ) st.hash in
  {st with n = st.n + n; hash = h}

(* Definition of the function for the partial block compression *)
let update_last (p:parameters) (len:size_nat) (last:lbytes len) (st:state p{len < size_block p /\ (st.n * size_block p) + len <= max_size_t})
: Tot (state p) =
  let blocks = pad_single p st.n len last in
  update_multi p (number_blocks_padding_single p len) blocks st

(* Definition of the finalization function *)
let finish p (st:state p) : lbytes (size_hash p) =
  truncate p st.hash

(* Definition of the core compression function *)
let update' (p:parameters) (len:size_nat) (input:lbytes len) (st:state p{let n = len / size_block p in st.n + n + 1 <= max_size_t}) : Tot (state p) =
  if st.len_block + len < size_block p then begin
    let pblock = update_sub st.blocks st.len_block len input in
    {st with blocks = pblock; len_block = st.len_block + len} end
  else begin
    let prev_n = st.n in
    // Fill the first part of the partial block and run update
    let l1 = size_block p - st.len_block in
    let rem1 = sub input 0 l1 in
    let block = sub st.blocks 0 (size_block p) in
    let block = update_sub block st.len_block l1 rem1 in
    let st = update_block p block st in
    let st = {st with n = prev_n + 1} in
    // Handle full blocks in the rest of the input data
    let l2 : size_nat = len - l1 in
    let rem2 = sub input l1 l2 in
    let n : size_nat = l2 / size_block p in
    let r : size_nat = l2 % size_block p in
    let blocks = sub #uint8 rem2 0 (n * (size_block p)) in
    let st = update_multi p n blocks st in
    // Handle the remainder of the input
    let rem3 = sub #uint8 rem2 (n * (size_block p)) r in
    let pblock = update_sub st.blocks 0 r rem3 in
    {st with blocks = pblock; len_block = r}
  end

(* Definition of the finalization function *)
let finish' (p:parameters) (st:state p{st.n + number_blocks_padding_single p st.len_block <= max_size_t}) : lbytes p.size_hash =
  let pblock = sub st.blocks 0 st.len_block in
  let blocks = pad p st.n st.len_block pblock in
  assert(st.n + number_blocks_padding_single p st.len_block <= max_size_t);
  let st = update_multi p (number_blocks_padding_single p st.len_block) blocks st in
  let hash_final = uints_to_bytes_be st.hash in
  truncate p st.hash

(* Definition of the SHA2 ontime function based on incremental calls *)
let hash' (p:parameters) (len:size_nat{len < max_input p}) (input:lbytes len) : lbytes p.size_hash =
  let st = init p in
  let st = update' p len input st in
  finish' p st

(* Definition of the original SHA2 onetime function *)
let hash (p:parameters) (len:size_nat{len < max_input p /\ (size_block p * number_blocks_padding p len) <= max_size_t}) (input:lbytes len) : lbytes p.size_hash =
  let n = number_blocks_padding p len in
  let blocks = pad p 0 len input in
  let st = init p in
  let st = update_multi p n blocks st in
  finish p st

///
/// Parameters for all instances of SHA2
///

let rotval32 (n:nat{n > 0 /\ n < 32}) : rotval U32 = size n
let rotval64 (n:nat{n > 0 /\ n < 64}) : rotval U64 = size n

let const_224_256_ops = List.Tot.map rotval32 [
    2; 13; 22;
    6; 11; 25;
    7; 18; 3;
    17; 19; 10]

let const_384_512_ops = List.Tot.map rotval64 [
    28; 34; 39;
    14; 18; 41;
    1;   8;  7;
    19; 61;  6]


let const_224_h0 = List.Tot.map u32 [
    0xc1059ed8; 0x367cd507; 0x3070dd17; 0xf70e5939;
    0xffc00b31; 0x68581511; 0x64f98fa7; 0xbefa4fa4]

let const_256_h0 = List.Tot.map u32 [
    0x6a09e667; 0xbb67ae85; 0x3c6ef372; 0xa54ff53a;
    0x510e527f; 0x9b05688c; 0x1f83d9ab; 0x5be0cd19]

let const_384_h0 = List.Tot.map u64 [
    0xcbbb9d5dc1059ed8; 0x629a292a367cd507; 0x9159015a3070dd17; 0x152fecd8f70e5939;
    0x67332667ffc00b31; 0x8eb44a8768581511; 0xdb0c2e0d64f98fa7; 0x47b5481dbefa4fa4]

let const_512_h0 = List.Tot.map u64 [
    0x6a09e667f3bcc908; 0xbb67ae8584caa73b; 0x3c6ef372fe94f82b; 0xa54ff53a5f1d36f1;
    0x510e527fade682d1; 0x9b05688c2b3e6c1f; 0x1f83d9abfb41bd6b; 0x5be0cd19137e2179]


let const_224_256_k = List.Tot.map u32 [
    0x428a2f98; 0x71374491; 0xb5c0fbcf; 0xe9b5dba5;
    0x3956c25b; 0x59f111f1; 0x923f82a4; 0xab1c5ed5;
    0xd807aa98; 0x12835b01; 0x243185be; 0x550c7dc3;
    0x72be5d74; 0x80deb1fe; 0x9bdc06a7; 0xc19bf174;
    0xe49b69c1; 0xefbe4786; 0x0fc19dc6; 0x240ca1cc;
    0x2de92c6f; 0x4a7484aa; 0x5cb0a9dc; 0x76f988da;
    0x983e5152; 0xa831c66d; 0xb00327c8; 0xbf597fc7;
    0xc6e00bf3; 0xd5a79147; 0x06ca6351; 0x14292967;
    0x27b70a85; 0x2e1b2138; 0x4d2c6dfc; 0x53380d13;
    0x650a7354; 0x766a0abb; 0x81c2c92e; 0x92722c85;
    0xa2bfe8a1; 0xa81a664b; 0xc24b8b70; 0xc76c51a3;
    0xd192e819; 0xd6990624; 0xf40e3585; 0x106aa070;
    0x19a4c116; 0x1e376c08; 0x2748774c; 0x34b0bcb5;
    0x391c0cb3; 0x4ed8aa4a; 0x5b9cca4f; 0x682e6ff3;
    0x748f82ee; 0x78a5636f; 0x84c87814; 0x8cc70208;
    0x90befffa; 0xa4506ceb; 0xbef9a3f7; 0xc67178f2]

let const_384_512_k = List.Tot.map u64 [
    0x428a2f98d728ae22; 0x7137449123ef65cd; 0xb5c0fbcfec4d3b2f; 0xe9b5dba58189dbbc;
    0x3956c25bf348b538; 0x59f111f1b605d019; 0x923f82a4af194f9b; 0xab1c5ed5da6d8118;
    0xd807aa98a3030242; 0x12835b0145706fbe; 0x243185be4ee4b28c; 0x550c7dc3d5ffb4e2;
    0x72be5d74f27b896f; 0x80deb1fe3b1696b1; 0x9bdc06a725c71235; 0xc19bf174cf692694;
    0xe49b69c19ef14ad2; 0xefbe4786384f25e3; 0x0fc19dc68b8cd5b5; 0x240ca1cc77ac9c65;
    0x2de92c6f592b0275; 0x4a7484aa6ea6e483; 0x5cb0a9dcbd41fbd4; 0x76f988da831153b5;
    0x983e5152ee66dfab; 0xa831c66d2db43210; 0xb00327c898fb213f; 0xbf597fc7beef0ee4;
    0xc6e00bf33da88fc2; 0xd5a79147930aa725; 0x06ca6351e003826f; 0x142929670a0e6e70;
    0x27b70a8546d22ffc; 0x2e1b21385c26c926; 0x4d2c6dfc5ac42aed; 0x53380d139d95b3df;
    0x650a73548baf63de; 0x766a0abb3c77b2a8; 0x81c2c92e47edaee6; 0x92722c851482353b;
    0xa2bfe8a14cf10364; 0xa81a664bbc423001; 0xc24b8b70d0f89791; 0xc76c51a30654be30;
    0xd192e819d6ef5218; 0xd69906245565a910; 0xf40e35855771202a; 0x106aa07032bbd1b8;
    0x19a4c116b8d2d0c8; 0x1e376c085141ab53; 0x2748774cdf8eeb99; 0x34b0bcb5e19b48a8;
    0x391c0cb3c5c95a63; 0x4ed8aa4ae3418acb; 0x5b9cca4f7763e373; 0x682e6ff3d6b2b8a3;
    0x748f82ee5defb2fc; 0x78a5636f43172f60; 0x84c87814a1f0ab72; 0x8cc702081a6439ec;
    0x90befffa23631e28; 0xa4506cebde82bde9; 0xbef9a3f7b2c67915; 0xc67178f2e372532b;
    0xca273eceea26619c; 0xd186b8c721c0c207; 0xeada7dd6cde0eb1e; 0xf57d4f7fee6ed178;
    0x06f067aa72176fba; 0x0a637dc5a2c898a6; 0x113f9804bef90dae; 0x1b710b35131c471b;
    0x28db77f523047d84; 0x32caab7b40c72493; 0x3c9ebe0a15c9bebc; 0x431d67c49c100d4c;
    0x4cc5d4becb3e42b6; 0x597f299cfc657e2a; 0x5fcb6fab3ad6faec; 0x6c44198c4a475817]


let parameters224 : parameters =
  assert_norm(List.Tot.length const_224_h0 = 8);
  assert_norm(List.Tot.length const_224_256_ops = 12);
  assert_norm(List.Tot.length const_224_256_k = 64);
  MkParameters
    U32
    (of_list const_224_256_ops)
    64
    (of_list const_224_256_k)
    (of_list const_224_h0)
    28

let parameters256 : parameters =
  assert_norm(List.Tot.length const_256_h0 = 8);
  assert_norm(List.Tot.length const_224_256_ops = 12);
  assert_norm(List.Tot.length const_224_256_k = 64);
  MkParameters
    U32
    (of_list const_224_256_ops)
    64
    (of_list const_224_256_k)
    (of_list const_256_h0)
    32

let parameters384 : parameters =
  assert_norm(List.Tot.length const_384_h0 = 8);
  assert_norm(List.Tot.length const_384_512_ops = 12);
  assert_norm(List.Tot.length const_384_512_k = 80);
  MkParameters
    U64
    (of_list const_384_512_ops)
    80
    (of_list const_384_512_k)
    (of_list const_384_h0)
    48

let parameters512 : parameters =
  assert_norm(List.Tot.length const_512_h0 = 8);
  assert_norm(List.Tot.length const_384_512_ops = 12);
  assert_norm(List.Tot.length const_384_512_k = 80);
  MkParameters
    U64
    (of_list const_384_512_ops)
    80
    (of_list const_384_512_k)
    (of_list const_512_h0)
    64

///
/// Instances of SHA2
///

let state224 = state parameters224
let state256 = state parameters256
let state384 = state parameters384
let state512 = state parameters512

let size_block224 = size_block parameters224
let size_block256 = size_block parameters256
let size_block384 = size_block parameters384
let size_block512 = size_block parameters512

let size_hash224 = size_hash parameters224
let size_hash256 = size_hash parameters256
let size_hash384 = size_hash parameters384
let size_hash512 = size_hash parameters512

let max_input224 = max_input parameters224
let max_input256 = max_input parameters256
let max_input384 = max_input parameters384
let max_input512 = max_input parameters512

let init224 = init parameters224
let init256 = init parameters256
let init384 = init parameters384
let init512 = init parameters512

let update224 = update' parameters224
let update256 = update' parameters256
let update384 = update' parameters384
let update512 = update' parameters512

let finish224 = finish' parameters224
let finish256 = finish' parameters256
let finish384 = finish' parameters384
let finish512 = finish' parameters512

let hash224 = hash' parameters224
let hash256 = hash' parameters256
let hash384 = hash' parameters384
let hash512 = hash' parameters512

