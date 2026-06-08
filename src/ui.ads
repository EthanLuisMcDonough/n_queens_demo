with Gtk.Grid;   use Gtk.Grid;
with Gtk.Label;  use Gtk.Label;
with Glib.Main;  use Glib.Main;
with Gtk.Window; use Gtk.Window;
with Gtk.Button; use Gtk.Button;
with N_Queens;
with Prot_Queue;

package UI is
   Size        : constant Positive := 8;
   Chunk_Cols  : constant Positive := 4;
   Chunk_Rows  : constant Positive := 2;
   Chunk_Count : constant Positive := Chunk_Cols * Chunk_Rows;

   procedure Run;
private
   package Queens is new N_Queens (Max_N => Size, Chunk_Count => Chunk_Count);
   use Queens;

   type Labels is array (1 .. Size, 1 .. Size) of Gtk_Label;
   type Chess_Board is record
      Table : Gtk_Grid;
      Cells : Labels;
   end record;

   Boards  : array (Chunk) of Chess_Board;
   Run_Btn : Gtk_Button;
   Results : Gtk_Label;

   function Create_Board return Chess_Board;
   procedure Render_Solution (Board : Chess_Board; S : Solution);

   type Board_Data is record
      S  : Solution;
      Id : Chunk;
   end record;

   package Board_Idle is new Glib.Main.Generic_Sources (Board_Data);
   package Completed_Idle is new Glib.Main.Generic_Sources (Natural);
   package Solution_Queue is new Prot_Queue (Element => Solution);

   task UI_Observer is new NQ_Observer with
      entry Display_Partial_Solution (Partial_Solution : Solution; CI : Chunk);
      entry Set_Solution (Value : Natural);
   end UI_Observer;
   --  Consumer thread
   
   procedure Populate_Window (Window : Gtk_Window);

   function Delayed_Render (Data : Board_Data) return Boolean;
   function Queens_Complete (Data : Natural) return Boolean;
   procedure Click_Run_Event (Self : access Gtk_Button_Record'Class);

   task type Compute_Queens (R : Row);
   type CQ_Ref is access Compute_Queens;
   --  Producer thread
end UI;
