% exo 1
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
	 [] H|T then if (H==In) then true
		     else {IsIn In T} end
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


%exo2
declare
fun{Not Val}
   (Val+1) mod 2
end

declare
fun{NotGate In}
   {Delay 500}
   case In of H|T then
      {Not H}|{NotGate T}
   else
      nil
   end
end

declare
fun{AndGate In1 In2}
   {Delay 500}
   case In1|In2 of (H1|T1)|(H2|T2)
   then
      (H1*H2)|{AndGate T1 T2}
   end
end

declare
fun{OrGate In1 In2}
   {Delay 500}
   case In1|In2 of (H1|T1)|(H2|T2)
   then
      (H1+H2-(H2*H1))|{OrGate T1 T2}
   end
end

declare
fun{Simulate G Input}
   case G of gate(value:X Y Z)
   then
      %{Browse  'matching1'}
      if (X == 'or') then
	 thread {OrGate {Simulate Y Input} {Simulate Z Input}} end
      elseif (X == 'and') then
	 thread {AndGate {Simulate Y Input} {Simulate Z Input}} end
      end  
   [] gate(value:X Y)
   then
      %{Browse' matching2'}
      if( X=='not') then
	 thread {NotGate {Simulate Y Input}} end
      end
   [] input(X) then
      %{Browse 'matching3'}
      %{Browse Input.X}
      Input.X
   end	 
end

local
   G = gate(value:'not' input(x) )
   Input = input(x:1|0|1|0|_ y:0|1|0|1|_ z:1|1|0|0|_ )
in
   {Browse {Simulate G Input}}
end

{Browse 42}

%exo 3 Termination of threads
%a
declare
L1 L2 F
L1 = [1 2 3]
F = fun {$ X} {Delay 200} X*X end

thread L2 = {Map L1 F}  end
{Wait L2}

{Show 'trol'}