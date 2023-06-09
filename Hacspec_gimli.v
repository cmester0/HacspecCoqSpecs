(* File automatically generated by Hacspec *)
From Hacspec Require Import Hacspec_Lib MachineIntegers.
From Coq Require Import ZArith.
Import List.ListNotations.
Open Scope Z_scope.
Open Scope bool_scope.

(*Not implemented yet? todo(item)*)

From Examples Require Import Hacspec_lib.

Notation State_t := (nseq int32 12).
Definition State : State_t -> State_t :=
  id.

Definition swap (s : State_t) (i : int32) (j : int32) : State_t :=
  let tmp := s.[i] : U32_t in
  let s := s.[i]<-(s.[j]) : State_t in
  let s := s.[j]<-tmp : State_t in
  s.

Definition gimli_round (s : State_t) (r : int32) : State_t :=
  let s := foldi (@repr WORDSIZE32 0) (@repr WORDSIZE32 4) (fun col s =>
      let x := rol (s.[col]) (@repr WORDSIZE32 24) : U32_t in
      let y := rol (s.[(col.+(@repr WORDSIZE32 4))]) (@repr WORDSIZE32 9) : U32_t in
      let z := s.[(col.+(@repr WORDSIZE32 8))] : U32_t in
      let s := s.[(col.+(@repr WORDSIZE32 8))]<-((x.^(shl z (@repr WORDSIZE32 1))).^(shl (y.&z) (@repr WORDSIZE32 2))) : State_t in
      let s := s.[(col.+(@repr WORDSIZE32 4))]<-((y.^x).^(shl (x.|z) (@repr WORDSIZE32 1))) : State_t in
      s.[col]<-((z.^y).^(shl (x.&y) (@repr WORDSIZE32 3)))) s : State_t in
  let s := if
      (r.&(@repr WORDSIZE32 3))=.?(@repr WORDSIZE32 0)
    then
      let s := swap s (@repr WORDSIZE32 0) (@repr WORDSIZE32 1) : State_t in
      swap s (@repr WORDSIZE32 2) (@repr WORDSIZE32 3)
    else
      s : State_t in
  let s := if
      (r.&(@repr WORDSIZE32 3))=.?(@repr WORDSIZE32 2)
    then
      let s := swap s (@repr WORDSIZE32 0) (@repr WORDSIZE32 2) : State_t in
      swap s (@repr WORDSIZE32 1) (@repr WORDSIZE32 3)
    else
      s : State_t in
  let s := if
      (r.&(@repr WORDSIZE32 3))=.?(@repr WORDSIZE32 0)
    then
      s.[(@repr WORDSIZE32 0)]<-((s.[(@repr WORDSIZE32 0)]).^((secret (@repr WORDSIZE32 2654435584)).|(secret r)))
    else
      s : _ in
  s.

Definition gimli (s : State_t) : State_t :=
  let s := foldi (@repr WORDSIZE32 0) (@repr WORDSIZE32 24) (fun rnd s =>
      let rnd := (@repr WORDSIZE32 24).-rnd : int32 in
      gimli_round s rnd) s : State_t in
  s.

Notation Block_t := (nseq int8 16).
Definition Block : Block_t -> Block_t :=
  id.

Notation Digest_t := (nseq int8 32).
Definition Digest : Digest_t -> Digest_t :=
  id.

Definition absorb_block (input_block : Block_t) (s : State_t) : State_t :=
  let input_bytes := to_le_U32s input_block : Seq_t U32_t in
  let s := s.[(@repr WORDSIZE32 0)]<-((s.[(@repr WORDSIZE32 0)]).^(input_bytes.[(@repr WORDSIZE32 0)])) : State_t in
  let s := s.[(@repr WORDSIZE32 1)]<-((s.[(@repr WORDSIZE32 1)]).^(input_bytes.[(@repr WORDSIZE32 1)])) : State_t in
  let s := s.[(@repr WORDSIZE32 2)]<-((s.[(@repr WORDSIZE32 2)]).^(input_bytes.[(@repr WORDSIZE32 2)])) : State_t in
  let s := s.[(@repr WORDSIZE32 3)]<-((s.[(@repr WORDSIZE32 3)]).^(input_bytes.[(@repr WORDSIZE32 3)])) : State_t in
  gimli s.

Definition squeeze_block (s : State_t) : Block_t :=
  let block := new : Block_t in
  foldi (@repr WORDSIZE32 0) (@repr WORDSIZE32 4) (fun i block =>
    let s_i := s.[i] : U32_t in
    let s_i_bytes := to_le_bytes s_i : Seq_t U8_t in
    let block := block.[((@repr WORDSIZE32 4).*i)]<-(s_i_bytes.[(@repr WORDSIZE32 0)]) : Block_t in
    let block := block.[(((@repr WORDSIZE32 4).*i).+(@repr WORDSIZE32 1))]<-(s_i_bytes.[(@repr WORDSIZE32 1)]) : Block_t in
    let block := block.[(((@repr WORDSIZE32 4).*i).+(@repr WORDSIZE32 2))]<-(s_i_bytes.[(@repr WORDSIZE32 2)]) : Block_t in
    block.[(((@repr WORDSIZE32 4).*i).+(@repr WORDSIZE32 3))]<-(s_i_bytes.[(@repr WORDSIZE32 3)])) block.

Definition gimli_hash_state (input : Seq_t U8_t) (s : State_t) : State_t :=
  let rate := length : int32 in
  let chunks := num_exact_chunks input rate : int32 in
  let s := foldi (@repr WORDSIZE32 0) chunks (fun i s =>
      let input_block := get_exact_chunk input rate i : Seq_t U8_t in
      let full_block := from_seq input_block : Block_t in
      absorb_block full_block s) s : State_t in
  let input_block := get_remainder_chunk input rate : Seq_t U8_t in
  let input_block_padded := new : Block_t in
  let input_block_padded := update_start input_block_padded input_block : Block_t in
  let input_block_padded := input_block_padded.[(len input_block)]<-(secret (@repr WORDSIZE8 1)) : Block_t in
  let s := s.[(@repr WORDSIZE32 11)]<-((s.[(@repr WORDSIZE32 11)]).^(secret (@repr WORDSIZE32 16777216))) : State_t in
  let s := absorb_block input_block_padded s : State_t in
  s.

Definition gimli_hash (input_bytes : Seq_t U8_t) : Digest_t :=
  let s := new : State_t in
  let s := gimli_hash_state input_bytes s : State_t in
  let output := new : Digest_t in
  let output := update_start output (squeeze_block s) : Digest_t in
  let s := gimli s : State_t in
  update output length (squeeze_block s).

Notation Nonce_t := (nseq int8 16).
Definition Nonce : Nonce_t -> Nonce_t :=
  id.

Notation Key_t := (nseq int8 32).
Definition Key : Key_t -> Key_t :=
  id.

Notation Tag_t := (nseq int8 16).
Definition Tag : Tag_t -> Tag_t :=
  id.

Definition process_ad (ad : Seq_t U8_t) (s : State_t) : State_t :=
  gimli_hash_state ad s.

Definition process_msg (message : Seq_t U8_t) (s : State_t) : (State_t '× Seq_t U8_t) :=
  let ciphertext := new_seq (len message) : Seq_t U8_t in
  let rate := length : int32 in
  let num_chunks := num_exact_chunks message rate : int32 in
  let '(ciphertext,s) := foldi (@repr WORDSIZE32 0) num_chunks (fun i '(ciphertext,s) =>
      let key_block := squeeze_block s : Block_t in
      let msg_block := get_exact_chunk message rate i : Seq_t U8_t in
      let msg_block := from_seq msg_block : Block_t in
      let ciphertext := set_exact_chunk ciphertext rate i (msg_block.^key_block) : Seq_t U8_t in
      let s := absorb_block msg_block s : State_t in
      (ciphertext,s)) (ciphertext,s) : (Seq_t U8_t '× State_t) in
  let key_block := squeeze_block s : Block_t in
  let last_block := get_remainder_chunk message rate : Seq_t U8_t in
  let block_len := len last_block : int32 in
  let msg_block_padded := new : Block_t in
  let msg_block_padded := update_start msg_block_padded last_block : Block_t in
  let ciphertext := set_chunk ciphertext rate num_chunks (slice_range (msg_block_padded.^key_block) (Build_Range_t (@repr WORDSIZE32 0)block_len)) : Seq_t U8_t in
  let msg_block_padded := msg_block_padded.[block_len]<-((msg_block_padded.[block_len]).^(secret (@repr WORDSIZE8 1))) : Block_t in
  let s := s.[(@repr WORDSIZE32 11)]<-((s.[(@repr WORDSIZE32 11)]).^(secret (@repr WORDSIZE32 16777216))) : State_t in
  let s := absorb_block msg_block_padded s : State_t in
  (s,ciphertext).

Definition process_ct (ciphertext : Seq_t U8_t) (s : State_t) : (State_t '× Seq_t U8_t) :=
  let message := new_seq (len ciphertext) : Seq_t U8_t in
  let rate := length : int32 in
  let num_chunks := num_exact_chunks ciphertext rate : int32 in
  let '(message,s) := foldi (@repr WORDSIZE32 0) num_chunks (fun i '(message,s) =>
      let key_block := squeeze_block s : Block_t in
      let ct_block := get_exact_chunk ciphertext rate i : Seq_t U8_t in
      let ct_block := from_seq ct_block : Block_t in
      let msg_block := ct_block.^key_block : Block_t in
      let message := set_exact_chunk message rate i (ct_block.^key_block) : Seq_t U8_t in
      let s := absorb_block msg_block s : State_t in
      (message,s)) (message,s) : (Seq_t U8_t '× State_t) in
  let key_block := squeeze_block s : Block_t in
  let ct_final := get_remainder_chunk ciphertext rate : Seq_t U8_t in
  let block_len := len ct_final : int32 in
  let ct_block_padded := new : Block_t in
  let ct_block_padded := update_start ct_block_padded ct_final : Block_t in
  let msg_block := ct_block_padded.^key_block : Block_t in
  let message := set_chunk message rate num_chunks (slice_range msg_block (Build_Range_t (@repr WORDSIZE32 0)block_len)) : Seq_t U8_t in
  let msg_block := from_slice_range msg_block (Build_Range_t (@repr WORDSIZE32 0)block_len) : Block_t in
  let msg_block := msg_block.[block_len]<-((msg_block.[block_len]).^(secret (@repr WORDSIZE8 1))) : Block_t in
  let s := s.[(@repr WORDSIZE32 11)]<-((s.[(@repr WORDSIZE32 11)]).^(secret (@repr WORDSIZE32 16777216))) : State_t in
  let s := absorb_block msg_block s : State_t in
  (s,message).

Definition nonce_to_u32s (nonce : Nonce_t) : Seq_t U32_t :=
  let uints := new_seq (@repr WORDSIZE32 4) : Seq_t U32_t in
  let uints := uints.[(@repr WORDSIZE32 0)]<-(U32_from_le_bytes (from_slice_range nonce (Build_Range_t (@repr WORDSIZE32 0)(@repr WORDSIZE32 4)))) : Seq_t U32_t in
  let uints := uints.[(@repr WORDSIZE32 1)]<-(U32_from_le_bytes (from_slice_range nonce (Build_Range_t (@repr WORDSIZE32 4)(@repr WORDSIZE32 8)))) : Seq_t U32_t in
  let uints := uints.[(@repr WORDSIZE32 2)]<-(U32_from_le_bytes (from_slice_range nonce (Build_Range_t (@repr WORDSIZE32 8)(@repr WORDSIZE32 12)))) : Seq_t U32_t in
  uints.[(@repr WORDSIZE32 3)]<-(U32_from_le_bytes (from_slice_range nonce (Build_Range_t (@repr WORDSIZE32 12)(@repr WORDSIZE32 16)))).

Definition key_to_u32s (key : Key_t) : Seq_t U32_t :=
  let uints := new_seq (@repr WORDSIZE32 8) : Seq_t U32_t in
  let uints := uints.[(@repr WORDSIZE32 0)]<-(U32_from_le_bytes (from_slice_range key (Build_Range_t (@repr WORDSIZE32 0)(@repr WORDSIZE32 4)))) : Seq_t U32_t in
  let uints := uints.[(@repr WORDSIZE32 1)]<-(U32_from_le_bytes (from_slice_range key (Build_Range_t (@repr WORDSIZE32 4)(@repr WORDSIZE32 8)))) : Seq_t U32_t in
  let uints := uints.[(@repr WORDSIZE32 2)]<-(U32_from_le_bytes (from_slice_range key (Build_Range_t (@repr WORDSIZE32 8)(@repr WORDSIZE32 12)))) : Seq_t U32_t in
  let uints := uints.[(@repr WORDSIZE32 3)]<-(U32_from_le_bytes (from_slice_range key (Build_Range_t (@repr WORDSIZE32 12)(@repr WORDSIZE32 16)))) : Seq_t U32_t in
  let uints := uints.[(@repr WORDSIZE32 4)]<-(U32_from_le_bytes (from_slice_range key (Build_Range_t (@repr WORDSIZE32 16)(@repr WORDSIZE32 20)))) : Seq_t U32_t in
  let uints := uints.[(@repr WORDSIZE32 5)]<-(U32_from_le_bytes (from_slice_range key (Build_Range_t (@repr WORDSIZE32 20)(@repr WORDSIZE32 24)))) : Seq_t U32_t in
  let uints := uints.[(@repr WORDSIZE32 6)]<-(U32_from_le_bytes (from_slice_range key (Build_Range_t (@repr WORDSIZE32 24)(@repr WORDSIZE32 28)))) : Seq_t U32_t in
  uints.[(@repr WORDSIZE32 7)]<-(U32_from_le_bytes (from_slice_range key (Build_Range_t (@repr WORDSIZE32 28)(@repr WORDSIZE32 32)))).

Definition gimli_aead_encrypt (message : Seq_t U8_t) (ad : Seq_t U8_t) (nonce : Nonce_t) (key : Key_t) : (Seq_t U8_t '× Tag_t) :=
  let s := from_seq (concat (nonce_to_u32s nonce) (key_to_u32s key)) : State_t in
  let s := gimli s : State_t in
  let s := process_ad ad s : State_t in
  let '(s,ciphertext) := process_msg message s : (State_t '× Seq_t U8_t) in
  let tag := squeeze_block s : Block_t in
  let tag := from_seq tag : Tag_t in
  (ciphertext,tag).

Definition gimli_aead_decrypt (ciphertext : Seq_t U8_t) (ad : Seq_t U8_t) (tag : Tag_t) (nonce : Nonce_t) (key : Key_t) : Seq_t U8_t :=
  let s := from_seq (concat (nonce_to_u32s nonce) (key_to_u32s key)) : State_t in
  let s := gimli s : State_t in
  let s := process_ad ad s : State_t in
  let '(s,message) := process_ct ciphertext s : (State_t '× Seq_t U8_t) in
  let my_tag := squeeze_block s : Block_t in
  let my_tag := from_seq my_tag : Tag_t in
  let out := new_seq (@repr WORDSIZE32 0) : Seq_t U8_t in
  if
    equal my_tag tag
  then
    message
  else
    out.
