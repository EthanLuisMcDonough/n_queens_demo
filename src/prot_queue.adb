package body Prot_Queue is
   protected body Queue is
      function Is_Empty return Boolean is
      begin
         return Items.Is_Empty;
      end Is_Empty;

      function Length return Natural is
      begin
         return Natural (Items.Length);
      end Length;

      procedure Push (E : Element) is
      begin
         Items.Append (E);
      end Push;

      procedure Pop (E : out Element) is
      begin
         E := Items.Last_Element;
         Items.Delete_Last;
      end Pop;

      procedure Clear is
      begin
         Items.Clear;
      end Clear;
   end Queue;
end Prot_Queue;
