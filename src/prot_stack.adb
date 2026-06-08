package body Prot_Stack is
   use Underlying_Container;

   protected body Stack is
      function Is_Empty return Boolean is
      begin
         return Items.Is_Empty;
      end Is_Empty;

      function Length return Natural is
      begin
         return Natural (Items.Length);
      end Length;

      procedure Push (S : Element) is
      begin
         Items.Append (S);
      end Push;

      procedure Pop (S : out Element) is
      begin
         S := Items.Last_Element;
         Items.Delete_Last;
      end Pop;

      function Get_Items return Underlying_Container.Vector is
      begin
         return Items;
      end Get_Items;
   end Stack;
end Prot_Stack;
