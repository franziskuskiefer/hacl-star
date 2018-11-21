module Spec.Kyber

open Lib.IntTypes
open Lib.RawIntTypes
open Lib.Sequence
open Lib.ByteSequence
open FStar.Mul
open Lib.LoopCombinators

let q = 7681
let n = 256

let field = x:nat{x < q}
let zero : field = 0
let one  : field = 1
let fadd (a:field) (b:field) : field = (a+b) % q
let fsub (a:field) (b:field) : field = (q+a-b) % q
let fmul (a:field) (b:field) : field = (a*b) % q

let rec fexp (e:field) (n:nat) : Tot field (decreases n) =
  if n = 0 then 1
  else if n = 1 then e
  else
    if n % 2 = 0 then (e `fmul` e) `fexp` (n / 2)
    else e `fmul` ((e `fmul` e) `fexp` ((n-1)/2))

let ( ** ) = fmul
let ( ++ ) = fadd
let ( -- ) = fsub
let ( ^^ ) = fexp

let poly = lseq field n
let poly_add (p1:poly) (p2:poly) : poly = map2 fadd p1 p2 (* Do we carry ?*)
let poly_sub (p1:poly) (p2:poly) : poly = map2 fsub p1 p2 (* Do we carry ?*)
let poly_pointwise_mul (p1:poly) (p2:poly) : poly = map2 fmul p1 p2 (* Do we carry ? *)

let omega : field = 3844
let psi   : field = 62
let n_inv : field = 7651
let psi_inv : field = 1115
let omega_inv : field = 6584

let ntt (p:poly) : poly =
  let np = p in
  repeati 256 (fun i np ->
		 np.[i] <- repeati 256 (fun j x -> x ++ ((psi ^^ j) ** p.[j] ** (omega ^^ (i * j)))) 0) np

let inv_ntt (p:poly) : poly =
  let np = p in
  repeati 256 (fun i np ->
		 np.[i] <- n_inv ** (psi_inv ^^ i) ** repeati 256 (fun j x -> x ++ (p.[j] ** (omega_inv ^^ (i * j)))) 0) np

let poly_mul (p1:poly) (p2:poly) : poly =
  inv_ntt (ntt p1 `poly_pointwise_mul` ntt p2)

let poly_scalar_mul (x:field) (p:poly) : poly = map (fun y -> x ** y) p

let poly_shift_reduce (p:poly) : poly =
    let np = repeati #poly 255 (fun i np -> np.[i+1] <- np.[i]) p in
    np.[0] <- zero -- p.[255]

let poly_mul_textbook_old (p1:poly) (p2:poly) : poly =
  let zero_poly : poly = create 256 zero in
  let sum,_ = repeati #(poly & poly) 256 (fun i (sum,np1) ->
		 (poly_add sum (poly_scalar_mul p2.[255-i] np1)),
		 (poly_shift_reduce np1)) (zero_poly,p1) in
  sum

let poly_mul_textbook (p1:poly) (p2:poly) : poly =
  let sum = create 512 zero in
  let sum = repeati #(lseq field 512) 256 (fun i sum ->
		 repeati #(lseq field 512) 256 (fun j sum ->
			 sum.[i+j] <- sum.[i+j] ++ (p1.[i] ** p2.[j])) sum) sum in
  let high = sub sum 256 256 in
  let low = sub sum 0 256 in
  poly_sub low high


let p1 : list field = [
  0x95; 0xcb; 0xde; 0x94; 0x76; 0xe8; 0x90; 0x7d;
  0x7a; 0xad; 0xe4; 0x5c; 0xb4; 0xb8; 0x73; 0xf8;
  0x8b; 0x59; 0x5a; 0x68; 0x79; 0x9f; 0xa1; 0x52;
  0xe6; 0xf8; 0xf7; 0x64; 0x7a; 0xac; 0x79; 0x57;

  0x95; 0xcb; 0xde; 0x94; 0x76; 0xe8; 0x90; 0x7d;
  0x7a; 0xad; 0xe4; 0x5c; 0xb4; 0xb8; 0x73; 0xf8;
  0x8b; 0x59; 0x5a; 0x68; 0x79; 0x9f; 0xa1; 0x52;
  0xe6; 0xf8; 0xf7; 0x64; 0x7a; 0xac; 0x79; 0x57;

  0x95; 0xcb; 0xde; 0x94; 0x76; 0xe8; 0x90; 0x7d;
  0x7a; 0xad; 0xe4; 0x5c; 0xb4; 0xb8; 0x73; 0xf8;
  0x8b; 0x59; 0x5a; 0x68; 0x79; 0x9f; 0xa1; 0x52;
  0xe6; 0xf8; 0xf7; 0x64; 0x7a; 0xac; 0x79; 0x57;

  0x95; 0xcb; 0xde; 0x94; 0x76; 0xe8; 0x90; 0x7d;
  0x7a; 0xad; 0xe4; 0x5c; 0xb4; 0xb8; 0x73; 0xf8;
  0x8b; 0x59; 0x5a; 0x68; 0x79; 0x9f; 0xa1; 0x52;
  0xe6; 0xf8; 0xf7; 0x64; 0x7a; 0xac; 0x79; 0x57;
  0x95; 0xcb; 0xde; 0x94; 0x76; 0xe8; 0x90; 0x7d;
  0x7a; 0xad; 0xe4; 0x5c; 0xb4; 0xb8; 0x73; 0xf8;
  0x8b; 0x59; 0x5a; 0x68; 0x79; 0x9f; 0xa1; 0x52;
  0xe6; 0xf8; 0xf7; 0x64; 0x7a; 0xac; 0x79; 0x57;

  0x95; 0xcb; 0xde; 0x94; 0x76; 0xe8; 0x90; 0x7d;
  0x7a; 0xad; 0xe4; 0x5c; 0xb4; 0xb8; 0x73; 0xf8;
  0x8b; 0x59; 0x5a; 0x68; 0x79; 0x9f; 0xa1; 0x52;
  0xe6; 0xf8; 0xf7; 0x64; 0x7a; 0xac; 0x79; 0x57;

  0x95; 0xcb; 0xde; 0x94; 0x76; 0xe8; 0x90; 0x7d;
  0x7a; 0xad; 0xe4; 0x5c; 0xb4; 0xb8; 0x73; 0xf8;
  0x8b; 0x59; 0x5a; 0x68; 0x79; 0x9f; 0xa1; 0x52;
  0xe6; 0xf8; 0xf7; 0x64; 0x7a; 0xac; 0x79; 0x57;

  0x95; 0xcb; 0xde; 0x94; 0x76; 0xe8; 0x90; 0x7d;
  0x7a; 0xad; 0xe4; 0x5c; 0xb4; 0xb8; 0x73; 0xf8;
  0x8b; 0x59; 0x5a; 0x68; 0x79; 0x9f; 0xa1; 0x52;
  0xe6; 0xf8; 0xf7; 0x64; 0x7a; 0xac; 0x79; 0x57
 ]


let test () =
  assert_norm(List.Tot.length p1 = 256);
  let test0 = create 256 zero in
  let test0 = test0.[1] <- 1 in
  IO.print_string   "NTT(test0):";
  let result1 = ntt test0 in
  List.iter (fun a -> IO.print_string (UInt32.to_string (u32_to_UInt32 (nat_to_uint #U32 a))); IO.print_string " ; ") (to_list result1);
  IO.print_string   "\nMul with NTT:";
  let result1 = poly_mul test0 test0 in
  List.iter (fun a -> IO.print_string (UInt32.to_string (u32_to_UInt32 (nat_to_uint #U32 a))); IO.print_string " ; ") (to_list result1);
  IO.print_string "\nMul with Textbook:";
  let result2 = poly_mul_textbook test0 test0 in
  List.iter (fun a -> IO.print_string (UInt32.to_string (u32_to_UInt32 (nat_to_uint #U32 a))); IO.print_string " ; ") (to_list result2);

  let test1 = of_list p1 in
  IO.print_string   "\nMul with NTT:";
  let result1 = poly_mul test1 test1 in
  List.iter (fun a -> IO.print_string (UInt32.to_string (u32_to_UInt32 (nat_to_uint #U32 a)))) (to_list result1);
  IO.print_string "\nMul with Textbook:";
  let result2 = poly_mul_textbook test1 test1 in
  List.iter (fun a -> IO.print_string (UInt32.to_string (u32_to_UInt32 (nat_to_uint #U32 a)))) (to_list result2);
  ()
