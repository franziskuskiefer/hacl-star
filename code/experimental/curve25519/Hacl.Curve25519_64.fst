module Hacl.Curve25519_64
open FStar.HyperStack
open FStar.HyperStack.All
open Lib.IntTypes
open Lib.Buffer
open Hacl.Impl.Curve25519.Fields
open Hacl.Impl.Curve25519.Generic

val secret_to_public: 
      pub:lbuffer uint8 32ul 
    -> priv:lbuffer uint8 32ul ->
    Stack unit
    (requires (fun h0 -> live h0 pub /\ live h0 priv))
    (ensures (fun h0 _ h1 -> modifies (loc pub) h0 h1))

let secret_to_public pub priv = 
    secret_to_public #M64 pub priv


val ecdh: 
      shared:lbuffer uint8 32ul 
    -> my_priv:lbuffer uint8 32ul 
    -> their_pub:lbuffer uint8 32ul -> 
    Stack unit
    (requires (fun h0 -> live h0 shared /\ live h0 my_priv /\ live h0 their_pub))
    (ensures (fun h0 _ h1 -> modifies (loc shared) h0 h1))
let ecdh shared my_priv their_pub = 
    scalarmult #M64 shared my_priv their_pub

