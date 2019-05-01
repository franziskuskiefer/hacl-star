module Hacl.Impl.Chacha20Poly1305.PolyCore

module ST = FStar.HyperStack.ST
open FStar.HyperStack
open FStar.HyperStack.All
open FStar.Mul

open Lib.IntTypes
open Lib.Buffer
open Lib.ByteBuffer

module LSeq = Lib.Sequence

module SpecPoly = Spec.Poly1305
module Spec = Spec.Chacha20Poly1305
module Poly = Hacl.Impl.Poly1305
open Hacl.Impl.Poly1305.Fields

val poly1305_padded:
  ctx:Poly.poly1305_ctx M32 ->
  len:size_t ->
  text:lbuffer uint8 len ->
  tmp:lbuffer uint8 16ul ->
  Stack unit
    (requires fun h -> live h ctx /\ live h text /\ live h tmp /\
      disjoint ctx text /\ disjoint ctx tmp /\ disjoint text tmp /\
      Poly.state_inv_t h ctx)
    (ensures fun h0 _ h1 ->
      modifies (loc tmp |+| loc ctx) h0 h1 /\
      Poly.state_inv_t h1 ctx /\
      // Additional framing for r_elem
      Poly.as_get_r h0 ctx == Poly.as_get_r h1 ctx /\
      // Functional spec
      Poly.as_get_acc h1 ctx ==
      Spec.poly1305_padded
        (Poly.as_get_r h0 ctx)
        (v len)
        (as_seq h0 text)
        (as_seq h0 tmp)
        (Poly.as_get_acc h0 ctx)
        )

val poly1305_init:
  ctx:Poly.poly1305_ctx M32 ->
  k:lbuffer uint8 32ul ->
  Stack unit
    (requires fun h -> live h ctx /\ live h k /\ disjoint ctx k)
    (ensures fun h0 _ h1 -> modifies (loc ctx) h0 h1 /\
      Poly.state_inv_t h1 ctx /\
      (let acc, r = SpecPoly.poly1305_init (as_seq h0 k) in
      acc == Poly.as_get_acc h1 ctx /\
      r == Poly.as_get_r h1 ctx))

val update1:
  ctx:Poly.poly1305_ctx M32 ->
  len:size_t{0 < v len /\ v len <= 16} ->
  text:lbuffer uint8 len ->
  Stack unit
    (requires fun h -> live h ctx /\ live h text /\ disjoint ctx text /\
      Poly.state_inv_t h ctx)
    (ensures fun h0 _ h1 ->
      modifies (loc ctx) h0 h1 /\
      Poly.state_inv_t h1 ctx /\
      // Additional framing for r_elem
      Poly.as_get_r h0 ctx == Poly.as_get_r h1 ctx /\
      // Functional spec
      Poly.as_get_acc h1 ctx ==
      SpecPoly.update1
        (Poly.as_get_r h0 ctx)
        (v len)
        (as_seq h0 text)
        (Poly.as_get_acc h0 ctx))

val finish:
  ctx:Poly.poly1305_ctx M32 ->
  k:lbuffer uint8 32ul -> // key
  out:lbuffer uint8 16ul -> // output: tag
  Stack unit
    (requires fun h -> live h ctx /\ live h k /\ live h out /\
      disjoint out k /\ disjoint out ctx /\ disjoint k ctx /\
      Poly.state_inv_t h ctx)
    (ensures fun h0 _ h1 -> modifies (loc out |+| loc ctx) h0 h1 /\
      as_seq h1 out == SpecPoly.finish (as_seq h0 k) (Poly.as_get_acc h0 ctx))
