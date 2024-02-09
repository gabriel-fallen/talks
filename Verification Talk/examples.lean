
#print List

/-
inductive List A where
| nil : List A
| cons : A -> List A -> List A
-/

/-
Hello World of theorem proving:
reversing a list is an involution :)
-/

def rev (l : List α) : List α :=
  match l with
  | List.nil       => List.nil
  | List.cons x xs => rev xs ++ [x]


theorem rev_append : ∀ (l m : List α), rev (l ++ m) = rev m ++ rev l := by
  intro l m
  induction l with
  | nil => simp [rev]
  | cons hd tl ih =>
    simp [rev]
    rw [ih, <-List.append_assoc]

theorem rev_append1 : ∀ (l m : List α), rev (l ++ m) = rev m ++ rev l :=
  λ l m => match l with
  | List.nil => by simp [rev]
  | List.cons x xs => by
    simp [rev]
    have ih : rev (xs ++ m) = rev m ++ rev xs := rev_append1 xs m
    rw [ih, <-List.append_assoc]

#print rev_append1


theorem rev_rev : ∀ (l : List α), rev (rev l) = l := by
  intro l
  induction l with
  | nil => simp [rev]
  | cons hd tl ih =>
    simp [rev]
    rw [rev_append, ih]
    simp [rev]

#print List.append_assoc


/-
A toy compiler correctness :)
-/

-- A type (alias) for variable names
@[reducible]
def Name := String

-- An expression language
inductive Expr (α : Type) where
| lit : α -> Expr α
| var : Name -> Expr α
| add : Expr α -> Expr α -> Expr α
| mul : Expr α -> Expr α -> Expr α
-- deriving Repr

def ex1 : Expr Nat := Expr.add (Expr.mul (Expr.var "z") (Expr.var "y")) (Expr.mul (Expr.var "x") (Expr.lit 23))

-- A type class with handy features :)
class Num (α : Type) extends Add α, Mul α where
  add_comm : add x y = add y x
  mul_comm : mul x y = mul y x


-- Let's provide some instances to actually evaluate expressions
instance : Num Nat where
  -- That's totally stupid and trivial but I don't know how else
  -- to convert between `+` and `add`
  add_comm := by
    apply Nat.add_comm
  mul_comm := by
    apply Nat.mul_comm

instance : Num Int where
  -- should be in the standard library
  add_comm := by
    intro x y
    match x, y with
    | Int.ofNat m,   Int.ofNat n   =>
      simp [Add.add, Int.add]
      apply Nat.add_comm
    | Int.ofNat m,   Int.negSucc n =>
      simp [Add.add, Int.add]
    | Int.negSucc m, Int.ofNat n   =>
      simp [Add.add, Int.add]
    | Int.negSucc m, Int.negSucc n =>
      simp [Add.add, Int.add]
      apply Nat.add_comm

  mul_comm := by
    intro x y
    match x, y with
    | Int.ofNat m,   Int.ofNat n   =>
      simp [Mul.mul, Int.mul]
      apply Nat.mul_comm
    | Int.ofNat m,   Int.negSucc n =>
      simp [Mul.mul, Int.mul]
      rw [Nat.mul_comm]
    | Int.negSucc m, Int.ofNat n   =>
      simp [Mul.mul, Int.mul]
      rw [Nat.mul_comm]
    | Int.negSucc m, Int.negSucc n =>
      simp [Mul.mul, Int.mul]
      apply Nat.mul_comm

-- OK, as long as we can work with integers now let's try another example

def ex2 : Expr Int := Expr.add (Expr.mul (Expr.var "z") (Expr.var "y")) (Expr.mul (Expr.var "x") (Expr.lit (-1)))


namespace Interpreter

open Expr

def eval [Num α] (env : Name -> α) (e : Expr α) : α :=
  match e with
  | lit a => a
  | var n => env n
  | add e1 e2 => (eval env e1) + (eval env e2)
  | mul e1 e2 => (eval env e1) * (eval env e2)


-- Now we can get a value of the `ex1`
#eval eval (λ _ => 42) ex1

-- What about `ex2`?
#eval eval (λ _ => 42) ex2


end Interpreter


-- A "bytecode"
inductive Code (α : Type) where
| const (v : α)
| read (n : Name)
| plus
| times


namespace VM

def reduce_stack (op : α -> α -> α) (stack : List α) : List α :=
  match stack with
  | x::y::st => (op x y)::st
  | _ => []

def run [Num α] (heap : Name -> α) (stack : List α) (p : List (Code α)) : List α :=
  match p with
  | []    => stack
  | c::cs =>
    match c with
    | Code.const v => run heap (v::stack) cs
    | Code.read  n => run heap (heap n :: stack) cs
    | Code.plus    => run heap (reduce_stack (· + ·) stack) cs
    | Code.times   => run heap (reduce_stack (· * ·) stack) cs

end VM

namespace Compiler

open Expr

def compile (e : Expr α) : List (Code α) :=
  match e with
  | lit a     => [Code.const a]
  | var n     => [Code.read  n]
  | add e1 e2 => compile e1 ++ compile e2 ++ [Code.plus]
  | mul e1 e2 => compile e1 ++ compile e2 ++ [Code.times]


-- Correctness

open Interpreter
open VM

theorem run_append [Num α] : ∀ (cs1 cs2 : List (Code α)) heap stack, run heap stack (cs1 ++ cs2) = run heap (run heap stack cs1) cs2 := by
  intros cs1 cs2 _ stack
  induction cs1 generalizing stack with
  | nil => simp [run]
  | cons hd tl ih =>
    cases hd <;> simp [run] <;> rw [ih]

theorem compiler_correct_aux [Num α] : ∀ (e : Expr α) heap stack, run heap stack (compile e) = eval heap e :: stack := by
  intro e heap stack
  induction e generalizing stack with
  | lit => simp [run, compile, eval]
  | var => simp [run, compile, eval]
  | add e1 e2 ih1 ih2 =>
    simp [run, compile, eval]
    rw [run_append]
    rw [run_append]
    rw [ih1, ih2]
    simp [run, compile, eval, reduce_stack]
    apply @Num.add_comm _ _ (eval heap e2) (eval heap e1)
  | mul e1 e2 ih1 ih2 =>
    simp [run, compile, eval]
    rw [run_append]
    rw [run_append]
    rw [ih1, ih2]
    simp [run, compile, eval, reduce_stack]
    apply @Num.mul_comm _ _ (eval heap e2) (eval heap e1)


theorem compiler_correct [Num α] : ∀ (e : Expr α) heap, run heap [] (compile e) = [eval heap e] :=
  λ e heap => compiler_correct_aux e heap []


-- Now that we know our compiler is correct we can try compiling and running the `ex1` :)
#eval run (λ _ => 42) [] (compile ex1)

-- ... or `ex2`
#eval run (λ _ => 42) [] (compile ex2)

end Compiler
