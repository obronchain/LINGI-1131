declare
fun {Flatten L}
   fun {SubFlat L}
      case L of
	 nil then nil
      [] H|T then {Append {SubFlat H} {SubFlat T}}
      [] X   then [X]
      end
   
   end
in
   {SubFlat L}
end

{Browse {Flatten [1 [2 3 [4]] 5]}}