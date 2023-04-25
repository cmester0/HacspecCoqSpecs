(* File automatically generated by Hacspec *)
From Hacspec Require Import Hacspec_Lib MachineIntegers.
From Coq Require Import ZArith.
Import List.ListNotations.
Open Scope Z_scope.
Open Scope bool_scope.

(*Not implemented yet? todo(item)*)

From Examples Require Import Hacspec_lib.

From Examples Require Import Hacspec_chacha20.

From Examples Require Import Hacspec_poly1305.

Inductive Error_t : Type :=
| InvalidTagError_t.

Notation ChaChaPolyKey_t := (ChaChaKey_t).

Notation ChaChaPolyIV_t := (ChaChaIV_t).

Notation ByteSeqResult_t := (Result_t (Seq_t U8_t) (Error_t)).

Definition init (key : ChaChaKey_t) (iv : ChaChaIV_t) : (FieldElement_t '× FieldElement_t '× PolyKey_t) :=
  let key_block0 := chacha20_key_block0 key iv : Block_t in
  let poly_key := from_slice key_block0 (@repr WORDSIZE32 0) (@repr WORDSIZE32 32) : PolyKey_t in
  poly1305_init poly_key.

Definition poly1305_update_padded (m : Seq_t U8_t) (st : (FieldElement_t '× FieldElement_t '× PolyKey_t)) : (FieldElement_t '× FieldElement_t '× PolyKey_t) :=
  let st := poly1305_update_blocks m st : (FieldElement_t '× FieldElement_t '× PolyKey_t) in
  let last := get_remainder_chunk m (@repr WORDSIZE32 16) : Seq_t U8_t in
  poly1305_update_last (@repr WORDSIZE32 16) last st.

Definition finish (aad_len : int32) (cipher_len : int32) (st : (FieldElement_t '× FieldElement_t '× PolyKey_t)) : Poly1305Tag_t :=
  let last_block := new : PolyBlock_t in
  let last_block := update last_block (@repr WORDSIZE32 0) (U64_to_le_bytes (U64 aad_len)) : PolyBlock_t in
  let last_block := update last_block (@repr WORDSIZE32 8) (U64_to_le_bytes (U64 cipher_len)) : PolyBlock_t in
  let st := poly1305_update_block last_block st : (FieldElement_t '× FieldElement_t '× PolyKey_t) in
  poly1305_finish st.

Definition chacha20_poly1305_encrypt (key : ChaChaKey_t) (iv : ChaChaIV_t) (aad : Seq_t U8_t) (msg : Seq_t U8_t) : (Seq_t U8_t '× Poly1305Tag_t) :=
  let cipher_text := chacha20 key iv (@repr WORDSIZE32 1) msg : Seq_t U8_t in
  let poly_st := init key iv : (FieldElement_t '× FieldElement_t '× PolyKey_t) in
  let poly_st := poly1305_update_padded aad poly_st : (FieldElement_t '× FieldElement_t '× PolyKey_t) in
  let poly_st := poly1305_update_padded cipher_text poly_st : (FieldElement_t '× FieldElement_t '× PolyKey_t) in
  let tag := finish (len aad) (len cipher_text) poly_st : Poly1305Tag_t in
  (cipher_text,tag).

Definition chacha20_poly1305_decrypt (key : ChaChaKey_t) (iv : ChaChaIV_t) (aad : Seq_t U8_t) (cipher_text : Seq_t U8_t) (tag : Poly1305Tag_t) : Result_t (Seq_t U8_t) (Error_t) :=
  let poly_st := init key iv : (FieldElement_t '× FieldElement_t '× PolyKey_t) in
  let poly_st := poly1305_update_padded aad poly_st : (FieldElement_t '× FieldElement_t '× PolyKey_t) in
  let poly_st := poly1305_update_padded cipher_text poly_st : (FieldElement_t '× FieldElement_t '× PolyKey_t) in
  let my_tag := finish (len aad) (len cipher_text) poly_st : Poly1305Tag_t in
  if
    declassify_eq my_tag tag
  then
    Ok (chacha20 key iv (@repr WORDSIZE32 1) cipher_text)
  else
    Err InvalidTagError_t.
