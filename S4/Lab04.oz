% exo1
local X Y Z in
   thread X = Y + Z end
   thread
      Y = 1
      Z = 2
   end

   {Browse X}
   
end

declare
fun{Counter Ins}
   local AddL Run in
      fun{AddL L E}
	 case L of nil then E#1|nil
	 [] C#N|Next then
	    if C==E then C#(N+1)|Next
	    else C#N|{AddL Next E}
	    end
	 end
      end

      fun{Run In Actual}
	 case In of nil then nil
	 [] H|T then local Acc in
			Acc = {AddL Actual H}
			Acc|{Run T Acc}
			end
	 end
      end
      
      {Run Ins nil}
   end
   
end

local
   InS
   Result
in
   thread Result = {Counter InS} end
   InS = e|m|e|c|nil
   {Browse Result}
end

%exo 3 marche pas 
declare
proc{PassingTheToken Id Tin Tout}
   case Tin of H|T then X in
      {Browse Id#H}
      {Delay 1000}
      Tout = H|X
      {PassingTheToken Id T X}
   []nil then skip
   end
end

local
   T1 = ok|_|_
   T2
   T3
in
   thread {PassingTheToken 1 T1 T2}end
   thread {PassingTheToken 2 T2 T3}end
   thread {PassingTheToken 3 T3 T1}end
end


%exo 4 
declare
fun{Bar In NProduce NDrink}
   if (NProcude - NDrink < 4) then
      {Delay 500}
      beer|{Bar In NProduce+1 NDrink}
   else
      case In of H|T then
	 {Delay 500}
	 beer|{Bar In NProduce+1 NDrink+1}
      end
   end
end

declare
fun{Foo In N}
   case In of nil then nil
   [] H|T then
      {Delay 1200}
      {Browse 'FooDrinkNIs'}
      {Browse N}
      N+1|{Foo T N+1}
   end
end

local
   Beer
   F
in
   thread F = {Foo Beer 0} end
   thread Beer = {Bar F 0 0} end
   {Browse Beer}
   {Browse F}
end

