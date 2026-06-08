with Glib;       use Glib;
with Gtk.Main;   use Gtk.Main;
with Gtk.Box;    use Gtk.Box;
with Gtk.Enums;  use Gtk.Enums;
with Gdk.RGBA;   use Gdk.RGBA;
with LWT.OpenMP; use LWT.OpenMP;
with Ada.Containers.Doubly_Linked_Lists;

package body UI is
   Control : OMP_Parallel (Num_Threads => Chunk_Count);
   pragma Unreferenced (Control);

   SQUARE_SIZE   : constant Gint   := 25;
   QUEEN_MARKUP  : constant String := "<span size=""14pt""><tt>♛</tt></span>";

   function Create_Board return Chess_Board is
      BLACK : constant Gdk_RGBA := (0.78, 0.43, 0.45, 1.0);
      WHITE : constant Gdk_RGBA := (0.94, 0.91, 0.91, 1.0);
      Table : Gtk_Grid;
      Cells : Labels;
   begin
      Gtk_New (Table);

      for I in 1 .. Size loop
         for J in 1 .. Size loop
            declare
               Cell : Gtk_Label := Gtk_Label_New ("");
            begin
               Cells (I, J) := Cell;
               Cell.Set_Size_Request (SQUARE_SIZE, SQUARE_SIZE);
               if (Integer (I) - 1) mod 2 = (Integer (J) - 1) mod 2 then
                  Cell.Override_Background_Color (Gtk_State_Flag_Normal, WHITE);
               else
                  Cell.Override_Background_Color (Gtk_State_Flag_Normal, BLACK);
               end if;
               
               Table.Attach (Cell, Gint (I) - 1, Gint (J) - 1);
            end;
         end loop;
      end loop;

      return (Table => Table, Cells => Cells);
   end Create_Board;

   procedure Render_Solution (Board : Chess_Board; S : Queens.Solution) is
   begin
      for I in 1 .. Size loop
         for J in 1 .. Size loop
            if Integer (S (Queens.Row (I))) = J then
               Set_Markup (Board.Cells (I, J), QUEEN_MARKUP);
            else
               Set_Markup (Board.Cells (I, J), "");
            end if;
         end loop;
      end loop;
   end Render_Solution;

   procedure Populate_Window (Window : Gtk_Window) is
      Table     : Gtk_Grid;
      Main_Body : Gtk_Box;
   begin
      Gtk_New (Table);
      Set_Column_Spacing (Table, 25);
      Set_Row_Spacing (Table, 15);

      Gtk_New (Results);
      Set_Label (Results, "Click the button to start the demo");

      Gtk_New (Run_Btn);
      Set_Label (Run_Btn, "Run Simulation");
      On_Clicked (Run_Btn, Click_Run_Event'Access);

      Gtk_New_Vbox (Main_Body);

      declare
         CI : Chunk := Chunk'First;
      begin
         for R in 1 .. Gint (Chunk_Rows) loop
            for C in 1 .. Gint (Chunk_Cols) loop
               declare
                  Cell : Gtk_Box;
                  Chunk_Lbl : constant Gtk_Label :=
                    Gtk_Label_New ("Chunk " & CI'Image);
                  Board : Chess_Board renames Boards (CI);
               begin
                  Gtk_New_Vbox (Cell);
                  Set_Spacing (Main_Body, 10);
                  
                  Board := Create_Board;
                  Cell.Add (Board.Table);
                  Cell.Add (Chunk_Lbl);

                  Table.Attach (Cell, C, R);
               end;

               if CI /= Chunk'Last then
                  CI := Chunk'Succ (CI);
               end if;
            end loop;
         end loop;
      end;

      Main_Body.Add (Results);
      Main_Body.Add (Table);
      Main_Body.Add (Run_Btn);

      Window.Add (Main_Body);
      Window.Set_Border_Width (20);
      Window.Set_Resizable (False);
   end Populate_Window;

   procedure Run is
      Window : Gtk_Window;
   begin
	   Init;
      Gtk_New (Window);

      Window.Set_Title (Size'Image & " Queens Demo");
      Populate_Window (Window);

   	Window.Show_All;
	   Gtk.Main.Main;
   end Run;

   function Delayed_Render (Data : Board_Data) return Boolean is
   begin
      Render_Solution (Boards (Data.Id), Data.S);
      return False;
   end Delayed_Render;

   function Queens_Complete (Data : Natural) return Boolean is
   begin
      Set_Label (Results, "Found " & Data'Image & " solutions");
      Set_Sensitive (Run_Btn, True);
      return False;
   end Queens_Complete;

   task body UI_Observer is
      use Solution_Queue;
      Solution_Val : Natural := 0;
      Has_Solution : Boolean := False;
      Queues       : array (Chunk) of List;
   begin
      loop
         select
            accept Display_Partial_Solution
              (Partial_Solution : Solution; CI : Chunk)
            do
               Queues (CI).Prepend (Partial_Solution);
            end Display_Partial_Solution;
         or
            accept Set_Solution (Value : Natural) do
               Has_Solution := True;
               Solution_Val := Value;
            end Set_Solution;
         or
            delay 0.1;
            declare
               All_Empty : Boolean := True;
               Res       : G_Source_Id;
            begin
               for CI in Queues'Range loop
                  declare
                     S : Solution := (others => 0);
                  begin
                     if not Queues (CI).Is_Empty then
                        S := Queues (CI).Last_Element;
                        Queues (CI).Delete_Last;
                        All_Empty := False;
                     end if;
                     Res := Board_Idle.Idle_Add
                       (Delayed_Render'Access, (S => S, Id => CI));
                  end;
               end loop;

               if All_Empty and then Has_Solution then
                  Has_Solution := False;
                  Res := Completed_Idle.Idle_Add
                    (Queens_Complete'Access, Solution_Val);
                  Solution_Val := 0;
               end if;
            end;
         end select;
      end loop;
   end UI_Observer;

   procedure Click_Run_Event (Self : access Gtk_Button_Record'Class) is
      T : CQ_Ref;
   begin
      Set_Sensitive (Run_Btn, False);
      Set_Label (Results, "Running simulation...");
      T := new Compute_Queens (Row (Size));
   end Click_Run_Event;

   task body Compute_Queens is
      S : Solutions;
   begin
      S := Place_Queens (R, NQ_Observer'Class (UI_Observer));
      UI_Observer.Set_Solution (Natural (S.Length));
   end Compute_Queens;
end UI;
