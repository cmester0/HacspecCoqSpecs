(* File automatically generated by Hacspec *)
From Hacspec Require Import Hacspec_Lib MachineIntegers.
From Coq Require Import ZArith.
Import List.ListNotations.
Open Scope Z_scope.
Open Scope bool_scope.

(*Not implemented yet? todo(item)*)

From Examples Require Import Hacspec_lib.

Definition ROUNDS : int32 :=
  (@repr WORDSIZE32 24).

Definition SHA3224_RATE : int32 :=
  (@repr WORDSIZE32 144).

Definition SHA3256_RATE : int32 :=
  (@repr WORDSIZE32 136).

Definition SHA3384_RATE : int32 :=
  (@repr WORDSIZE32 104).

Definition SHA3512_RATE : int32 :=
  (@repr WORDSIZE32 72).

Definition SHAKE128_RATE : int32 :=
  (@repr WORDSIZE32 168).

Definition SHAKE256_RATE : int32 :=
  (@repr WORDSIZE32 136).

Notation State_t := (nseq int64 25).
Definition State : State_t -> State_t :=
  id.

Notation Row_t := (nseq int64 5).
Definition Row : Row_t -> Row_t :=
  id.

Notation Digest224_t := (nseq int8 28).
Definition Digest224 : Digest224_t -> Digest224_t :=
  id.

Notation Digest256_t := (nseq int8 32).
Definition Digest256 : Digest256_t -> Digest256_t :=
  id.

Notation Digest384_t := (nseq int8 48).
Definition Digest384 : Digest384_t -> Digest384_t :=
  id.

Notation Digest512_t := (nseq int8 64).
Definition Digest512 : Digest512_t -> Digest512_t :=
  id.

Notation RoundConstants_t := (nseq int32 ROUNDS).
Definition RoundConstants : RoundConstants_t -> RoundConstants_t :=
  id.

Notation RotationConstants_t := (nseq int32 25).
Definition RotationConstants : RotationConstants_t -> RotationConstants_t :=
  id.

Definition ROUNDCONSTANTS : RoundConstants_t :=
  RoundConstants (array_from_list _ [(@repr WORDSIZE64 1);(@repr WORDSIZE64 32898);(@repr WORDSIZE64 9223372036854808714);(@repr WORDSIZE64 9223372039002292224);(@repr WORDSIZE64 32907);(@repr WORDSIZE64 2147483649);(@repr WORDSIZE64 9223372039002292353);(@repr WORDSIZE64 9223372036854808585);(@repr WORDSIZE64 138);(@repr WORDSIZE64 136);(@repr WORDSIZE64 2147516425);(@repr WORDSIZE64 2147483658);(@repr WORDSIZE64 2147516555);(@repr WORDSIZE64 9223372036854775947);(@repr WORDSIZE64 9223372036854808713);(@repr WORDSIZE64 9223372036854808579);(@repr WORDSIZE64 9223372036854808578);(@repr WORDSIZE64 9223372036854775936);(@repr WORDSIZE64 32778);(@repr WORDSIZE64 9223372039002259466);(@repr WORDSIZE64 9223372039002292353);(@repr WORDSIZE64 9223372036854808704);(@repr WORDSIZE64 2147483649);(@repr WORDSIZE64 9223372039002292232)]).

Definition ROTC : RotationConstants_t :=
  RotationConstants (array_from_list _ [(@repr WORDSIZE32 0);(@repr WORDSIZE32 1);(@repr WORDSIZE32 62);(@repr WORDSIZE32 28);(@repr WORDSIZE32 27);(@repr WORDSIZE32 36);(@repr WORDSIZE32 44);(@repr WORDSIZE32 6);(@repr WORDSIZE32 55);(@repr WORDSIZE32 20);(@repr WORDSIZE32 3);(@repr WORDSIZE32 10);(@repr WORDSIZE32 43);(@repr WORDSIZE32 25);(@repr WORDSIZE32 39);(@repr WORDSIZE32 41);(@repr WORDSIZE32 45);(@repr WORDSIZE32 15);(@repr WORDSIZE32 21);(@repr WORDSIZE32 8);(@repr WORDSIZE32 18);(@repr WORDSIZE32 2);(@repr WORDSIZE32 61);(@repr WORDSIZE32 56);(@repr WORDSIZE32 14)]).

Definition PI : RotationConstants_t :=
  RotationConstants (array_from_list _ [(@repr WORDSIZE32 0);(@repr WORDSIZE32 6);(@repr WORDSIZE32 12);(@repr WORDSIZE32 18);(@repr WORDSIZE32 24);(@repr WORDSIZE32 3);(@repr WORDSIZE32 9);(@repr WORDSIZE32 10);(@repr WORDSIZE32 16);(@repr WORDSIZE32 22);(@repr WORDSIZE32 1);(@repr WORDSIZE32 7);(@repr WORDSIZE32 13);(@repr WORDSIZE32 19);(@repr WORDSIZE32 20);(@repr WORDSIZE32 4);(@repr WORDSIZE32 5);(@repr WORDSIZE32 11);(@repr WORDSIZE32 17);(@repr WORDSIZE32 23);(@repr WORDSIZE32 2);(@repr WORDSIZE32 8);(@repr WORDSIZE32 14);(@repr WORDSIZE32 15);(@repr WORDSIZE32 21)]).

Definition theta (s : State_t) : State_t :=
  let b := new : Row_t in
  let b := foldi (@repr WORDSIZE32 0) (@repr WORDSIZE32 5) (fun i b =>
      b.[i]<-(((((s.[i]).^(s.[(i.+(@repr WORDSIZE32 5))])).^(s.[(i.+(@repr WORDSIZE32 10))])).^(s.[(i.+(@repr WORDSIZE32 15))])).^(s.[(i.+(@repr WORDSIZE32 20))]))) b : Row_t in
  let s := foldi (@repr WORDSIZE32 0) (@repr WORDSIZE32 5) (fun i s =>
      let u := b.[((i.+(@repr WORDSIZE32 1)).%(@repr WORDSIZE32 5))] : U64_t in
      let t := (b.[((i.+(@repr WORDSIZE32 4)).%(@repr WORDSIZE32 5))]).^(rol u (@repr WORDSIZE32 1)) : U64_t in
      foldi (@repr WORDSIZE32 0) (@repr WORDSIZE32 5) (fun j s =>
        s.[(((@repr WORDSIZE32 5).*j).+i)]<-((s.[(((@repr WORDSIZE32 5).*j).+i)]).^t)) s) s : State_t in
  s.

Definition rho (s : State_t) : State_t :=
  let s := foldi (@repr WORDSIZE32 0) (@repr WORDSIZE32 25) (fun i s =>
      let u := s.[i] : U64_t in
      s.[i]<-(rol u (ROTC.[i]))) s : State_t in
  s.

Definition pi (s : State_t) : State_t :=
  let v := new : State_t in
  foldi (@repr WORDSIZE32 0) (@repr WORDSIZE32 25) (fun i v =>
    v.[i]<-(s.[(PI.[i])])) v.

Definition chi (s : State_t) : State_t :=
  let b := new : Row_t in
  let '(b,s) := foldi (@repr WORDSIZE32 0) (@repr WORDSIZE32 5) (fun i '(b,s) =>
      let b := foldi (@repr WORDSIZE32 0) (@repr WORDSIZE32 5) (fun j b =>
          b.[j]<-(s.[(((@repr WORDSIZE32 5).*i).+j)])) b : Row_t in
      let s := foldi (@repr WORDSIZE32 0) (@repr WORDSIZE32 5) (fun j s =>
          let u := b.[((j.+(@repr WORDSIZE32 1)).%(@repr WORDSIZE32 5))] : U64_t in
          s.[(((@repr WORDSIZE32 5).*i).+j)]<-((s.[(((@repr WORDSIZE32 5).*i).+j)]).^((not u).&(b.[((j.+(@repr WORDSIZE32 2)).%(@repr WORDSIZE32 5))])))) s : State_t in
      (b,s)) (b,s) : (Row_t '× State_t) in
  s.

Definition iota (s : State_t) (rndconst : int64) : State_t :=
  let s := s.[(@repr WORDSIZE32 0)]<-((s.[(@repr WORDSIZE32 0)]).^(classify rndconst)) : State_t in
  s.

Definition keccakf1600 (s : State_t) : State_t :=
  let s := foldi (@repr WORDSIZE32 0) ROUNDS (fun i s =>
      let s := theta s : State_t in
      let s := rho s : State_t in
      let s := pi s : State_t in
      let s := chi s : State_t in
      iota s (ROUNDCONSTANTS.[i])) s : State_t in
  s.

Definition absorb_block (s : State_t) (block : Seq_t U8_t) : State_t :=
  let s := foldi (@repr WORDSIZE32 0) (len block) (fun i s =>
      let w := i shift_right (@repr WORDSIZE32 3) : int32 in
      let o := (@repr WORDSIZE32 8).*(i.&(@repr WORDSIZE32 7)) : int32 in
      s.[w]<-((s.[w]).^(shl (U64_from_U8 (block.[i])) o))) s : State_t in
  keccakf1600 s.

Definition squeeze (s : State_t) (nbytes : int32) (rate : int32) : Seq_t U8_t :=
  let out := new_seq nbytes : Seq_t U8_t in
  app global vcar projector tuple todo(term).

Definition keccak (rate : int32) (data : Seq_t U8_t) (p : int8) (outbytes : int32) : Seq_t U8_t :=
  let buf := new_seq rate : Seq_t U8_t in
  let last_block_len := (@repr WORDSIZE32 0) : int32 in
  let s := new : State_t in
  let '(buf,last_block_len,s) := foldi (@repr WORDSIZE32 0) (num_chunks data rate) (fun i '(buf,last_block_len,s) =>
      let '(block_len,block) := get_chunk data rate i : (int32 '× Seq_t U8_t) in
      if
        block_len=.?rate
      then
        let s := absorb_block s block : State_t in
        (buf,last_block_len,s)
      else
        let buf := update_start buf block : Seq_t U8_t in
        let last_block_len := block_len : int32 in
        (buf,last_block_len,s)) (buf,last_block_len,s) : (Seq_t U8_t '× int32 '× State_t) in
  let buf := buf.[last_block_len]<-(secret p) : Seq_t U8_t in
  let buf := buf.[(rate.-(@repr WORDSIZE32 1))]<-((buf.[(rate.-(@repr WORDSIZE32 1))]).|(secret (@repr WORDSIZE8 128))) : Seq_t U8_t in
  let s := absorb_block s buf : State_t in
  squeeze s outbytes rate.

Definition sha3224 (data : Seq_t U8_t) : Digest224_t :=
  let t := keccak SHA3224_RATE data (@repr WORDSIZE8 6) (@repr WORDSIZE32 28) : Seq_t U8_t in
  from_seq t.

Definition sha3256 (data : Seq_t U8_t) : Digest256_t :=
  let t := keccak SHA3256_RATE data (@repr WORDSIZE8 6) (@repr WORDSIZE32 32) : Seq_t U8_t in
  from_seq t.

Definition sha3384 (data : Seq_t U8_t) : Digest384_t :=
  let t := keccak SHA3384_RATE data (@repr WORDSIZE8 6) (@repr WORDSIZE32 48) : Seq_t U8_t in
  from_seq t.

Definition sha3512 (data : Seq_t U8_t) : Digest512_t :=
  let t := keccak SHA3512_RATE data (@repr WORDSIZE8 6) (@repr WORDSIZE32 64) : Seq_t U8_t in
  from_seq t.

Definition shake128 (data : Seq_t U8_t) (outlen : int32) : Seq_t U8_t :=
  keccak SHAKE128_RATE data (@repr WORDSIZE8 31) outlen.

Definition shake256 (data : Seq_t U8_t) (outlen : int32) : Seq_t U8_t :=
  keccak SHAKE256_RATE data (@repr WORDSIZE8 31) outlen.