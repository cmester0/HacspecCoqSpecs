(* File automatically generated by Hacspec *)
From Hacspec Require Import Hacspec_Lib MachineIntegers.
From Coq Require Import ZArith.
Import List.ListNotations.
Open Scope Z_scope.
Open Scope bool_scope.

(*Not implemented yet? todo(item)*)

Definition test : int8 :=
  let acc := (@repr WORDSIZE8 0) : int8 in
  let acc := foldi (@repr WORDSIZE8 1) (@repr WORDSIZE8 10) (fun i acc =>
      acc.+i) acc : int8 in
  acc.+(@repr WORDSIZE8 1).