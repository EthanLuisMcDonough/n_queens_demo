with Ada.Containers.Vectors;

generic
   type Element is private;
package Prot_Stack is
   package Underlying_Container is new
     Ada.Containers.Vectors
       (Index_Type   => Positive,
        Element_Type => Element);

   protected type Stack is
      function Is_Empty return Boolean;
      function Length return Natural;
      procedure Push (S : Element);
      procedure Pop (S : out Element);
      function Get_Items return Underlying_Container.Vector;
   private
      Items : Underlying_Container.Vector;
   end Stack;
end Prot_Stack;
