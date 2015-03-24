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


% exo 3
declare
proc {PassingTheToken Id Tin Tout}
   case Tin of H|T then X in
      {Show Id#H}
      {Delay 1000}
      Tout = H|X
      {PassingTheToken Id T X}
   [] nil then
      skip
   end
end

local
   S1 S2 S3
in
   thread {PassingTheToken 1 unit|S1 S2} end
   thread {PassingTheToken 2 S2 S3} end
   thread {PassingTheToken 3 S3 S1} end
end

%exo Foo at the Bar
declare
fun{Bar N In}
   if N < 4 then
      {Delay 4000}
      {Browse 'beer produced'}
      {Browse N}
      beer|{Bar N+1 In}
   else
      case In of H|T then
	 {Bar N-1 T}
      end
   end
end

declare
fun{Foo In N}
   case In of H|T then
      {Delay 5000}
      {Browse 'Foo you drink'}
      {Browse N}
      drinked|{Foo T N+1}
   end
end

local
   Beers
   Drinked
in
   thread Beers = {Bar 0 Drinked} end
   thread Drinked = {Foo Beers 0} end
end

% exo 3
declare
proc {PassingTheToken Id Tin Tout}
   case Tin of H|T then X in
      {Show Id#H}
      {Delay 1000}
      Tout = H|X
      {PassingTheToken Id T X}
   [] nil then
      skip
   end
end

local
   S1 S2 S3
in
   thread {PassingTheToken 1 unit|S1 S2} end
   thread {PassingTheToken 2 S2 S3} end
   thread {PassingTheToken 3 S3 S1} end
end

%exo Foo at the Bar
declare
fun{Bar N In}
   if N < 4 then
      {Delay 4000}
      {Browse 'beer produced'}
      {Browse N}
      beer|{Bar N+1 In}
   else
      case In of H|T then
	 {Bar N-1 T}
      end
   end
end

declare
fun{Foo In N}
   case In of H|T then
      {Delay 5000}
      {Browse 'Foo you drink'}
      {Browse N}
      drinked|{Foo T N+1}
   end
end

local
   Beers
   Drinked
in
   thread Beers = {Bar 0 Drinked} end
   thread Drinked = {Foo Beers 0} end
end

