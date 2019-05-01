module Lib.Sequence

open FStar.Mul
open Lib.IntTypes

#set-options "--z3rlimit 15"

/// Variable length Sequences, derived from FStar.Seq

(* This is the type of unbounded sequences.
   Use this only when dealing with, say, user input whose length is unbounded.
   As far as possible use the API for bounded sequences defined later in this file.*)

(** Definition of a Sequence *)
let seq (a:Type0) = Seq.seq a

(** Length of a Sequence *)
let length (#a:Type0) (s:seq a) : nat = Seq.length s

/// Fixed length Sequences

(* This is the type of bounded sequences.
   Use this as much as possible.
   It adds additional length checks that you'd have to prove in the implementation otherwise *)

(** Definition of a fixed-length Sequence *)
let lseq (a:Type0) (len:size_nat) = s:seq a{Seq.length s == len}
let to_seq (#a:Type0) (#len:size_nat) (l:lseq a len) : seq a = l
let to_lseq (#a:Type0) (s:seq a{length s <= max_size_t}) : l:lseq a (length s){l == s} = s

(* If you want to prove your code with an abstract lseq use the following: *)
// val lseq: a:Type0 -> len:size_nat -> Type0
// val to_seq: #a:Type0 -> #len:size_nat -> lseq a len -> s:seq a{length s == len}
// val to_lseq: #a:Type0 -> s:seq a{length s <= max_size_t} -> lseq a (length s)

val index:
    #a:Type
  -> #len:size_nat
  -> s:lseq a len
  -> i:size_nat{i < len} ->
  Tot (r:a{r == Seq.index (to_seq s) i})

(** Creation of a fixed-length Sequence from an initial value *)
val create:
    #a:Type
  -> len:size_nat
  -> init:a ->
  Tot (s:lseq a len{to_seq s == Seq.create len init /\ (forall (i:nat).
    {:pattern (index s i)} i < len ==> index s i == init)})


(** Concatenate sequences: use with care, may make implementation hard to verify *)
val concat:
    #a:Type
  -> #len0:size_nat
  -> #len1:size_nat{len0 + len1 <= max_size_t}
  -> s0:lseq a len0
  -> s1:lseq a len1 ->
  Tot (s2:lseq a (len0 + len1){to_seq s2 == Seq.append (to_seq s0) (to_seq s1)})

inline_for_extraction
let ( @| ) #a #len0 #len1 s0 s1 = concat #a #len0 #len1 s0 s1

(** Conversion of a Sequence to a list *)
val to_list:
    #a:Type
  -> s:seq a ->
  Tot (l:list a{List.Tot.length l = length s /\ l == Seq.seq_to_list s})

(** Creation of a fixed-length Sequence from a list of values *)
val of_list:
    #a:Type
  -> l:list a{List.Tot.length l <= max_size_t} ->
  Tot (s:lseq a (List.Tot.length l){to_seq s == Seq.seq_of_list l})

val of_list_index:
    #a:Type
  -> l:list a{List.Tot.length l <= max_size_t}
  -> i:nat{i < List.Tot.length l} ->
  Lemma (index (of_list l) i == List.Tot.index l i)
    [SMTPat (index (of_list l) i)]

abstract
type equal (#a:Type) (#len:size_nat) (s1:lseq a len) (s2:lseq a len) =
  forall (i:size_nat{i < len}).{:pattern (index s1 i); (index s2 i)} index s1 i == index s2 i

val eq_intro: #a:Type -> #len:size_nat -> s1:lseq a len -> s2:lseq a len ->
  Lemma
  (requires forall i. {:pattern index s1 i; index s2 i} index s1 i == index s2 i)
  (ensures equal s1 s2)
  [SMTPat (equal s1 s2)]

val eq_elim: #a:Type -> #len:size_nat -> s1:lseq a len -> s2:lseq a len ->
  Lemma
  (requires equal s1 s2)
  (ensures  s1 == s2)
  [SMTPat (equal s1 s2)]

(* Alias for creation from a list *)
unfold let createL #a l = of_list #a l

(** Updating an element of a fixed-length Sequence *)
val upd:
    #a:Type
  -> #len:size_nat
  -> s:lseq a len
  -> n:size_nat{n < len}
  -> x:a ->
  Tot (o:lseq a len{to_seq o == Seq.upd (to_seq s) n x /\ index o n == x /\ (forall (i:size_nat).
    {:pattern (index s i)} (i < len /\ i <> n) ==> index o i == index s i)})

(** Membership of an element to a fixed-length Sequence *)
val member: #a:eqtype -> #len: size_nat -> a -> lseq a len -> Tot bool

(** Operator for accessing an element of a fixed-length Sequence *)
unfold
let op_String_Access #a #len = index #a #len

(** Operator for updating an element of a fixed-length Sequence *)
unfold
let op_String_Assignment #a #len = upd #a #len

(** Selecting a subset of a fixed-length Sequence *)
val sub:
    #a:Type
  -> #len:size_nat
  -> s1:lseq a len
  -> start:size_nat
  -> n:size_nat{start + n <= len} ->
  Tot (s2:lseq a n{to_seq s2 == Seq.slice (to_seq s1) start (start + n) /\
	     (forall (k:nat{k < n}). {:pattern (index s2 k)} index s2 k == index s1 (start + k))})

(** Selecting a subset of a fixed-length Sequence *)
let slice
    (#a:Type)
    (#len:size_nat)
    (s1:lseq a len)
    (start:nat)
    (fin:nat{start <= fin /\ fin <= len})
  =
  sub #a s1 start (fin - start)

(** Updating a sub-Sequence from another fixed-length Sequence *)
val update_sub:
    #a:Type
  -> #len:size_nat
  -> i:lseq a len
  -> start:size_nat
  -> n:size_nat{start + n <= len}
  -> x:lseq a n ->
  Tot (o:lseq a len{sub o start n == x /\
    (forall (k:nat{(0 <= k /\ k < start) \/ (start + n <= k /\ k < len)}).
      {:pattern (index o k)} index o k == index i k)})

(** Lemma regarding updating a sub-Sequence with another Sequence *)
val lemma_update_sub:
    #a:Type
  -> #len:size_nat
  -> dst:lseq a len
  -> start:size_nat
  -> n:size_nat{start + n <= len}
  -> src:lseq a n
  -> res:lseq a len ->
  Lemma
    (requires
      sub res 0 start == sub dst 0 start /\
      sub res start n == src /\
      sub res (start + n) (len - start - n) ==
      sub dst (start + n) (len - start - n))
    (ensures
      res == update_sub dst start n src)

val lemma_concat2:
    #a:Type0
  -> len0:size_nat
  -> s0:lseq a len0
  -> len1:size_nat{len0 + len1 <= max_size_t}
  -> s1:lseq a len1
  -> s:lseq a (len0 + len1) ->
  Lemma
    (requires
      sub s 0 len0 == s0 /\
      sub s len0 len1 == s1)
    (ensures s == concat s0 s1)

val lemma_concat3:
    #a:Type0
  -> len0:size_nat
  -> s0:lseq a len0
  -> len1:size_nat{len0 + len1 <= max_size_t}
  -> s1:lseq a len1
  -> len2:size_nat{len0 + len1 + len2 <= max_size_t}
  -> s2:lseq a len2
  -> s:lseq a (len0 + len1 + len2) ->
  Lemma
    (requires
      sub s 0 len0 == s0 /\
      sub s len0 len1 == s1 /\
      sub s (len0 + len1) len2 == s2)
    (ensures s == concat (concat s0 s1) s2)

(** Updating a sub-Sequence from another fixed-length Sequence *)
let update_slice
    (#a:Type)
    (#len:size_nat)
    (i:lseq a len)
    (start:size_nat)
    (fin:size_nat{start <= fin /\ fin <= len})
    (upd:lseq a (fin - start))
  =
  update_sub #a i start (fin - start) upd

(** Creation of a fixed-length Sequence from an initialization function *)
val createi: #a:Type
  -> len:size_nat
  -> init:(i:nat{i < len} -> a) ->
  Tot (s:lseq a len{(forall (i:nat).
    {:pattern (index s i)} i < len ==> index s i == init i)})

(** Mapi function for fixed-length Sequences *)
val mapi:#a:Type -> #b:Type -> #len:size_nat
  -> f:(i:nat{i < len} -> a -> Tot b)
  -> s1:lseq a len ->
  Tot (s2:lseq b len{(forall (i:nat).
    {:pattern (index s2 i)} i < len ==> index s2 i == f i s1.[i])})

(** Map function for fixed-length Sequences *)
val map:#a:Type -> #b:Type -> #len:size_nat
  -> f:(a -> Tot b)
  -> s1:lseq a len ->
  Tot (s2:lseq b len{(forall (i:nat).
    {:pattern (index s2 i)} i < len ==> index s2 i == f s1.[i])})

(** Map2i function for fixed-length Sequences *)
val map2i:#a:Type -> #b:Type -> #c:Type -> #len:size_nat
  -> f:(i:nat{i < len} -> a -> b -> Tot c)
  -> s1:lseq a len
  -> s2:lseq b len ->
  Tot (s3:lseq c len{(forall (i:nat).
    {:pattern (index s3 i)} i < len ==> index s3 i == f i s1.[i] s2.[i])})

(** Map2 function for fixed-length Sequences *)
val map2:#a:Type -> #b:Type -> #c:Type -> #len:size_nat
  -> f:(a -> b -> Tot c)
  -> s1:lseq a len
  -> s2:lseq b len ->
  Tot (s3:lseq c len{(forall (i:nat).
    {:pattern (index s3 i)} i < len ==> index s3 i == f s1.[i] s2.[i])})

(** Forall function for fixed-length Sequences *)
val for_all:#a:Type -> #len:size_nat -> (a -> Tot bool) -> lseq a len -> bool

(** Forall2 function for fixed-length Sequences *)
val for_all2:#a:Type -> #b:Type -> #len:size_nat
  -> (a -> b -> Tot bool)
  -> s1:lseq a len
  -> s2:lseq b len ->
  Tot bool

val repeati_blocks:
    #a:Type0
  -> #b:Type0
  -> blocksize:size_nat{blocksize > 0}
  -> inp:seq a
  -> f:(i:nat{i < length inp / blocksize} -> lseq a blocksize -> b -> b)
  -> l:(i:nat{i == length inp / blocksize} -> len:size_nat{len == length inp % blocksize} -> s:lseq a len -> b -> b)
  -> init:b ->
  Tot b

let repeat_blocks_f
  (#a:Type0)
  (#b:Type0)
  (bs:size_nat{bs > 0})
  (inp:seq a)
  (f:(lseq a bs -> b -> b))
  (nb:nat{nb == length inp / bs})
  (i:nat{i < nb})
  (acc:b) : b
 =
  assert ((i+1) * bs <= nb * bs);
  let block = Seq.slice inp (i * bs) (i * bs + bs) in
  f block acc

val repeat_blocks:
    #a:Type0
  -> #b:Type0
  -> blocksize:size_nat{blocksize > 0}
  -> inp:seq a
  -> f:(lseq a blocksize -> b -> b)
  -> l:(len:size_nat{len == length inp % blocksize} -> s:lseq a len -> b -> b)
  -> init:b ->
  Tot b

val lemma_repeat_blocks:
    #a:Type0
  -> #b:Type0
  -> bs:size_nat{bs > 0}
  -> inp:seq a
  -> f:(lseq a bs -> b -> b)
  -> l:(len:size_nat{len == length inp % bs} -> s:lseq a len -> b -> b)
  -> init:b ->
  Lemma (
    let len = length inp in
    let nb = len / bs in
    let rem = len % bs in
    let acc = Lib.LoopCombinators.repeati nb (repeat_blocks_f bs inp f nb) init in
    let last = Seq.slice inp (nb * bs) len in
    let acc = l rem last acc in
    repeat_blocks #a #b bs inp f l init == acc)

val repeat_blocks_multi:
    #a:Type0
  -> #b:Type0
  -> blocksize:size_nat{blocksize > 0}
  -> inp:seq a{length inp % blocksize = 0}
  -> f:(lseq a blocksize -> b -> b)
  -> init:b ->
  Tot b

val lemma_repeat_blocks_multi:
    #a:Type0
  -> #b:Type0
  -> bs:size_nat{bs > 0}
  -> inp:seq a{length inp % bs = 0}
  -> f:(lseq a bs -> b -> b)
  -> init:b ->
  Lemma (
    let len = length inp in
    let nb = len / bs in
    repeat_blocks_multi #a #b bs inp f init ==
    Lib.LoopCombinators.repeati nb (repeat_blocks_f bs inp f nb) init)

(** Generates `n` blocks of length `len` by iteratively applying a function with an accumulator *)
val generate_blocks:
    #t:Type0
  -> len:size_nat
  -> max:nat
  -> n:nat{n <= max}
  -> a:(i:nat{i <= max} -> Type)
  -> f:(i:nat{i < max} -> a i -> a (i + 1) & s:seq t{length s == len})
  -> init:a 0 ->
  Tot (a n & s:seq t{ length s == n * len})


(* The following functions allow us to bridge between unbounded and bounded sequences *)
val map_blocks_multi:
    #a:Type0
  -> blocksize:size_nat{blocksize > 0}
  -> n:nat
  -> inp:seq a{length inp == n * blocksize}
  -> f:(i:nat{i < length inp / blocksize} -> lseq a blocksize -> lseq a blocksize) ->
  Tot (out:seq a {length out == length inp})


(* The following functions allow us to bridge between unbounded and bounded sequences *)
val map_blocks:
    #a:Type0
  -> blocksize:size_nat{blocksize > 0}
  -> inp:seq a
  -> f:(i:nat{i < length inp / blocksize} -> lseq a blocksize -> lseq a blocksize)
  -> g:(i:nat{i == length inp / blocksize} -> len:size_nat{len < blocksize} -> s:lseq a len -> lseq a len) ->
  Tot (out:seq a {length out == length inp})


val eq_generate_blocks0:
    #t:Type0
  -> len:size_nat
  -> n:nat
  -> a:(i:nat{i <= n} -> Type)
  -> f:(i:nat{i < n} -> a i -> a (i + 1) & s:seq t{length s == len})
  -> init:a 0 ->
  Lemma (generate_blocks #t len n 0 a f init ==
	 (init,Seq.empty))


val unfold_generate_blocks:
    #t:Type0
  -> len:size_nat
  -> n:nat
  -> a:(i:nat{i <= n} -> Type)
  -> f:(i:nat{i < n} -> a i -> a (i + 1) & s:seq t{length s == len})
  -> init:a 0
  -> i:nat{i < n} ->
  Lemma (generate_blocks #t len n (i+1) a f init ==
	   (let (acc,s) = generate_blocks #t len n i a f init in
	    let (acc',s') = f i acc in
	    (acc',Seq.append s s')))



(*
#set-options "--z3rlimit 400 --max_ifuel 1"

val map_blocks_multi_lemma:
    #a:Type0
  -> blocksize:size_nat{blocksize > 0}
  -> n:size_nat
  -> inp:seq a{length inp == n * blocksize}
  -> f:(i:nat{i < length inp / blocksize} -> lseq a blocksize -> lseq a blocksize)
  -> j:nat{j < length inp} ->
  Lemma (
    Seq.index (map_blocks_multi blocksize n inp f) j ==
    Seq.index (f (j/blocksize) (Seq.slice inp ((j/blocksize) * blocksize) ((j/blocksize+1)*blocksize))) (j % blocksize))
    [SMTPat (Seq.index (map_blocks_multi #a blocksize n inp f) j)]

val map_blocks_lemma:
    #a:Type0
  -> blocksize:size_nat{blocksize > 0}
  -> inp:seq a{length inp % blocksize == 0}
  -> f:(i:nat{i < length inp / blocksize} -> lseq a blocksize -> lseq a blocksize)
  -> g:(i:nat{i == length inp / blocksize} -> len:size_nat{len < blocksize} -> s:lseq a len -> lseq a len)
  -> i:nat{i < length inp} ->
  Lemma (
    let blocks = length inp / blocksize in
    let rem = length inp % blocksize in
    (if i < blocksize * blocks then
      Seq.index (map_blocks blocksize inp f g) i ==
      Seq.index (f (i/blocksize) (Seq.slice inp ((i/blocksize) * blocksize) ((i/blocksize+1)*blocksize))) (i % blocksize)
     else
      Seq.index (map_blocks blocksize inp f g) i ==
      Seq.index (g blocks rem (Seq.slice inp (blocks * blocksize) (length inp))) (i % blocksize)))
    [SMTPat (Seq.index (map_blocks #a blocksize inp f g) i)]
*)

val map_blocks_n_fits_lemma:
    len:nat ->
    blocksize:nat ->
    n:nat{n * blocksize > 0} ->
    i:nat{i < len / (n * blocksize)} ->
    j:nat{j < n} ->
    Lemma (n * i + j < len / blocksize)
	  [SMTPat (n * i + j < len / blocksize)]

(*
val map_blocks_n_lemma:
    #a:Type0
  -> blocksize:size_nat{blocksize > 0}
  -> n:size_nat{n * blocksize <= max_size_t /\ n * blocksize > 0}
  -> inp:seq a
  -> f:(i:nat{i < length inp / blocksize} -> lseq a blocksize -> lseq a blocksize)
  -> g:(i:nat{i == length inp / blocksize} -> len:size_nat{len < blocksize} -> s:lseq a len -> lseq a len) ->
  Lemma (
	map_blocks #a blocksize inp f g ==
	map_blocks #a (n * blocksize) inp
	  (fun i nb ->
	    map_blocks_multi #a blocksize n nb
	      (fun j b -> f (n * i + j) b))
	  (fun i len l ->
	    map_blocks #a blocksize l
	      (fun j b -> f (n * i + j) b)
	      (fun j l b -> g (n * i + j) l b)))


val repeat_blocks_n_fits_lemma:
    blocksize:size_nat{blocksize > 0}
  -> n:size_nat{n > 0 /\ n*blocksize <= max_size_t}
  -> len:nat ->
    Lemma ((len % (n * blocksize)) % blocksize == len % blocksize)
    [SMTPat (len % (n * blocksize) % blocksize)]

val repeat_blocks_n_lemma:
    #a:Type0
  -> #b:Type0
  -> blocksize:size_nat{blocksize > 0}
  -> n:size_nat{n > 0 /\ n*blocksize <= max_size_t}
  -> inp:seq a
  -> f:(lseq a blocksize -> b -> b)
  -> l:(len:size_nat{len == length inp % blocksize} -> s:lseq a len -> b -> b)
  -> init:b ->
  Lemma (repeat_blocks blocksize inp f l init ==
	 repeat_blocks (n * blocksize) inp
	   (fun bl a ->
	     repeat_blocks blocksize bl f (fun len bl a -> a) a)
	   (fun len bl a ->
	     repeat_blocks blocksize bl f l a) init)


val generate_blocks1_lemma:
    #t:Type0
  -> len:size_nat
  -> a:(i:nat{i <= 1} -> Type)
  -> f:(i:nat{i < 1} -> a i -> a (i + 1) & s:seq t{length s == len})
  -> init:a 0 ->
  Lemma (ensures (let (a,s) = generate_blocks #t len 1 a f init in
		  (a,s) == f 0 init))

val map_blocks_multi1_lemma:
    #a:Type0
  -> blocksize:size_nat{blocksize > 0}
  -> inp:seq a{length inp == blocksize}
  -> f:(i:nat{i < length inp / blocksize} -> lseq a blocksize -> lseq a blocksize) ->
  Lemma (ensures (map_blocks_multi blocksize 1 inp f ==
		  f 0 inp))

*)
