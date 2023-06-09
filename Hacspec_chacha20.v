(* File automatically generated by Hacspec *)
From Hacspec Require Import Hacspec_Lib MachineIntegers.
From Coq Require Import ZArith.
Import List.ListNotations.
Open Scope Z_scope.
Open Scope bool_scope.

(*Not implemented yet? todo(item)*)

From Examples Require Import Hacspec_lib.

Notation State_t := (nseq int32 16).
Definition State : State_t -> State_t :=
  id.

Notation Constants_t := (nseq int32 4).
Definition Constants : Constants_t -> Constants_t :=
  id.

Notation Block_t := (nseq int8 64).
Definition Block : Block_t -> Block_t :=
  id.

Notation ChaChaIV_t := (nseq int8 12).
Definition ChaChaIV : ChaChaIV_t -> ChaChaIV_t :=
  id.

Notation ChaChaKey_t := (nseq int8 32).
Definition ChaChaKey : ChaChaKey_t -> ChaChaKey_t :=
  id.

Definition chacha20_line (a : int32) (b : int32) (d : int32) (s : int32) (m : State_t) : State_t :=
  let state := m : State_t in
  let state := state.[a]<-((state.[a]).+(state.[b])) : State_t in
  let state := state.[d]<-((state.[d]).^(state.[a])) : State_t in
  state.[d]<-(rol (state.[d]) s).

Definition chacha20_quarter_round (a : int32) (b : int32) (c : int32) (d : int32) (state : State_t) : State_t :=
  let state := chacha20_line a b d (@repr WORDSIZE32 16) state : State_t in
  let state := chacha20_line c d b (@repr WORDSIZE32 12) state : State_t in
  let state := chacha20_line a b d (@repr WORDSIZE32 8) state : State_t in
  chacha20_line c d b (@repr WORDSIZE32 7) state.

Definition chacha20_double_round (state : State_t) : State_t :=
  let state := chacha20_quarter_round (@repr WORDSIZE32 0) (@repr WORDSIZE32 4) (@repr WORDSIZE32 8) (@repr WORDSIZE32 12) state : State_t in
  let state := chacha20_quarter_round (@repr WORDSIZE32 1) (@repr WORDSIZE32 5) (@repr WORDSIZE32 9) (@repr WORDSIZE32 13) state : State_t in
  let state := chacha20_quarter_round (@repr WORDSIZE32 2) (@repr WORDSIZE32 6) (@repr WORDSIZE32 10) (@repr WORDSIZE32 14) state : State_t in
  let state := chacha20_quarter_round (@repr WORDSIZE32 3) (@repr WORDSIZE32 7) (@repr WORDSIZE32 11) (@repr WORDSIZE32 15) state : State_t in
  let state := chacha20_quarter_round (@repr WORDSIZE32 0) (@repr WORDSIZE32 5) (@repr WORDSIZE32 10) (@repr WORDSIZE32 15) state : State_t in
  let state := chacha20_quarter_round (@repr WORDSIZE32 1) (@repr WORDSIZE32 6) (@repr WORDSIZE32 11) (@repr WORDSIZE32 12) state : State_t in
  let state := chacha20_quarter_round (@repr WORDSIZE32 2) (@repr WORDSIZE32 7) (@repr WORDSIZE32 8) (@repr WORDSIZE32 13) state : State_t in
  chacha20_quarter_round (@repr WORDSIZE32 3) (@repr WORDSIZE32 4) (@repr WORDSIZE32 9) (@repr WORDSIZE32 14) state.

Definition chacha20_rounds (state : State_t) : State_t :=
  let st := state : State_t in
  foldi (@repr WORDSIZE32 0) (@repr WORDSIZE32 10) (fun _i st =>
    chacha20_double_round st) st.

Definition chacha20_core (ctr : U32_t) (st0 : State_t) : State_t :=
  let state := st0 : State_t in
  let state := state.[(@repr WORDSIZE32 12)]<-((state.[(@repr WORDSIZE32 12)]).+ctr) : State_t in
  let k := chacha20_rounds state : State_t in
  k.+state.

Definition chacha20_constants_init : Constants_t :=
  let constants := new : Constants_t in
  let constants := constants.[(@repr WORDSIZE32 0)]<-(secret (@repr WORDSIZE32 1634760805)) : Constants_t in
  let constants := constants.[(@repr WORDSIZE32 1)]<-(secret (@repr WORDSIZE32 857760878)) : Constants_t in
  let constants := constants.[(@repr WORDSIZE32 2)]<-(secret (@repr WORDSIZE32 2036477234)) : Constants_t in
  constants.[(@repr WORDSIZE32 3)]<-(secret (@repr WORDSIZE32 1797285236)).

Definition chacha20_init (key : ChaChaKey_t) (iv : ChaChaIV_t) (ctr : U32_t) : State_t :=
  let st := new : State_t in
  let st := update st (@repr WORDSIZE32 0) chacha20_constants_init : State_t in
  let st := update st (@repr WORDSIZE32 4) (to_le_U32s key) : State_t in
  let st := st.[(@repr WORDSIZE32 12)]<-ctr : State_t in
  update st (@repr WORDSIZE32 13) (to_le_U32s iv).

Definition chacha20_key_block (state : State_t) : Block_t :=
  let state := chacha20_core (secret (@repr WORDSIZE32 0)) state : State_t in
  from_seq (to_le_bytes state).

Definition chacha20_key_block0 (key : ChaChaKey_t) (iv : ChaChaIV_t) : Block_t :=
  let state := chacha20_init key iv (secret (@repr WORDSIZE32 0)) : State_t in
  chacha20_key_block state.

Definition chacha20_encrypt_block (st0 : State_t) (ctr : U32_t) (plain : Block_t) : Block_t :=
  let st := chacha20_core ctr st0 : State_t in
  let pl := from_seq (to_le_U32s plain) : State_t in
  let st := pl.^st : State_t in
  from_seq (to_le_bytes st).

Definition chacha20_encrypt_last (st0 : State_t) (ctr : U32_t) (plain : Seq_t U8_t) : Seq_t U8_t :=
  let b := new : Block_t in
  let b := update b (@repr WORDSIZE32 0) plain : Block_t in
  let b := chacha20_encrypt_block st0 ctr b : Block_t in
  slice b (@repr WORDSIZE32 0) (len plain).

Definition chacha20_update (st0 : State_t) (m : Seq_t U8_t) : Seq_t U8_t :=
  let blocks_out := new_seq (len m) : Seq_t U8_t in
  let n_blocks := num_exact_chunks m (@repr WORDSIZE32 64) : int32 in
  let blocks_out := foldi (@repr WORDSIZE32 0) n_blocks (fun i blocks_out =>
      let msg_block := get_exact_chunk m (@repr WORDSIZE32 64) i : Seq_t U8_t in
      let b := chacha20_encrypt_block st0 (secret i) (from_seq msg_block) : Block_t in
      set_exact_chunk blocks_out (@repr WORDSIZE32 64) i b) blocks_out : Seq_t U8_t in
  let last_block := get_remainder_chunk m (@repr WORDSIZE32 64) : Seq_t U8_t in
  if
    (len last_block)<>(@repr WORDSIZE32 0)
  then
    let b := chacha20_encrypt_last st0 (secret n_blocks) last_block : Seq_t U8_t in
    set_chunk blocks_out (@repr WORDSIZE32 64) n_blocks b
  else
    blocks_out.

Definition chacha20 (key : ChaChaKey_t) (iv : ChaChaIV_t) (ctr : int32) (m : Seq_t U8_t) : Seq_t U8_t :=
  let state := chacha20_init key iv (secret ctr) : State_t in
  chacha20_update state m.
