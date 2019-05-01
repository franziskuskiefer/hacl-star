module SHA_helpers

open Prop_s
open Opaque_s
open Spec.SHA2
open Spec.Hash
open Spec.Hash.Definitions
open Spec.Hash.Lemmas
open X64.CryptoInstructions_s
open Types_s
open Words_s
open FStar.Seq
open FStar.UInt32  // Interop with UInt-based SHA spec
open Arch.Types

friend Spec.SHA2
friend X64.CryptoInstructions_s

#reset-options "--max_fuel 0 --max_ifuel 0"

// Define these specific converters here, so that F* only reasons about 
// the correctness of the conversion once, rather that at every call site
let vv (u:UInt32.t) : nat32 = v u
let to_uint32 (n:nat32) : UInt32.t = uint_to_t n
let word = UInt32.t
let k = (Spec.SHA2.k0 SHA2_256)

let reveal_word () = ()

unfold let ws_opaque_aux = ws
let ws_opaque (b:block_w) (t:counter{t < size_k_w_256}) : nat32 = 
  vv (ws_opaque_aux SHA2_256 b t)

unfold let shuffle_core_opaque_aux = shuffle_core
let shuffle_core_opaque (block:block_w) (hash:hash256) (t:counter{t < size_k_w_256}):hash256 =
  shuffle_core_opaque_aux SHA2_256 block hash t

unfold let update_multi_opaque_aux = make_opaque update_multi
let update_multi_opaque (hash:hash256) (blocks:bytes_blocks):hash256 =
  update_multi_opaque_aux SHA2_256 hash blocks

let update_multi_transparent (hash:hash256) (blocks:bytes_blocks) = 
  update_multi SHA2_256 hash blocks

let add_mod32 (x:word) (y:nat32) : nat32 = vv (add_mod x (to_uint32 y))
let word_to_nat32 = vv
let nat32_to_word = to_uint32
let byte_to_nat8 = UInt8.v
let nat8_to_byte = UInt8.uint_to_t

let make_hash_def (abef cdgh:quad32) :
    (hash:words_state SHA2_256 {
         length hash == 8 /\
         hash.[0] == to_uint32 abef.hi3 /\
         hash.[1] == to_uint32 abef.hi2 /\
         hash.[2] == to_uint32 cdgh.hi3 /\
         hash.[3] == to_uint32 cdgh.hi2 /\
         hash.[4] == to_uint32 abef.lo1 /\
         hash.[5] == to_uint32 abef.lo0 /\
         hash.[6] == to_uint32 cdgh.lo1 /\
         hash.[7] == to_uint32 cdgh.lo0    
    } ) =
    let a = to_uint32 abef.hi3 in
    let b = to_uint32 abef.hi2 in
    let c = to_uint32 cdgh.hi3 in
    let d = to_uint32 cdgh.hi2 in
    let e = to_uint32 abef.lo1 in
    let f = to_uint32 abef.lo0 in
    let g = to_uint32 cdgh.lo1 in
    let h = to_uint32 cdgh.lo0 in
    let l = [a; b; c; d; e; f; g; h] in
    let hash = seq_of_list l in
    assert_norm (length hash == 8);
    elim_of_list l;
    //assert_norm (index hash 2 == c);
    hash

let make_hash = make_opaque make_hash_def

let make_ordered_hash_def (abcd efgh:quad32) :
  (hash:words_state SHA2_256 {
         length hash == 8 /\
         hash.[0] == to_uint32 abcd.lo0 /\
         hash.[1] == to_uint32 abcd.lo1 /\
         hash.[2] == to_uint32 abcd.hi2 /\
         hash.[3] == to_uint32 abcd.hi3 /\
         hash.[4] == to_uint32 efgh.lo0 /\
         hash.[5] == to_uint32 efgh.lo1 /\
         hash.[6] == to_uint32 efgh.hi2 /\
         hash.[7] == to_uint32 efgh.hi3      
   })
  =
    let a = to_uint32 abcd.lo0 in
    let b = to_uint32 abcd.lo1 in
    let c = to_uint32 abcd.hi2 in
    let d = to_uint32 abcd.hi3 in
    let e = to_uint32 efgh.lo0 in
    let f = to_uint32 efgh.lo1 in
    let g = to_uint32 efgh.hi2 in
    let h = to_uint32 efgh.hi3 in
    let l = [a; b; c; d; e; f; g; h] in
    let hash = seq_of_list l in
    assert_norm (length hash == 8);
    elim_of_list l;
    hash  

let make_ordered_hash = make_opaque make_ordered_hash_def

let shuffle_core_properties (block:block_w) (hash:hash256) (t:counter{t < size_k_w_256}) :
    Lemma(let h = shuffle_core_opaque block hash t in
          let a0 = hash.[0] in
          let b0 = hash.[1] in
          let c0 = hash.[2] in
          let d0 = hash.[3] in
          let e0 = hash.[4] in
          let f0 = hash.[5] in
          let g0 = hash.[6] in
          let h0 = hash.[7] in
          let t1 = word_add_mod SHA2_256 h0 (word_add_mod SHA2_256 (_Sigma1 SHA2_256 e0) (word_add_mod SHA2_256 (_Ch SHA2_256 e0 f0 g0) (word_add_mod SHA2_256 (k0 SHA2_256).[t] (ws SHA2_256 block t)))) in
          let t2 = word_add_mod SHA2_256 (_Sigma0 SHA2_256 a0) (_Maj SHA2_256 a0 b0 c0) in         
          h.[0] == word_add_mod SHA2_256 t1 t2 /\
          h.[1] == a0 /\
          h.[2] == b0 /\
          h.[3] == c0 /\
          h.[4] == word_add_mod SHA2_256 d0 t1 /\
          h.[5] == e0 /\
          h.[6] == f0 /\
          h.[7] == g0)
  =
  Pervasives.reveal_opaque (`%shuffle_core) shuffle_core;
  let h = shuffle_core SHA2_256 block hash t in
  let a0 = hash.[0] in
  let b0 = hash.[1] in
  let c0 = hash.[2] in
  let d0 = hash.[3] in
  let e0 = hash.[4] in
  let f0 = hash.[5] in
  let g0 = hash.[6] in
  let h0 = hash.[7] in
  let t1 = word_add_mod SHA2_256 h0 (word_add_mod SHA2_256 (_Sigma1 SHA2_256 e0) (word_add_mod SHA2_256 (_Ch SHA2_256 e0 f0 g0) (word_add_mod SHA2_256 (k0 SHA2_256).[t] (ws SHA2_256 block t)))) in
  let t2 = word_add_mod SHA2_256 (_Sigma0 SHA2_256 a0) (_Maj SHA2_256 a0 b0 c0) in         
  let l = [ word_add_mod SHA2_256 t1 t2; a0; b0; c0; word_add_mod SHA2_256 d0 t1; e0; f0; g0 ] in
  assert (h == seq_of_list l);
  elim_of_list l;
  ()

let sha256_rnds2_spec_update_quad32 (abef cdgh:quad32) (wk:UInt32.t) : (quad32*quad32) =
  let hash0 = make_hash abef cdgh in
  let a', b', c', d', e', f', g', h' = sha256_rnds2_spec_update hash0.[0] hash0.[1] hash0.[2] hash0.[3] hash0.[4] hash0.[5] hash0.[6] hash0.[7] wk in
  let abef' = Mkfour (vv f') (vv e') (vv b') (vv a') in
  let cdgh' = Mkfour (vv h') (vv g') (vv d') (vv c') in
  (abef', cdgh')

let sha256_rnds2_spec_quad32 (src1 src2 wk:quad32) : quad32 =
  let abef', cdgh'   = sha256_rnds2_spec_update_quad32 src2 src1   (to_uint32 wk.lo0) in
  let abef'', cdgh'' = sha256_rnds2_spec_update_quad32 abef' cdgh' (to_uint32 wk.lo1) in
  abef''

let lemma_sha256_rnds2_spec_quad32 (src1 src2 wk:quad32) :
  Lemma (sha256_rnds2_spec src1 src2 wk == sha256_rnds2_spec_quad32 src1 src2 wk)
  =
  reveal_opaque sha256_rnds2_spec_def;
  ()
  
let lemma_add_mod_commutes (x y:UInt32.t) :
  Lemma (add_mod x y == add_mod y x)
  =
  ()

let lemma_add_mod32_associates (x y z:int) :
  Lemma ( ((x + y % pow2_32) + z) % pow2_32 == (x + ((y + z) % pow2_32)) % pow2_32 )
  =
  ()

let lemma_add_mod_associates_U32 (x y z:UInt32.t) :
  Lemma (add_mod x (add_mod y z) == add_mod (add_mod x y) z)
  =
  assert_norm (pow2 32 == pow2_32);
  //assert (add_mod y z == to_uint32 ((vv y + vv z) % pow2_32));
  //assert (add_mod x (add_mod y z) == to_uint32 ((vv x + vv (to_uint32 ((vv y + vv z) % pow2_32))) % pow2_32));
  lemma_add_mod32_associates (vv x) (vv y) (vv z);
  //assert (to_uint32 ((vv x + vv (to_uint32 ((vv y + vv z) % pow2_32))) % pow2_32) ==
  //        to_uint32 (((vv x + vv y % pow2_32) + vv z) % pow2_32));
  admit() // TODO: This proof is flaky.  Some combination of the asserts above will make it go through, but the combo varies day by day

let lemma_add_wrap_is_add_mod (n0 n1:nat32) :
  Lemma (add_wrap n0 n1 == vv (add_mod (to_uint32 n0) (to_uint32 n1)))
  =
  assert_norm (pow2 32 == pow2_32);
  ()

let add_wrap_commutes (x y:nat32) :
  Lemma(add_wrap x y == add_wrap y x)
  =
  ()

// Walk F* through the math steps required to rearrange all of the add_mods
let lemma_add_mod_a (a b c d e f g h wk:UInt32.t) : 
  Lemma ( let u = add_mod (_Ch SHA2_256 e f g) 
                  (add_mod (_Sigma1 SHA2_256 e) 
                  (add_mod wk 
                  (add_mod h 
                  (add_mod (_Maj SHA2_256 a b c) 
                           (_Sigma0 SHA2_256 a))))) in
          let t1 = add_mod h (add_mod (_Sigma1 SHA2_256 e) (add_mod (_Ch SHA2_256 e f g) wk)) in
          let t2 = add_mod (_Sigma0 SHA2_256 a) (_Maj SHA2_256 a b c) in                      
          let core = add_mod t1 t2 in
          u == core)
  =
  let t1 = add_mod h (add_mod (_Sigma1 SHA2_256 e) (add_mod (_Ch SHA2_256 e f g) wk)) in
  let t2 = add_mod (_Sigma0 SHA2_256 a) (_Maj SHA2_256 a b c) in                      
  let core = add_mod t1 t2 in
  lemma_add_mod_commutes (_Sigma0 SHA2_256 a) (_Maj SHA2_256 a b c);
  assert (t2 == add_mod (_Maj SHA2_256 a b c) (_Sigma0 SHA2_256 a));
  lemma_add_mod_commutes h (add_mod (_Sigma1 SHA2_256 e) (add_mod (_Ch SHA2_256 e f g) wk));
  assert (t1 == add_mod (add_mod (_Sigma1 SHA2_256 e) (add_mod (_Ch SHA2_256 e f g) wk)) h);
  lemma_add_mod_associates_U32 (add_mod (_Sigma1 SHA2_256 e) (add_mod (_Ch SHA2_256 e f g) wk)) h (add_mod (_Maj SHA2_256 a b c) (_Sigma0 SHA2_256 a));
  assert (core == add_mod (add_mod (_Sigma1 SHA2_256 e) (add_mod (_Ch SHA2_256 e f g) wk)) (add_mod h (add_mod (_Maj SHA2_256 a b c) (_Sigma0 SHA2_256 a))));
  lemma_add_mod_associates_U32 (_Sigma1 SHA2_256 e) (_Ch SHA2_256 e f g) wk;
  // ==> add_mod (add_mod (_Sigma1 SHA2_256 e) (_Ch SHA2_256 e f g)) wk)
  lemma_add_mod_commutes (_Sigma1 SHA2_256 e) (_Ch SHA2_256 e f g);
  // ==> add_mod (add_mod (_Ch SHA2_256 e f g) (_Sigma1 SHA2_256 e)) wk)
  lemma_add_mod_associates_U32 (add_mod (_Ch SHA2_256 e f g) (_Sigma1 SHA2_256 e)) wk (add_mod h (add_mod (_Maj SHA2_256 a b c) (_Sigma0 SHA2_256 a)));
  assert (core == add_mod (add_mod (_Ch SHA2_256 e f g) (_Sigma1 SHA2_256 e)) (add_mod wk (add_mod h (add_mod (_Maj SHA2_256 a b c) (_Sigma0 SHA2_256 a)))));
  lemma_add_mod_associates_U32 (_Ch SHA2_256 e f g) (_Sigma1 SHA2_256 e) (add_mod wk (add_mod h (add_mod (_Maj SHA2_256 a b c) (_Sigma0 SHA2_256 a))));
  ()

let lemma_add_mod_e (a b c d e f g h wk:UInt32.t) : 
  Lemma ( let u = add_mod (_Ch SHA2_256 e f g)
                  (add_mod (_Sigma1 SHA2_256 e)
                  (add_mod wk 
                  (add_mod h 
                           d))) in
          let t1 = add_mod h (add_mod (_Sigma1 SHA2_256 e) (add_mod (_Ch SHA2_256 e f g) wk)) in
          let core = add_mod d t1 in
          u == core)
  =
  let t1 = add_mod h (add_mod (_Sigma1 SHA2_256 e) (add_mod (_Ch SHA2_256 e f g) wk)) in
  let core = add_mod d t1 in
  lemma_add_mod_commutes h (add_mod (_Sigma1 SHA2_256 e) (add_mod (_Ch SHA2_256 e f g) wk));
  // t1 == add_mod (add_mod (_Sigma1 SHA2_256 e) (add_mod (_Ch SHA2_256 e f g) wk)) h);
  lemma_add_mod_commutes d t1;
  // core == add_mod t1 d
  lemma_add_mod_associates_U32 (_Sigma1 SHA2_256 e) (_Ch SHA2_256 e f g) wk;
  assert (t1 == add_mod (add_mod (add_mod (_Sigma1 SHA2_256 e) (_Ch SHA2_256 e f g)) wk) h);
  lemma_add_mod_associates_U32 (add_mod (add_mod (_Sigma1 SHA2_256 e) (_Ch SHA2_256 e f g)) wk) h d;
  assert (core == add_mod (add_mod (add_mod (_Sigma1 SHA2_256 e) (_Ch SHA2_256 e f g)) wk) (add_mod h d));
  lemma_add_mod_associates_U32 (add_mod (_Sigma1 SHA2_256 e) (_Ch SHA2_256 e f g)) wk (add_mod h d);
  assert (core == add_mod (add_mod (_Sigma1 SHA2_256 e) (_Ch SHA2_256 e f g)) (add_mod wk (add_mod h d)));
    lemma_add_mod_associates_U32 (_Ch SHA2_256 e f g) (_Sigma1 SHA2_256 e)  (add_mod wk (add_mod h d));
  assert (core == add_mod (_Ch SHA2_256 e f g) (add_mod (_Sigma1 SHA2_256 e) (add_mod wk (add_mod h d))));
  ()

let lemma_sha256_rnds2_spec_update_is_shuffle_core (hash:hash256) (wk:UInt32.t) (t:counter) (block:block_w) : Lemma
   (requires t < size_k_w SHA2_256 /\ wk == to_uint32 (add_mod32 (k0 SHA2_256).[t] (ws_opaque block t)))
   (ensures (let a', b', c', d', e', f', g', h' = 
                 sha256_rnds2_spec_update hash.[0] hash.[1] hash.[2] hash.[3] 
                                          hash.[4] hash.[5] hash.[6] hash.[7] wk in
             let u = seq_of_list [a'; b'; c'; d'; e'; f'; g'; h'] in
             let c = shuffle_core_opaque block hash t in
             u == c))
  =
  let a', b', c', d', e', f', g', h' = 
                 sha256_rnds2_spec_update hash.[0] hash.[1] hash.[2] hash.[3] 
                                          hash.[4] hash.[5] hash.[6] hash.[7] wk in
  let l = [a'; b'; c'; d'; e'; f'; g'; h'] in                                          
  let u = seq_of_list l in
  let c = shuffle_core_opaque block hash t in
  Pervasives.reveal_opaque (`%shuffle_core) shuffle_core;
  Pervasives.reveal_opaque (`%ws) ws;
  shuffle_core_properties block hash t;
  elim_of_list l;
  lemma_add_mod_a hash.[0] hash.[1] hash.[2] hash.[3] hash.[4] hash.[5] hash.[6] hash.[7] wk;
  lemma_add_mod_e hash.[0] hash.[1] hash.[2] hash.[3] hash.[4] hash.[5] hash.[6] hash.[7] wk;  
  ()

let sha256_rnds2_spec_update_core_quad32 (abef cdgh:quad32) (wk:UInt32.t) (block:block_w) (t:counter{t < size_k_w_256}) : (quad32*quad32) =
  let hash0 = make_hash abef cdgh in
  let hash1 = shuffle_core_opaque block hash0 t in
  let abef' = Mkfour (vv hash1.[5]) (vv hash1.[4]) (vv hash1.[1]) (vv hash1.[0]) in
  let cdgh' = Mkfour (vv hash1.[7]) (vv hash1.[6]) (vv hash1.[3]) (vv hash1.[2]) in
  (abef', cdgh')

let lemma_rnds_quad32 (abef cdgh:quad32) (wk:UInt32.t) (block:block_w) (t:counter{t < size_k_w_256}) : Lemma
  (requires wk == to_uint32 (add_mod32 (k0 SHA2_256).[t] (ws_opaque block t)))
  (ensures sha256_rnds2_spec_update_core_quad32 abef cdgh wk block t == sha256_rnds2_spec_update_quad32 abef cdgh wk)
  =
  let hash0 = make_hash abef cdgh in
  let hash1 = shuffle_core_opaque block hash0 t in
  let a', b', c', d', e', f', g', h' = 
                 sha256_rnds2_spec_update hash0.[0] hash0.[1] hash0.[2] hash0.[3] 
                                          hash0.[4] hash0.[5] hash0.[6] hash0.[7] wk in
  let l = [a'; b'; c'; d'; e'; f'; g'; h'] in                                      
  elim_of_list l;
  lemma_sha256_rnds2_spec_update_is_shuffle_core hash0 wk t block;
  ()

#push-options "--z3rlimit 10"
let lemma_rnds2_spec_quad32_is_shuffle_core_x2 (abef cdgh:quad32) (wk0 wk1:UInt32.t) (block:block_w) (t:counter{t < size_k_w_256 - 1}) : Lemma
  (requires vv wk0 == add_mod32 (k0 SHA2_256).[t] (ws_opaque block t) /\
            vv wk1 == add_mod32 (k0 SHA2_256).[t+1] (ws_opaque block (t+1)))
  (ensures (let hash0 = make_hash abef cdgh in
            let hash1 = shuffle_core_opaque block hash0 t in
            let hash2 = shuffle_core_opaque block hash1 (t + 1) in
            let abef', cdgh' = sha256_rnds2_spec_update_quad32 abef cdgh wk0 in
            let abef'', cdgh'' = sha256_rnds2_spec_update_quad32 abef' cdgh' wk1 in
            hash2 == make_hash abef'' cdgh''))
  =
  let hash0 = make_hash abef cdgh in
  let hash1 = shuffle_core_opaque block hash0 t in
  let hash2 = shuffle_core_opaque block hash1 (t + 1) in
  let abef', cdgh' = sha256_rnds2_spec_update_quad32 abef cdgh wk0 in
  let abef'', cdgh'' = sha256_rnds2_spec_update_quad32 abef' cdgh' wk1 in
  lemma_rnds_quad32 abef cdgh wk0 block t;
  lemma_rnds_quad32 abef' cdgh' wk1 block (t+1);
  assert (equal (make_hash abef' cdgh') hash1);
  assert (equal (make_hash abef'' cdgh'') hash2);
  ()
#pop-options

let sha256_rnds2_spec_update_quad32_x2_shifts (abef cdgh:quad32) (wk0 wk1:UInt32.t) : 
  Lemma ((let abef', cdgh' = sha256_rnds2_spec_update_quad32 abef cdgh wk0 in
          let abef'', cdgh'' = sha256_rnds2_spec_update_quad32 abef' cdgh' wk1 in
          cdgh'' == abef))
  =
  ()

let sha256_rnds2_spec_quad32_is_shuffle_core_x2 (abef cdgh wk:quad32) (block:block_w) (t:counter{t < size_k_w_256 - 1}) : Lemma
  (requires wk.lo0 == add_mod32 (k0 SHA2_256).[t]   (ws_opaque block t) /\
            wk.lo1 == add_mod32 (k0 SHA2_256).[t+1] (ws_opaque block (t+1)))
  (ensures (let hash0 = make_hash abef cdgh in
            let hash1 = shuffle_core_opaque block hash0 t in
            let hash2 = shuffle_core_opaque block hash1 (t + 1) in
            let abef' = sha256_rnds2_spec_quad32 cdgh abef wk in
            hash2 == make_hash abef' abef))
  =
  lemma_rnds2_spec_quad32_is_shuffle_core_x2 abef cdgh (to_uint32 wk.lo0) (to_uint32 wk.lo1) block t;
  sha256_rnds2_spec_update_quad32_x2_shifts abef cdgh (to_uint32 wk.lo0) (to_uint32 wk.lo1);
  ()

let lemma_sha256_rnds2_two_steps (abef cdgh xmm0:quad32) (t:counter) (block:block_w) : Lemma
  (requires t + 1 < size_k_w_256 /\
            xmm0.lo0 == add_wrap (vv (k0 SHA2_256).[t]  ) (ws_opaque block t) /\
            xmm0.lo1 == add_wrap (vv (k0 SHA2_256).[t+1]) (ws_opaque block (t+1)) )
  (ensures (let hash0 = make_hash abef cdgh in
            let hash1 = shuffle_core_opaque block hash0 t in
            let hash2 = shuffle_core_opaque block hash1 (t + 1) in
            hash2 == make_hash (sha256_rnds2_spec cdgh abef xmm0) abef))
  =  
  let hash0 = make_hash abef cdgh in
  let hash1 = shuffle_core_opaque block hash0 t in
  let hash2 = shuffle_core_opaque block hash1 (t + 1) in
  lemma_add_wrap_is_add_mod (vv (k0 SHA2_256).[t]  ) (ws_opaque block t);
  lemma_add_wrap_is_add_mod (vv (k0 SHA2_256).[t+1]) (ws_opaque block (t+1));
  sha256_rnds2_spec_quad32_is_shuffle_core_x2 abef cdgh xmm0 block t;
  lemma_sha256_rnds2_spec_quad32 cdgh abef xmm0;
  ()

// Top-level proof for the SHA256_rnds2 instruction
let lemma_sha256_rnds2 (abef cdgh xmm0:quad32) (t:counter) (block:block_w) (hash_in:hash256) : Lemma
  (requires t + 1 < size_k_w_256 /\
            xmm0.lo0 == add_wrap (word_to_nat32 k.[t])   (ws_opaque block t) /\
            xmm0.lo1 == add_wrap (word_to_nat32 k.[t+1]) (ws_opaque block (t+1)) /\ 
            make_hash abef cdgh == Spec.Loops.repeat_range 0 t (shuffle_core_opaque block) hash_in
            )
  (ensures make_hash (sha256_rnds2_spec cdgh abef xmm0) abef ==
           Spec.Loops.repeat_range 0 (t+2) (shuffle_core_opaque block) hash_in)
  =
  lemma_add_wrap_is_add_mod (vv (k0 SHA2_256).[t]  ) (ws_opaque block t);
  lemma_add_wrap_is_add_mod (vv (k0 SHA2_256).[t+1]) (ws_opaque block (t+1));
  lemma_sha256_rnds2_two_steps abef cdgh xmm0 t block;
  Spec.Loops.repeat_range_induction 0 (t + 1) (shuffle_core_opaque block) hash_in;
  Spec.Loops.repeat_range_induction 0 (t + 2) (shuffle_core_opaque block) hash_in;
  ()

(* Proof work for the SHA256_msg* instructions *)
let _sigma0_quad32 (q:quad32) : quad32 =
  Mkfour (vv (_sigma0 SHA2_256 (to_uint32 q.lo0)))
         (vv (_sigma0 SHA2_256 (to_uint32 q.lo1)))
         (vv (_sigma0 SHA2_256 (to_uint32 q.hi2)))
         (vv (_sigma0 SHA2_256 (to_uint32 q.hi3)))

let _sigma1_quad32 (q:quad32) : quad32 =
  Mkfour (vv (_sigma1 SHA2_256 (to_uint32 q.lo0)))
         (vv (_sigma1 SHA2_256 (to_uint32 q.lo1)))
         (vv (_sigma1 SHA2_256 (to_uint32 q.hi2)))
         (vv (_sigma1 SHA2_256 (to_uint32 q.hi3)))

let ws_partial_def (t:counter) (block:block_w) : quad32 =
    if 16 <= t && t < size_k_w_256 then
       (let init = ws_quad32 (t-16) block in
        let sigma0_in = ws_quad32 (t-15) block in
        let sigma0_out = _sigma0_quad32 sigma0_in in
        add_wrap_quad32 init sigma0_out)
    else 
       Mkfour 0 0 0 0

let add_mod_quad32 (q0 q1:quad32) : quad32 =
  Mkfour (vv (add_mod (to_uint32 q0.lo0) (to_uint32 q1.lo0)))
         (vv (add_mod (to_uint32 q0.lo1) (to_uint32 q1.lo1)))
         (vv (add_mod (to_uint32 q0.hi2) (to_uint32 q1.hi2)))
         (vv (add_mod (to_uint32 q0.hi3) (to_uint32 q1.hi3)))

let lemma_add_wrap_quad32_is_add_mod_quad32 (q0 q1:quad32) :
  Lemma (add_mod_quad32 q0 q1 == add_wrap_quad32 q0 q1)
  =
  FStar.Classical.forall_intro_2 lemma_add_wrap_is_add_mod;
  ()

// Top-level proof for the SHA256_msg1 instruction
let lemma_sha256_msg1 (dst src:quad32) (t:counter) (block:block_w) : Lemma
  (requires 16 <= t /\ t < size_k_w(SHA2_256) /\
            dst == ws_quad32 (t-16) block /\
            src.lo0 == ws_opaque block (t-12))
  (ensures sha256_msg1_spec dst src == ws_partial t block)
  =
  reveal_opaque sha256_msg1_spec_def;
  let init = ws_quad32 (t-16) block in
  let sigma0_in = ws_quad32 (t-15) block in
  let sigma0_out = _sigma0_quad32 sigma0_in in
  lemma_add_wrap_quad32_is_add_mod_quad32 init sigma0_out;
  reveal_opaque ws_partial_def;
  ()
  

let lemma_add_mod_ws_rearrangement (a b c d:UInt32.t) :
  Lemma (add_mod a (add_mod b (add_mod c d)) == add_mod (add_mod (add_mod d c) b) a)
  =
  lemma_add_mod_commutes (add_mod (add_mod d c) b) a;
  assert (add_mod (add_mod (add_mod d c) b) a == add_mod a (add_mod (add_mod d c) b));
  lemma_add_mod_commutes (add_mod d c) b;
  assert (add_mod a (add_mod (add_mod d c) b) == add_mod a (add_mod b (add_mod d c)));
  lemma_add_mod_commutes d c;
  assert (add_mod a (add_mod b (add_mod d c)) == add_mod a (add_mod b (add_mod c d)));
  ()

let ws_computed (b:block_w) (t:counter{t < size_k_w_256}): Tot (UInt32.t) =
  if t < block_word_length then to_uint32 (ws_opaque b t)
  else
    let t16 = to_uint32 (ws_opaque b (t - 16)) in
    let t15 = to_uint32 (ws_opaque b (t - 15)) in
    let t7  = to_uint32 (ws_opaque b (t - 7)) in
    let t2  = to_uint32 (ws_opaque b (t - 2)) in
    let s1 = _sigma1 SHA2_256 t2 in
    let s0 = _sigma0 SHA2_256 t15 in
    (word_add_mod SHA2_256 (word_add_mod SHA2_256 (word_add_mod SHA2_256 t16 s0) t7) s1)

#push-options "--max_fuel 1"
let lemma_ws_computed_is_ws (b:block_w) (t:counter{t < size_k_w_256}) :
  Lemma (ws_computed b t == ws SHA2_256 b t)
  =
  Pervasives.reveal_opaque (`%ws) ws;
  if t < block_word_length then (
    assert (vv (ws_computed b t) == ws_opaque b t);
    assert (to_uint32 (ws_opaque b t) == ws SHA2_256 b t);
    ()
  ) else (
    let t16 = to_uint32 (ws_opaque b (t - 16)) in
    let t15 = to_uint32 (ws_opaque b (t - 15)) in
    let t7  = to_uint32 (ws_opaque b (t - 7)) in
    let t2  = to_uint32 (ws_opaque b (t - 2)) in
    let s1 = _sigma1 SHA2_256 t2 in
    let s0 = _sigma0 SHA2_256 t15 in
    lemma_add_mod_ws_rearrangement s1 t7 s0 t16;
    ()
  )
#pop-options

let lemma_ws_computed_is_ws_opaque (b:block_w) (t:counter{t < size_k_w_256}) :
  Lemma (vv (ws_computed b t) == ws_opaque b t)
  =
  lemma_ws_computed_is_ws b t;
  Pervasives.reveal_opaque (`%ws) ws;
  ()

let ws_computed_quad32 (t:counter{t < size_k_w_256 - 3}) (block:block_w) : quad32 =
       Mkfour (vv (ws_computed block t))
              (vv (ws_computed block (t+1)))
              (vv (ws_computed block (t+2)))
              (vv (ws_computed block (t+3)))

let lemma_ws_computed_is_ws_quad32 (b:block_w) (t:counter{t < size_k_w_256 - 3}) :
  Lemma (ws_computed_quad32 t b == ws_quad32 t b)
  =
  let w = ws_computed_quad32 t b in
  let w' = ws_quad32 t b in
  lemma_ws_computed_is_ws_opaque b t;
  lemma_ws_computed_is_ws_opaque b (t+1);
  lemma_ws_computed_is_ws_opaque b (t+2);
  lemma_ws_computed_is_ws_opaque b (t+3);  
  ()

#push-options "--z3rlimit 30"
let lemma_ws_computed_quad32 (t:counter{16 <= t /\ t < size_k_w_256 - 4}) (block:block_w) :
  Lemma (let t_minus_16 = ws_quad32 (t-16) block in
         let t_minus_15 = ws_quad32 (t-15) block in
         let t_minus_7 = ws_quad32 (t - 7) block in
         let t_minus_2 = ws_quad32 (t - 2) block in        
         let m1 = add_mod_quad32 t_minus_16 (_sigma0_quad32 t_minus_15) in
         let m2 = add_mod_quad32 m1 t_minus_7 in
         let m3 = add_mod_quad32 m2 (_sigma1_quad32 t_minus_2) in
         m3 == ws_computed_quad32 t block )
  =
  ()
#pop-options  

let sha256_msg1_spec_t (t:counter{t < size_k_w_256 - 1}) (block:block_w) : quad32 =
  let init = ws_quad32 t block in
  let next = ws_quad32 (t + 1) block in
  let msg1 = add_mod_quad32 init (_sigma0_quad32 next) in
  msg1

let lemma_sha256_msg1_spec_t_partial (t:counter) (block:block_w) : Lemma
  (requires 16 <= t /\ t < size_k_w_256 - 3)
  (ensures ws_partial t block == sha256_msg1_spec_t (t-16) block)
  =
  reveal_opaque ws_partial_def;
  let init = ws_quad32 (t-16) block in
  let next = ws_quad32 (t-15) block in
  lemma_add_wrap_quad32_is_add_mod_quad32 init (_sigma0_quad32 next);
  ()
          
let lemma_sha256_msg1_spec_t (src1 src2:quad32) (t:counter) (block:block_w) : Lemma
  (requires t < size_k_w_256 - 4 /\
            src1 == ws_quad32 t block /\
            src2.lo0 == ws_opaque block (t+4))
  (ensures sha256_msg1_spec_t t block == sha256_msg1_spec src1 src2)
  =
  reveal_opaque sha256_msg1_spec_def;
  ()

#push-options "--z3rlimit 30"
let lemma_sha256_step2 (src1 src2:quad32) (t:counter) (block:block_w) : Lemma
  (requires 16 <= t /\ t < size_k_w(SHA2_256) - 3 /\
            src2.hi2 == ws_opaque block (t-2) /\
            src2.hi3 == ws_opaque block (t-1) /\
            (let w = sha256_msg1_spec_t (t-16) block in
             let mid = ws_quad32 (t-7) block in
             src1 == add_mod_quad32 w mid))
  (ensures sha256_msg2_spec src1 src2 == ws_computed_quad32 t block)
  =
  reveal_opaque sha256_msg2_spec_def;
  let w = sha256_msg1_spec_t (t-16) block in
  let mid = ws_quad32 (t-7) block in
  let final = sha256_msg2_spec src1 src2 in
  lemma_ws_computed_is_ws_opaque block (t);
  lemma_ws_computed_is_ws_opaque block (t+1);
  ()
#pop-options

// Top-level proof for the SHA256_msg2 instruction
let lemma_sha256_msg2 (src1 src2:quad32) (t:counter) (block:block_w) : Lemma
  (requires 16 <= t /\ t < size_k_w(SHA2_256) - 3 /\
            (let step1 = ws_partial t block in
             let t_minus_7 = ws_quad32 (t-7) block in
             src1 == add_wrap_quad32 step1 t_minus_7 /\

             src2.hi2 == ws_opaque block (t-2) /\
             src2.hi3 == ws_opaque block (t-1)))
  (ensures sha256_msg2_spec src1 src2 == ws_quad32 t block)
  =
  let step1 = ws_partial t block in
  let t_minus_7 = ws_quad32 (t-7) block in
  lemma_sha256_msg1_spec_t_partial t block;
  // ==> step1 == sha256_msg1_spec_t (t-16) block
  lemma_add_wrap_quad32_is_add_mod_quad32 step1 t_minus_7;
  lemma_sha256_step2 src1 src2 t block;
  lemma_ws_computed_is_ws_quad32 block t;
  ()


(* Abbreviations and lemmas for the code itself *)
open Workarounds

(*+ TODO: Why does this work in fsti but not here? +*)
(*
#push-options "--z3rlimit 20 --max_fuel 1"
let lemma_quads_to_block (qs:seq quad32) : Lemma
  (requires length qs == 4)
  (ensures (let block = quads_to_block qs in
            forall i . {:pattern (index_work_around_quad32 qs i)} 0 <= i /\ i < 4 ==>
              (qs.[i]).lo0 == ws_opaque block (4 `op_Multiply` i + 0) /\
              (qs.[i]).lo1 == ws_opaque block (4 `op_Multiply` i + 1) /\
              (qs.[i]).hi2 == ws_opaque block (4 `op_Multiply` i + 2) /\
              (qs.[i]).hi3 == ws_opaque block (4 `op_Multiply` i + 3) /\
              qs.[i] == ws_quad32 (4 `op_Multiply` i) block))
  =  
  //reveal_opaque ws;
  admit()
#pop-options
*)

let translate_hash_update (h0 h1 h0' h1' a0 a1:quad32) : Lemma
  (requires h0' == add_wrap_quad32 a0 h0 /\
            h1' == add_wrap_quad32 a1 h1) 
  (ensures (
         let h = make_hash h0 h1 in
         let a = make_hash a0 a1 in
         let h' = make_hash h0' h1' in
         let mapped = Spec.Loops.seq_map2 (fun x y -> word_add_mod SHA2_256 x y) h a in
         mapped == h'))
  =
  let h = make_hash h0 h1 in
  let a = make_hash a0 a1 in
  let h' = make_hash h0' h1' in
  let mapped = Spec.Loops.seq_map2 (fun x y -> word_add_mod SHA2_256 x y) h a in
  FStar.Classical.forall_intro_2 lemma_add_wrap_is_add_mod;
  assert (equal mapped h');
  ()
         
unfold let shuffle_opaque = shuffle
  
let update_block (hash:hash256) (block:block_w): Tot (hash256) =
  let hash_1 = shuffle_opaque SHA2_256 hash block in
  Spec.Loops.seq_map2 (fun x y -> word_add_mod SHA2_256 x y) hash hash_1

let lemma_update_block_equiv (hash:hash256) (block:bytes{length block = block_length}) :
  Lemma (update_block hash (words_of_bytes SHA2_256 block_word_length block) == update SHA2_256 hash block)
  =
  Pervasives.reveal_opaque (`%Spec.SHA2.update) Spec.SHA2.update;
  assert (equal (update_block hash (words_of_bytes SHA2_256 block_word_length block)) (update SHA2_256 hash block));
  ()

(*+ TODO: Broken due to indirection of opaque +*)
let update_lemma (src1 src2 src1' src2' h0 h1:quad32) (block:block_w) : Lemma
  (requires (let hash_orig = make_hash h0 h1 in
             make_hash src1 src2 == 
             Spec.Loops.repeat_range 0 64 (shuffle_core_opaque block) hash_orig /\
             src1' == add_wrap_quad32 src1 h0 /\
             src2' == add_wrap_quad32 src2 h1))
  (ensures (let hash_orig = make_hash h0 h1 in
            make_hash src1' src2' == update_block hash_orig block))
  =
  let hash_orig = make_hash h0 h1 in
  let hash_1 = shuffle_opaque SHA2_256 hash_orig block in
  Pervasives.reveal_opaque (`%shuffle) shuffle;
  Pervasives.reveal_opaque (`%shuffle_core) shuffle_core;
  let h = make_hash src1 src2 in
  assert (forall (block:block_w) (hash:hash256) . FStar.FunctionalExtensionality.feq (shuffle_core_opaque block hash) (shuffle_core_opaque_aux SHA2_256 block hash));
  //assert (forall (block:block_w) . (shuffle_core_opaque block) == (shuffle_core_opaque_aux SHA2_256 block));
  admit();
  assert (shuffle_core_opaque == shuffle_core_opaque_aux SHA2_256);
  assert (shuffle_core_opaque == shuffle_core SHA2_256);
  assert (shuffle_core_opaque block == shuffle_core SHA2_256 block);
  assert (Spec.Loops.repeat_range 0 64 (shuffle_core_opaque block) hash_orig ==
          Spec.Loops.repeat_range 0 64 (shuffle_core SHA2_256 block) hash_orig);
  assert (make_hash src1 src2 == shuffle SHA2_256 hash_orig block); 
  assert (make_hash src1 src2 == shuffle_opaque SHA2_256 hash_orig block);
  translate_hash_update src1 src2 src1' src2' h0 h1;
  assert (equal (make_hash src1' src2') (update_block hash_orig block));
  ()


let lemma_le_bytes_to_seq_quad32_empty (b:seq nat8) : Lemma 
  (requires b == empty) 
  (ensures le_bytes_to_seq_quad32 b == empty)
  =
  FStar.Pervasives.reveal_opaque (`%le_bytes_to_seq_quad32) le_bytes_to_seq_quad32;
  assert (equal (le_bytes_to_seq_quad32 b) empty)

let lemma_le_bytes_to_seq_quad32_length (b:seq nat8) : Lemma 
  (requires length b % 16 == 0)
  (ensures length (le_bytes_to_seq_quad32 b) == length b / 16)
  =
  FStar.Pervasives.reveal_opaque (`%le_bytes_to_seq_quad32) le_bytes_to_seq_quad32;
  ()

#push-options "--max_fuel 1" // Without this, F* refuses to do even one unfolding of recursive functions :(
let lemma_slice_commutes_reverse_bytes_quad32_seq (s:seq quad32) (pivot:nat) : Lemma
  (requires pivot <= length s)
  (ensures  slice (reverse_bytes_quad32_seq s) 0 pivot == reverse_bytes_quad32_seq (slice s 0 pivot))
  =
  let rs = reverse_bytes_quad32_seq s in
  let srs = slice (reverse_bytes_quad32_seq s) 0 pivot in
  let ss = slice s 0 pivot in
  let rss = reverse_bytes_quad32_seq ss in
  if pivot = 0 then (
    assert (equal ss empty);
    assert (equal srs empty);
    assert (equal empty (reverse_bytes_quad32_seq empty));
    ()
  ) else (
    assert (equal srs rss)
  )

// One level of expansion that we can use in places that can't use fuel
let lemma_update_multi_quads_unfold (s:seq quad32) (hash_orig:hash256) : Lemma
  (requires length s >= 4)
  (ensures  (let prefix, qs = split s (length s - 4) in
             let h_prefix = update_multi_quads prefix hash_orig in
             let hash = update_block h_prefix (quads_to_block qs) in
             update_multi_quads s hash_orig == hash))
  =
  ()

let lemma_update_multi_quads_short (s:seq quad32) (hash_orig:hash256) : Lemma 
  (requires length s < 4)
  (ensures  update_multi_quads s hash_orig == hash_orig)
  =
  ()

let update_multi_one (h:hash256) (b:bytes_blocks {length b = block_length}) : Lemma
  (ensures (update_multi SHA2_256 h b == update SHA2_256 h b)) =
  let block, rem = Seq.split b (block_length) in
  assert (Seq.length rem == 0);
  update_multi_zero SHA2_256 (update SHA2_256 h b)

#pop-options

(*+ TODO +*)
let lemma_endian_relation (quads qs:seq quad32) (input2:seq UInt8.t) : Lemma
  (requires length qs == 4 /\ length input2 == 64 /\
            qs == reverse_bytes_quad32_seq quads /\
            input2 == seq_nat8_to_seq_uint8 (le_seq_quad32_to_bytes quads))
  (ensures  quads_to_block qs == words_of_bytes SHA2_256 block_word_length input2)
  =
  // calc {
  //   quads_to_block (reverse_bytes_quad32_seq quads)
  //   seq_nat32_to_seq_U32 (seq_four_to_seq_LE (reverse_bytes_quad32_seq quads))
//reveal_reverse_bytes_quad32 quads;
  //   seq_nat32_to_seq_U32 (seq_four_to_seq_LE (four_reverse (four_map reverse_bytes_nat32 q)))
  reveal_opaque reverse_bytes_nat32_def;
  //   seq_nat32_to_seq_U32 (seq_four_to_seq_LE (four_reverse (four_map (fun n -> be_bytes_to_nat32 (reverse_seq (nat32_to_be_bytes n))) q)))

  //   words_of_bytes SHA2_256 16 (seq_nat8_to_seq_U8 (seq_nat32_to_seq_nat8_LE (seq_four_to_seq_LE b)))
  reveal_opaque le_seq_quad32_to_bytes_def;
  //   words_of_bytes SHA2_256 16 (seq_nat8_to_seq_U8 (le_seq_quad32_to_bytes quads))
  //   words_of_bytes SHA2_256 size__w (seq_nat8_to_seq_U8 (le_seq_quad32_to_bytes quads))
  // }
  admit()

let lemma_mod_transform (quads:seq quad32) : Lemma
  (requires length quads % 4 == 0)
  (ensures length (seq_nat8_to_seq_uint8 (le_seq_quad32_to_bytes quads)) % 64 == 0)
  =
  ()

#reset-options "--max_fuel 0 --max_ifuel 0"
let rec lemma_update_multi_equiv_vale (hash hash':hash256) (quads:seq quad32) (r_quads:seq quad32)
  (nat8s:seq nat8) (blocks:seq UInt8.t) :
  Lemma (requires length quads % 4 == 0 /\
                  r_quads == reverse_bytes_quad32_seq quads /\
                  nat8s == le_seq_quad32_to_bytes quads /\
                  blocks == seq_nat8_to_seq_uint8 nat8s /\
                  hash' == update_multi_quads r_quads hash)        
        (ensures 
           length blocks % 64 == 0 /\
           hash' == update_multi_opaque_vale hash blocks)
        (decreases (length quads)) 
  =
  let open FStar.Mul in
  lemma_mod_transform quads;
  assert (length blocks % 64 == 0);
  reveal_opaque update_multi;
  if length quads = 0 then begin
    lemma_le_seq_quad32_to_bytes_length quads;
    //assert (length nat8s == 0);
    //assert (length r_quads == 0);
    lemma_update_multi_quads_short r_quads hash;
    //assert (hash' == hash);
    //assert (length blocks == 0);
    assert (equal blocks empty);
    update_multi_zero SHA2_256 hash;
    //assert (update_multi SHA2_256 hash blocks == hash);
    ()
  end else begin
    let num_blocks = (length quads) / 4 in
    let bytes_pivot = (num_blocks - 1) * 64 in

    // Use associativity of update_multi to rearrange recursion to better match update_multi_quads' recursion
    let input1,input2 = split_block SHA2_256 blocks (bytes_pivot / 64) in

    let h_bytes1 = update_multi SHA2_256 hash input1 in
    let h_bytes2 = update_multi SHA2_256 h_bytes1 input2 in
    update_multi_associative SHA2_256 hash blocks bytes_pivot;
    assert (h_bytes2 == update_multi SHA2_256 hash blocks);
  
    // Unfold update_multi_quads one level, so we can start matching parts up    
    let prefix, qs = split r_quads (length r_quads - 4) in
    let h_prefix = update_multi_quads prefix hash in
    let h_final = update_block h_prefix (quads_to_block qs) in
    lemma_update_multi_quads_unfold r_quads hash;
    // hash' == update_multi_quads r_quads hash == h_final

    (*+ Goal: h_bytes_2 == h_final +*)

    (* Step 1: Show that h_prefix == h_bytes1 *)

    // Inductive hypothesis says that we roughly line up on input1  
    let r_prefix = reverse_bytes_quad32_seq prefix in
    lemma_update_multi_equiv_vale hash h_prefix r_prefix prefix 
                             (le_seq_quad32_to_bytes r_prefix) 
                             (seq_nat8_to_seq_uint8 (le_seq_quad32_to_bytes r_prefix));
    assert (h_prefix == update_multi SHA2_256 hash (seq_nat8_to_seq_uint8 (le_seq_quad32_to_bytes r_prefix)));    
    // To show that h_prefix == h_bytes1, we need to show that:
    // seq_nat8_to_seq_U8 (le_seq_quad32_to_bytes r_prefix) == input1
    // calc {
    //   input1
    //   slice blocks 0 bytes_pivot
    //   slice ( (le_seq_quad32_to_bytes quads)) 0 bytes_pivot
    assert (equal (slice (seq_nat8_to_seq_uint8 (le_seq_quad32_to_bytes quads)) 0 bytes_pivot)
                  (seq_nat8_to_seq_uint8 (slice (le_seq_quad32_to_bytes quads) 0 bytes_pivot)));
    //   seq_nat8_to_seq_U8 (slice (le_seq_quad32_to_bytes quads) 0 bytes_pivot)
    slice_commutes_le_seq_quad32_to_bytes0 quads (bytes_pivot / 16);
    //   seq_nat8_to_seq_U8 (le_seq_quad32_to_bytes (slice quads 0 (bytes_pivot / 16)))
    //   seq_nat8_to_seq_U8 (le_seq_quad32_to_bytes (slice quads 0 ((num_blocks - 1) * 4)))
    assert (bytes_pivot / 16 == length quads - 4);
    //   seq_nat8_to_seq_U8 (le_seq_quad32_to_bytes (slice quads 0 (length quads - 4)))
    //
    //   seq_nat8_to_seq_U8 (le_seq_quad32_to_bytes (slice quads 0 (length quads - 4)))))
    assert (reverse_bytes_quad32_seq (reverse_bytes_quad32_seq (slice quads 0 (length quads - 4))) == slice quads 0 (length quads - 4));
    //   seq_nat8_to_seq_U8 (le_seq_quad32_to_bytes (reverse_bytes_quad32_seq (reverse_bytes_quad32_seq (slice quads 0 (length quads - 4)))))
    Collections.Seqs.slice_seq_map_commute reverse_bytes_quad32 quads 0 (length quads - 4);
    //   seq_nat8_to_seq_U8 (le_seq_quad32_to_bytes (reverse_bytes_quad32_seq (slice (reverse_bytes_quad32_seq quads) 0 (length quads - 4)))
    //   seq_nat8_to_seq_U8 (le_seq_quad32_to_bytes r_prefix)
    // }   
    // assert (seq_nat8_to_seq_U8 (le_seq_quad32_to_bytes r_prefix) == input1); // Conclusion of the calc
    assert (Seq.equal h_prefix h_bytes1);  // Conclusion of Step 1
    // To invoke lemma_endian_relation below, 
    // we need to show (1):
    // calc {
    //   qs
    Collections.Seqs.slice_seq_map_commute reverse_bytes_quad32 quads (length quads - 4) (length quads);
    //   slice (reverse_bytes_quad32_seq quads) (length quads - 4) (length quads))
    //   reverse_bytes_quad32_seq (slice quads (length quads - 4) (length quads))
    // }
    // And (2):
    // calc {
    //   input2
    //   slice blocks bytes_pivot (length blocks)
    //   slice (seq_nat8_to_seq_U8 (le_seq_quad32_to_bytes quads)) bytes_pivot (length blocks)
    // assert (equal (slice (seq_nat8_to_seq_uint8 (le_seq_quad32_to_bytes quads)) bytes_pivot (length blocks))
    //               (seq_nat8_to_seq_uint8 (slice (le_seq_quad32_to_bytes quads)  bytes_pivot (length blocks))));
    //   seq_nat8_to_seq_U8 (slice (le_seq_quad32_to_bytes quads) bytes_pivot (length blocks))
    slice_commutes_le_seq_quad32_to_bytes quads (bytes_pivot/16) ((length blocks)/16);
    //   seq_nat8_to_seq_U8 (le_seq_quad32_to_bytes (slice quads bytes_pivot/16 (length blocks)/16)
    //
    //   seq_nat8_to_seq_U8 (le_seq_quad32_to_bytes (slice quads (length quads - 4) (length quads))))
    // }
    //assert (input2 == seq_nat8_to_seq_U8 (le_seq_quad32_to_bytes (slice quads (length quads - 4) (length quads))));  // Conclusion of the calc

    (* Step 2: Show that update_block SHA2_256 h_prefix (quads_to_block qs) == update_multi SHA2_256 h_bytes1 input2 *) 
    // calc {
    //   update_block SHA2_256 h_prefix (quads_to_block qs)
    //     { from Step 1 }
    //   update_block SHA2_256 h_bytes1 (quads_to_block qs)
    //
    assert (equal input2 (seq_nat8_to_seq_uint8 (le_seq_quad32_to_bytes (slice quads (length quads - 4) (length quads)))));
    lemma_endian_relation (slice quads (length quads - 4) (length quads)) qs 
                          input2;  // ==> quads_to_block qs == words_of_bytes SHA2_256 block_word_length input2
    //   update_block SHA2_256 h_bytes1 (words_of_bytes SHA2_256 16 input2)
    lemma_update_block_equiv h_bytes1 input2;
    //   update SHA2_256 h_bytes1 input2
    update_multi_one h_bytes1 input2;
    //   update_multi SHA2_256 h_bytes1 input2
    // }
    //
    // assert (update_block SHA2_256 h_prefix (quads_to_block qs) == update_multi SHA2_256 h_bytes1 input2); // Conclusion of calc
    // assert (h_final == h_bytes2); // Conclusion of Goal    
    ()    
  end
  
  

  
//
#push-options "--max_fuel 1"  // Without this, F* refuses to do even one unfolding of update_multi_quads :(
let rec lemma_update_multi_quads (s:seq quad32) (hash_orig:hash256) (bound:nat) : Lemma
    (requires bound + 4 <= length s)
    (ensures (let prefix_LE = slice s 0 bound in
              let prefix_BE = reverse_bytes_quad32_seq prefix_LE in
              let h_prefix = update_multi_quads prefix_BE hash_orig in
              let block_quads_LE = slice s bound (bound + 4) in
              let block_quads_BE = reverse_bytes_quad32_seq block_quads_LE in
              let input_LE = slice s 0 (bound+4) in
              let input_BE = reverse_bytes_quad32_seq input_LE in
              let h = update_block h_prefix (quads_to_block block_quads_BE) in
              h == update_multi_quads input_BE hash_orig))
  =
  let prefix_LE = slice s 0 bound in
  let prefix_BE = reverse_bytes_quad32_seq prefix_LE in
  let h_prefix = update_multi_quads prefix_BE hash_orig in
  let block_quads_LE = slice s bound (bound + 4) in
  let block_quads_BE = reverse_bytes_quad32_seq block_quads_LE in
  let input_LE = slice s 0 (bound+4) in
  let input_BE = reverse_bytes_quad32_seq input_LE in
  let h = update_block h_prefix (quads_to_block block_quads_BE) in
  lemma_slice_commutes_reverse_bytes_quad32_seq s bound;
  lemma_slice_commutes_reverse_bytes_quad32_seq s (bound + 4);
  assert (prefix_BE == slice (reverse_bytes_quad32_seq s) 0 bound);
  assert (input_BE == slice (reverse_bytes_quad32_seq s) 0 (bound + 4));
  if bound = 0 then ()
  else (
    let prefix, qs = split input_BE (length input_BE - 4) in
    assert (equal prefix prefix_BE);
    assert (equal qs block_quads_BE);
    ()
  )  
#pop-options  

let lemma_le_bytes_to_hash_quads_part1 (s:seq quad32) : Lemma
  (requires length s == 2)
  (ensures  le_bytes_to_hash (le_seq_quad32_to_bytes s) ==
            Collections.Seqs_s.seq_map nat32_to_word (Words.Seq_s.seq_four_to_seq_LE s))
  =
  let lhs = le_bytes_to_hash (le_seq_quad32_to_bytes s) in  
  assert (lhs == Collections.Seqs_s.seq_map nat32_to_word (Words.Seq_s.seq_nat8_to_seq_nat32_LE (le_seq_quad32_to_bytes s)));
  reveal_opaque le_seq_quad32_to_bytes_def;
  Words.Seq.seq_nat8_to_seq_nat32_to_seq_nat8_LE (Words.Seq_s.seq_four_to_seq_LE s);
  ()

//
#push-options "--z3rlimit 30"
let lemma_le_bytes_to_hash_quads (s:seq quad32) : Lemma
  (requires length s == 2)
  (ensures (let rhs = le_bytes_to_hash (le_seq_quad32_to_bytes s) in
            rhs.[0] == to_uint32 (s.[0]).lo0 /\
            rhs.[1] == to_uint32 (s.[0]).lo1 /\
            rhs.[2] == to_uint32 (s.[0]).hi2 /\
            rhs.[3] == to_uint32 (s.[0]).hi3 /\
            rhs.[4] == to_uint32 (s.[1]).lo0 /\
            rhs.[5] == to_uint32 (s.[1]).lo1 /\
            rhs.[6] == to_uint32 (s.[1]).hi2 /\
            rhs.[7] == to_uint32 (s.[1]).hi3 /\  
            length rhs == 8))
  =
  let rhs = le_bytes_to_hash (le_seq_quad32_to_bytes s) in  
  lemma_le_bytes_to_hash_quads_part1 s;
  assert (rhs == Collections.Seqs_s.seq_map nat32_to_word (Words.Seq_s.seq_four_to_seq_LE s));
  ()
#pop-options

let lemma_hash_to_bytes (s:seq quad32) : Lemma
  (requires length s == 2)
  (ensures make_ordered_hash s.[0] s.[1] == le_bytes_to_hash (le_seq_quad32_to_bytes s))
  =
  lemma_le_bytes_to_hash_quads s;
  assert (equal (make_ordered_hash s.[0] s.[1]) (le_bytes_to_hash (le_seq_quad32_to_bytes s)));
  ()

let lemma_update_multi_opaque_vale_is_update_multi (hash:hash256) (blocks:bytes) : Lemma
  (requires length blocks % 64 = 0)
  (ensures  update_multi_opaque_vale hash blocks == update_multi_transparent hash blocks)
  =
  reveal_opaque update_multi;
  ()
