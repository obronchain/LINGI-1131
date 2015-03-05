declare
fun{Numbers N I J}
   {Delay 500}
   if (N==0) then nil
   else ({OS.rand} mod (J-I+1)) +I|{Numbers N-1 I J} end
end

declare
proc{SumAndCount In S C}
   local
      fun{Sum In Acc}
	 {Delay 250}
	 case In of H|T then Acc+H|{Sum T Acc+H}
	 else nil end
      end

      fun{Count In Acc}
	 {Delay 250}
	 case In of H|T then Acc+1|{Count T Acc+1}
	 else nil end
      end
   in
      thread S = {Sum In 0}end
      thread C = {Count In 0}end
   end
end

declare
fun{FilterList Xs Ys}
   local
      fun{IsIn In Ys}
	 case Ys of nil then false
	 [] H|T then if (H==In) then {IsIn In T}
		     else false end
	 end
      end
   in
      case Xs of H|T then if {IsIn H Ys} then {FilterList T Ys}
			  else H|{FilterList T Ys} end
      else
	 nil
      end
   end
end

local
   Sum
   Count
   Num
   Filter
in
   thread Num = {Numbers 10 1 5} end
   thread Filter = {FilterList Num [2 3]}end 
   thread {SumAndCount Filter Sum Count} end
   {Browse Num}
   {Browse Filter}
   {Browse Sum}
   {Browse Count}
end
