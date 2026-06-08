--  Adapted from https://github.com/parasail-lang/parasail/blob/main/examples/n_queens.psl

package body N_Queens is
   protected body Null_Observer is
      procedure Display_Partial_Solution
        (Partial_Solution : Solution; CI : Chunk)
      is
      begin
         null;
      end Display_Partial_Solution;    
   end Null_Observer;

   function Create_Null_Observer return NQ_Observer'Class is
      NO : Null_Observer;
   begin
      return NQ_Observer'Class (NO);
   end Create_Null_Observer;

   function Place_Queens
     (N : Row := Row (Max_N);
      Observer : in out NQ_Observer'Class)
      return Solutions
   is
      Computed   : Solution_Stack.Stack;
      Task_Stack : Work_List.Stack;
      SS         : Solution_State := (others => <>);
   begin
      Task_Stack.Push (SS);

      while not Task_Stack.Is_Empty loop
         Task_Stack.Pop (SS);
         declare
            State : constant Solution_State := SS;
         begin
            parallel (CI in Chunk'Range)
            for R in 1 .. N loop
               if Is_Acceptable (State, R) then
                  if State.Column < N then
                     declare
                        Next : constant Solution_State :=
                          Next_State (State, R);
                     begin
                        Observer.Display_Partial_Solution (Next.Trial, CI);
                        Task_Stack.Push (Next);
                     end;
                  else
                     declare
                        Final : constant Solution :=
                          Final_Result (State, R);
                     begin
                        Observer.Display_Partial_Solution (Final, CI);
                        Computed.Push (Final);
                     end;
                  end if;
               end if;
            end loop;
         end;
      end loop;

      return Computed.Get_Items;
   end Place_Queens;

   function Is_Acceptable
     (S : Solution_State; R : Row)
      return Boolean
   is
   begin
      return S.Trial (R) = 0
        and then not S.Diag_Sum (R + S.Column)
        and then not S.Diag_Diff (R - S.Column);
   end Is_Acceptable;

   function Next_State
     (S : Solution_State; R : Row)
      return Solution_State
   is
      NS : Solution_State := S;
   begin
      NS.Column := S.Column + 1;
      NS.Diag_Sum (R + S.Column) := True;
      NS.Diag_Diff (R - S.Column) := True;
      NS.Trial (R) := S.Column;
      return NS;
   end Next_State;

   function Final_Result
     (S : Solution_State; R : Row)
      return Solution
   is
      Sol : Solution := S.Trial;
   begin
      Sol (R) := S.Column;
      return Sol;
   end Final_Result;

end N_Queens;
