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
	 case In of H|T then Acc+H|{Sum T Acc+H}
	 else nil end
      end

      fun{Count In Acc}
	 case In of H|T then Acc+1|{Count T Acc+1}
	 else nil end
      end
   in
      thread S = {Sum In 0}end
      thread C = {Count In 0}end
   end
end

local
   Sum
   Count
   Num
in
   thread Num = {Numbers 10 1 4} end
   thread {SumAndCount Num Sum Count} end
   {Browse Sum}
   {Browse Count}
   {Browse Num}
end

