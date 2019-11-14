module Vale.Stdcalls.X64.Fsub
open FStar.Mul

#reset-options "--z3rlimit 50"
let z3rlimit_hack x = ()

(* And here's the fsub wrapper itself *)
let lowstar_fsub : lowstar_fsub_t  =
  assert_norm (List.length dom + List.length ([]<:list arg) <= 4);
  IX64.wrap_weak_stdcall
    code_fsub
    dom
    (W.mk_prediction code_fsub dom [] (fsub_lemma code_fsub IA.win))

let fsub_ //: normal lowstar_fsub_t
  = as_normal_t #lowstar_fsub_t lowstar_fsub
