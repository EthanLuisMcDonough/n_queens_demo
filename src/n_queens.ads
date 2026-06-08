--  Adapted from https://github.com/parasail-lang/parasail/blob/main/examples/n_queens.psl

with Prot_Stack;
with Ada.Calendar; use Ada.Calendar;

generic
   Max_N : Integer;
   Chunk_Count : Positive := 1;

package N_Queens is 

   type Chunk is new Positive range 1 .. Chunk_Count;

   type Chess_Unit is new Integer range Max_N * (-2) .. Max_N * 2;
   MAX  : constant Chess_Unit := Chess_Unit (Max_N);
   ZERO : constant Chess_Unit := Chess_Unit (0);
   ONE  : constant Chess_Unit := Chess_Unit (1);

   subtype Col_Or_Null is Chess_Unit range ZERO .. MAX;
   subtype Col is Chess_Unit range ONE .. MAX;
   subtype Row is Chess_Unit range ONE .. MAX;

   type Solution is array (Row) of Col_Or_Null;
   package Solution_Stack is new Prot_Stack (Element => Solution);
   subtype Solutions is Solution_Stack.Underlying_Container.Vector;

   type NQ_Observer is synchronized interface;
   procedure Display_Partial_Solution
     (Self : in out NQ_Observer; Partial_Solution : Solution; CI : Chunk)
      is abstract;

   protected type Null_Observer is new NQ_Observer with
      procedure Display_Partial_Solution (Partial_Solution : Solution; CI : Chunk);
   end Null_Observer;

   function Place_Queens
     (N : Row := Row (Max_N);
      Observer : in out NQ_Observer'Class)
      return Solutions;

   function Create_Null_Observer return NQ_Observer'Class;

private

   subtype Sum_Range  is Chess_Unit range 2 .. Chess_Unit'Last;
   subtype Diff_Range is Chess_Unit range ONE - MAX .. MAX - ONE;

   type Sum  is array (Sum_Range) of Boolean;
   type Diff is array (Diff_Range) of Boolean;

   type Solution_State is record
      Column    : Col      := 1;
      Trial     : Solution := (others => 0);
      Diag_Sum  : Sum      := (others => False);
      Diag_Diff : Diff     := (others => False);
   end record;

   function Is_Acceptable
     (S : Solution_State; R : Row)
      return Boolean;
   --  Returns True if the next queen could be placed in row R.

   function Next_State
     (S : Solution_State; R : Row)
      return Solution_State;
   --  Returns a Solution_State produced by adding a queen
   --  at (Current_Column(S), R).

   function Final_Result
     (S : Solution_State; R : Row)
      return Solution;
   --  Final_Result returns a result produced by adding a queen
   --  at (Columns.Last, R) to a solution with all other columns
   --  placed.

   package Work_List is new Prot_Stack (Element => Solution_State);

end N_Queens;
