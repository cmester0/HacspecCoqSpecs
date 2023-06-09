(* File automatically generated by Hacspec *)
From Hacspec Require Import Hacspec_Lib MachineIntegers.

From Coq Require Import ZArith.
Import List.ListNotations.
Open Scope Z_scope.
Open Scope bool_scope.

From Hacspec Require Export MachineIntegers.
From Hacspec Require Export Hacspec_Lib.

(** Should be moved to Hacspec_Lib.v **)
Definition int_xI {WS : WORDSIZE} (a : int) : int := MachineIntegers.add (MachineIntegers.mul a (repr 2)) MachineIntegers.one.
Definition int_xO {WS : WORDSIZE} (a : int) : int := MachineIntegers.mul a (repr 2).
Number Notation int Pos.of_num_int Pos.to_num_int (via positive mapping [[int_xI] => xI, [int_xO] => xO , [MachineIntegers.one] => xH]) : hacspec_scope.
Notation "0" := (repr O).
Notation U8_t := int8.
Notation U8 := id.
Notation U16_t := int16.
Notation U16 := id.
Notation U32_t := int32.
Notation U32 := id.
Notation U64_t := int64.
Notation U64 := id.
Notation U128_t := int128.
Notation U128 := id.

Definition array_index {A: Type} `{Default A} {len : nat} (s: nseq A len) {WS} (i : @int WS) := array_index s (unsigned i).
Notation " x .[ a ]" := (array_index x a) (at level 40).
Definition array_upd {A: Type} {len : nat} (s: nseq A len) {WS} (i: @int WS) (new_v: A) : nseq A len := array_upd s (unsigned i) new_v.
Notation " x .[ i ]<- a" := (array_upd x i a) (at level 40).

Class Addition A := add : A -> A -> A.
Notation "a .+ b" := (add a b).
Instance array_add_inst {ws : WORDSIZE} {len: nat} : Addition (nseq (@int ws) len) := { add a b := a array_add b }.
Instance int_add_inst {ws : WORDSIZE} : Addition (@int ws) := { add a b := MachineIntegers.add a b }.

Class Subtraction A := sub : A -> A -> A.
Notation "a .- b" := (sub a b).
Instance array_sub_inst {ws : WORDSIZE} {len: nat} : Subtraction (nseq (@int ws) len) := { sub := array_join_map MachineIntegers.sub }.
Instance int_sub_inst {ws : WORDSIZE} : Subtraction (@int ws) := { sub a b := MachineIntegers.sub a b }.

Class Multiplication A := mul : A -> A -> A.
Notation "a .* b" := (mul a b).
Instance array_mul_inst {ws : WORDSIZE} {len: nat} : Multiplication (nseq (@int ws) len) := { mul a b := a array_mul b }.
Instance int_mul_inst {ws : WORDSIZE} : Multiplication (@int ws) := { mul a b := MachineIntegers.mul a b }.

Class Xor A := xor : A -> A -> A.
Notation "a .^ b" := (xor a b).

Instance array_xor_inst {ws : WORDSIZE} {len: nat} : Xor (nseq (@int ws) len) := { xor a b := a array_xor b }.
Instance int_xor_inst {ws : WORDSIZE} : Xor (@int ws) := { xor a b := MachineIntegers.xor a b }.

Definition new {A : Type} `{Default A} {len} : nseq A len := array_new_ default _.
Class array_or_seq A len :=
{ as_seq : seq A ; as_nseq : nseq A len }.

Arguments as_seq {_} {_} array_or_seq.
Arguments as_nseq {_} {_} array_or_seq.
Coercion as_seq : array_or_seq >-> seq.
Coercion as_nseq : array_or_seq >-> nseq.

Instance nseq_array_or_seq {A len} (a : nseq A len) : array_or_seq A len :=
{ as_seq := array_to_seq a ; as_nseq := a ; }.
Coercion nseq_array_or_seq : nseq >-> array_or_seq.

Instance seq_array_or_seq {A} `{Default A} (a : seq A) : array_or_seq A (length a) :=
{ as_seq := a ; as_nseq := array_from_seq _ a ; }.
Coercion seq_array_or_seq : seq >-> array_or_seq.

Definition update {A : Type}  `{Default A} {len slen} (s : nseq A len) {WS} (start : @int WS) (start_a : array_or_seq A slen) : nseq A len :=
array_update (a := A) (len := len) s (unsigned start) (as_seq start_a).

Definition to_le_U32s {A l} := array_to_le_uint32s (A := A) (l := l).
Axiom to_le_bytes : forall {ws : WORDSIZE} {len}, nseq (@int ws) len -> seq int8.
Definition from_seq {A : Type}  `{Default A} {len slen} (s : array_or_seq A slen) : nseq A len := array_from_seq _ (as_seq s).

Notation Seq_t := seq.
Notation len := (fun s => seq_len s : int32).

Definition array_slice {a: Type} `{Default a} {len : nat} (input: nseq a len) {WS} (start: @int WS) (slice_len: @int WS) : seq a := slice (array_to_seq input) (unsigned start) (unsigned (start .+ slice_len)).
Notation slice := array_slice.
Definition seq_new {A: Type} `{Default A} {WS} (len: @int WS) : seq A := seq_new (unsigned len).
Notation new_seq := seq_new.
Notation num_exact_chunks := seq_num_exact_chunks.
Notation get_exact_chunk := seq_get_exact_chunk.
Definition set_chunk {a: Type} `{Default a} {len} (s: seq a) {WS} (chunk_len: @int WS) (chunk_num: @int WS) (chunk: array_or_seq a len) : seq a := seq_set_chunk s (unsigned chunk_len) (unsigned chunk_num) (as_seq chunk).
Definition set_exact_chunk {a} `{H : Default a} {len} s {WS} := @set_chunk a H len s WS.
     Notation get_remainder_chunk := seq_get_remainder_chunk.
Notation "a <> b" := (negb (eqb a b)).

Notation from_secret_literal := nat_mod_from_secret_literal.
Definition pow2 {m} (x : @int WORDSIZE32) := nat_mod_pow2 m (unsigned x).
Instance nat_mod_addition {n} : Addition (nat_mod n) := { add a b := a +% b }.
Instance nat_mod_subtraction {n} : Subtraction (nat_mod n) := { sub a b := a -% b }.
Instance nat_mod_multiplication {n} : Multiplication (nat_mod n) := { mul a b := a *% b }.
Definition from_slice {a: Type} `{Default a} {len slen} (x : array_or_seq a slen) {WS} (start: @int WS) (slice_len: @int WS) := array_from_slice default len (as_seq x) (unsigned start) (unsigned slice_len).
Notation zero := nat_mod_zero.
Notation to_byte_seq_le := nat_mod_to_byte_seq_le.
Notation U128_to_le_bytes := u128_to_le_bytes.
Notation U64_to_le_bytes := u64_to_le_bytes.
     Notation from_byte_seq_le := nat_mod_from_byte_seq_le.
Definition from_literal {m} := nat_mod_from_literal m.
Notation inv := nat_mod_inv.
Notation update_start := array_update_start.
Notation pow := nat_mod_pow_self.
Notation bit := nat_mod_bit.

Definition int_to_int {ws1 ws2} (i : @int ws1) : @int ws2 := repr (unsigned i).
Coercion int_to_int : int >-> int.
Notation push := seq_push.
Notation Build_secret := secret.
Notation "a -× b" :=
(prod a b) (at level 80, right associativity) : hacspec_scope.
Notation Result_t := result.
Axiom TODO_name : Type.
Notation ONE := nat_mod_one.
Notation exp := nat_mod_exp.
Notation nat_mod := GZnZ.znz.
Instance nat_mod_znz_addition {n} : Addition (GZnZ.znz n) := { add a b := a +% b }.
Instance nat_mod_znz_subtraction {n} : Subtraction (GZnZ.znz n) := { sub a b := a -% b }.
Instance nat_mod_znz_multiplication {n} : Multiplication (GZnZ.znz n) := { mul a b := a *% b }.
Notation TWO := nat_mod_two.
Notation ne := (fun x y => negb (eqb x y)).
Notation eq := (eqb).
Notation rotate_right := (ror).
Notation to_be_U32s := array_to_be_uint32s.
Notation get_chunk := seq_get_chunk.
Notation num_chunks := seq_num_chunks.
Notation U64_to_be_bytes := uint64_to_be_bytes.
Notation to_be_bytes := array_to_be_bytes.
Notation U8_from_usize := uint8_from_usize.
Notation concat := seq_concat.
Notation declassify := id.
Notation U128_from_be_bytes := uint128_from_be_bytes.
Notation U128_to_be_bytes := uint128_to_be_bytes.
Notation slice_range := array_slice_range.
Notation truncate := seq_truncate.
Axiom array_to_be_uint64s : forall {A l}, nseq A l -> seq uint64.
Notation to_be_U64s := array_to_be_uint64s.
Notation classify := id.
Notation U64_from_U8 := uint64_from_uint8.
Fixpoint Build_Range_t (a b : nat) := (a,b). (* match (b - a)%nat with O => [] | S n => match b with | O => [] | S b' => Build_Range_t a b' ++ [b] end end. *)
Notation declassify_eq := eq.
Notation String_t := String.string.
(** end of: Should be moved to Hacspec_Lib.v **)
