(* File automatically generated by Hacspec *)
From Hacspec Require Import Hacspec_Lib MachineIntegers.
From Coq Require Import ZArith.
Import List.ListNotations.
Open Scope Z_scope.
Open Scope bool_scope.

(*Not implemented yet? todo(item)*)

From Examples Require Import Hacspec_lib.

Definition BLOCKSIZE : int32 :=
  (@repr WORDSIZE32 16).

Notation Gf128Block_t := (nseq int8 BLOCKSIZE).
Definition Gf128Block : Gf128Block_t -> Gf128Block_t :=
  id.

Notation Gf128Key_t := (nseq int8 BLOCKSIZE).
Definition Gf128Key : Gf128Key_t -> Gf128Key_t :=
  id.

Notation Gf128Tag_t := (nseq int8 BLOCKSIZE).
Definition Gf128Tag : Gf128Tag_t -> Gf128Tag_t :=
  id.

Notation Element_t := (U128_t).

Definition IRRED : U128_t :=
  secret (@repr WORDSIZE128 299076299051606071403356588563077529600).

Definition fadd (x : U128_t) (y : U128_t) : _ :=
  x.^y.

Definition fmul (x : U128_t) (y : U128_t) : U128_t :=
  let res := secret (@repr WORDSIZE128 0) : U128_t in
  let sh := x : U128_t in
  let '(res,sh) := foldi (@repr WORDSIZE32 0) (@repr WORDSIZE32 128) (fun i '(res,sh) =>
      let res := if
          (declassify (y.&(shl (secret (@repr WORDSIZE128 1)) ((@repr WORDSIZE32 127).-i))))<>(declassify (secret (@repr WORDSIZE128 0)))
        then
          res.^sh
        else
          res : _ in
      let sh := if
          (declassify (sh.&(secret (@repr WORDSIZE128 1))))<>(declassify (secret (@repr WORDSIZE128 0)))
        then
          (shr sh (@repr WORDSIZE32 1)).^IRRED
        else
          shr sh (@repr WORDSIZE32 1) : _ in
      (res,sh)) (res,sh) : (_ '× _) in
  res.

Definition encode (block : Gf128Block_t) : U128_t :=
  U128_from_be_bytes (from_seq block).

Definition decode (e : U128_t) : Gf128Block_t :=
  from_seq (U128_to_be_bytes e).

Definition update (r : U128_t) (block : Gf128Block_t) (acc : U128_t) : U128_t :=
  fmul (fadd (encode block) acc) r.

Definition poly (msg : Seq_t U8_t) (r : U128_t) : U128_t :=
  let l := len msg : int32 in
  let n_blocks := l./BLOCKSIZE : int32 in
  let rem := l.%BLOCKSIZE : int32 in
  let acc := secret (@repr WORDSIZE128 0) : U128_t in
  let acc := foldi (@repr WORDSIZE32 0) n_blocks (fun i acc =>
      let k := i.*BLOCKSIZE : int32 in
      let block := new : Gf128Block_t in
      let block := update_start block (slice_range msg (Build_Range_t k(k.+BLOCKSIZE))) : Gf128Block_t in
      update r block acc) acc : U128_t in
  if
    rem<>(@repr WORDSIZE32 0)
  then
    let k := n_blocks.*BLOCKSIZE : int32 in
    let last_block := new : Gf128Block_t in
    let last_block := update_slice last_block (@repr WORDSIZE32 0) msg k rem : Gf128Block_t in
    update r last_block acc
  else
    acc.

Definition gmac (text : Seq_t U8_t) (k : Gf128Key_t) : Gf128Tag_t :=
  let s := new : Gf128Block_t in
  let r := encode (from_seq k) : U128_t in
  let a := poly text r : U128_t in
  from_seq (decode (fadd a (encode s))).
