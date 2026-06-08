with Ada.Containers.Doubly_Linked_Lists;

generic
   type Element is private;
package Prot_Queue is
   package Underlying_Container is new
     Ada.Containers.Doubly_Linked_Lists
       (Element_Type => Element);
   
   protected type Queue is
      function Is_Empty return Boolean;
      function Length return Natural;
      procedure Push (E : Element);
      procedure Pop (E : out Element);
      procedure Clear;
   private
      Items : Underlying_Container.List;
   end Queue;
end Prot_Queue;