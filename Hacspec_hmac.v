(* File automatically generated by Hacspec *)
From Hacspec Require Import Hacspec_Lib MachineIntegers.
From Coq Require Import ZArith.
Import List.ListNotations.
Open Scope Z_scope.
Open Scope bool_scope.

(*Not implemented yet? todo(item)*)

From Examples Require Import Hacspec_lib.

From Examples Require Import Hacspec_sha256.

Definition BLOCK_LEN : int32 :=
  K_SIZE.

Notation PRK_t := (nseq int8 HASH_SIZE).
Definition PRK : PRK_t -> PRK_t :=
  id.

Notation Block_t := (nseq int8 BLOCK_LEN).
Definition Block : Block_t -> Block_t :=
  id.

Definition I_PAD : Block_t :=
  Block (array_from_list _ [0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36;0x36]).

Definition O_PAD : Block_t :=
  Block (array_from_list _ [0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c;0x5c]).

Definition k_block (k : Seq_t U8_t) : Block_t :=
  if
    (len k)>.?BLOCK_LEN
  then
    update_start new (hash k)
  else
    update_start new k.

Definition hmac (k : Seq_t U8_t) (txt : Seq_t U8_t) : PRK_t :=
  let k_block := k_block k : Block_t in
  let h_in := from_seq (k_block.^I_PAD) : Seq_t U8_t in
  let h_in := concat h_in txt : Seq_t U8_t in
  let h_inner := hash h_in : Sha256Digest_t in
  let h_in := from_seq (k_block.^O_PAD) : Seq_t U8_t in
  let h_in := concat h_in h_inner : Seq_t U8_t in
  from_seq (hash h_in).