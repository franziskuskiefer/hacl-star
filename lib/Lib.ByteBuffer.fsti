module Lib.ByteBuffer

open FStar.HyperStack
open FStar.HyperStack.ST
open LowStar.Buffer

open Lib.IntTypes
open Lib.RawIntTypes
open Lib.Buffer

module B = LowStar.Buffer
module BS = Lib.ByteSequence

open FStar.Mul

(** Compares two byte buffers of equal length returning a bool *)
inline_for_extraction
val lbytes_eq:
    #len:size_t
  -> a:lbuffer uint8 (v len)
  -> b:lbuffer uint8 (v len) ->
  Stack bool
    (requires fun h -> B.live h a /\ B.live h b)
    (ensures  fun h0 r h1 ->
      B.modifies B.loc_none h0 h1 /\
      r == BS.lbytes_eq #(v len) (B.as_seq h0 a) (B.as_seq h0 b))

inline_for_extraction
val uint_from_bytes_le:
    #t:inttype{~(t == U1)}
  -> #l:secrecy_level
  -> i:lbuffer uint8 (numbytes t) ->
  Stack (uint_t t l)
    (requires fun h0 -> live h0 i)
    (ensures  fun h0 o h1 ->
      h0 == h1 /\ live h1 i /\
      o == BS.uint_from_bytes_le #t (as_seq h0 i))

inline_for_extraction
val uint_from_bytes_be:
    #t:inttype{~(t == U1)}
  -> #l:secrecy_level
  -> i:lbuffer uint8 (numbytes t) ->
  Stack (uint_t t l)
    (requires fun h0 -> live h0 i)
    (ensures  fun h0 o h1 ->
      h0 == h1 /\ live h1 i /\
      o == BS.uint_from_bytes_be #t (as_seq h0 i))

inline_for_extraction
val uint_to_bytes_le:
    #t:inttype
  -> #l:secrecy_level
  -> o:lbuffer uint8 (numbytes t)
  -> i:uint_t t l ->
  Stack unit
    (requires fun h0 -> live h0 o)
    (ensures  fun h0 _ h1 ->
      live h1 o /\ modifies (loc_buffer o) h0 h1 /\
      as_seq h1 o == BS.uint_to_bytes_le #t i)

inline_for_extraction
val uint_to_bytes_be:
    #t:inttype
  -> #l:secrecy_level
  -> o:lbuffer uint8 (numbytes t)
  -> i:uint_t t l ->
  Stack unit
    (requires fun h0 -> live h0 o)
    (ensures  fun h0 _ h1 ->
      live h1 o /\ modifies (loc_buffer o) h0 h1 /\
      as_seq h1 o == BS.uint_to_bytes_be #t i)

inline_for_extraction
val uints_from_bytes_le:
    #t:inttype{~(t == U1)}
  -> #l:secrecy_level
  -> #len:size_nat{len * numbytes t <= max_size_t}
  -> o:lbuffer (uint_t t l) len
  -> clen:size_t{size_v clen == len}
  -> i:lbuffer uint8 (len * numbytes t) ->
  Stack unit
        (requires (fun h0 -> live h0 o /\ live h0 i))
        (ensures (fun h0 _ h1 -> modifies (loc_buffer o) h0 h1 /\
                              as_seq h1 o ==
                              (BS.uints_from_bytes_le #t #l #len (as_seq h0 i) )))

inline_for_extraction
val uints_from_bytes_be:
    #t:inttype{~(t == U1)}
  -> #l:secrecy_level
  -> #len:size_nat{len * numbytes t <= max_size_t}
  -> o:lbuffer (uint_t t l) len
  -> clen:size_t{size_v clen == len}
  -> i:lbuffer uint8 (len * numbytes t) ->
  Stack unit
        (requires (fun h0 -> live h0 o /\ live h0 i))
        (ensures (fun h0 _ h1 -> modifies (loc_buffer o) h0 h1 /\
                              as_seq h1 o ==
                              (BS.uints_from_bytes_be #t #l #len (as_seq h0 i) )))

inline_for_extraction
val uints_to_bytes_le:
    #t:inttype
  -> #l:secrecy_level
  -> #len:size_nat{len * numbytes t <= max_size_t}
  -> o:lbuffer uint8 (len * numbytes t)
  -> clen:size_t{size_v clen == len}
  -> i:lbuffer (uint_t t l) len ->
  Stack unit
        (requires (fun h0 -> live h0 o /\ live h0 i))
        (ensures (fun h0 _ h1 -> modifies (loc_buffer o) h0 h1 /\
                              as_seq h1 o ==
                              (BS.uints_to_bytes_le #t #l #len (as_seq h0 i) )))

inline_for_extraction
val uints_to_bytes_be:
    #t:inttype
  -> #l:secrecy_level
  -> #len:size_nat{len * numbytes t <= max_size_t}
  -> o:lbuffer uint8 (len * numbytes t)
  -> clen:size_t{size_v clen == len}
  -> i:lbuffer (uint_t t l) len ->
  Stack unit
        (requires (fun h0 -> live h0 o /\ live h0 i /\ disjoint o i))
        (ensures (fun h0 _ h1 -> modifies (loc_buffer o) h0 h1 /\
                              as_seq h1 o ==
                              (BS.uints_to_bytes_be #t #l #len (as_seq h0 i) )))

inline_for_extraction
let uint32s_to_bytes_le #len = uints_to_bytes_le #U32 #SEC #len

inline_for_extraction
let uint32s_from_bytes_le #len = uints_from_bytes_le #U32 #SEC #len
