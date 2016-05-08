% Lab 5


% Exercise 1 Producer-Consumer

% (a)
declare
fun {Numbers N I J}
   if N==0
      then nil
   else
      {Delay 500}
      (({OS.rand} mod (J-I+1)) + I)|{Numbers N-1 I J}
   end
end

%{Browse {Numbers 10 0 4}}

% (b)
declare
fun {SumAndCount L}
   fun {SubSAC L S C}
      case L of nil then [S C]
      [] H|T then
	 {Delay 250}
	 {SubSAC T S+H C+1}
      end
   end
in
  {SubSAC L 0 0}
end

% (c)
% {Browse       {SumAndCount       {Number 4 0 1}    }   }  % slow
% {Browse thread{SumAndCount thread{Numbers 4 0 1}end}end}  % fast
% figure the time by yourself


% (d)
declare
fun {FilterList Xs Ys}
   fun {IsIn X Y}
      % true if X in list Y
      case Y of nil then false
      [] H|T then if H==X then true else {IsIn X T} end
      end
   end
in
   case Xs of nil then nil
   [] H|T then if {IsIn H Ys} then {FilterList T Ys} else H|{FilterList T Ys} end
   end
end

% test: {Browse {FilterList [hello world fool] [world]}}

% (e)
{Browse {SumAndCount {FilterList {Numbers 10 0 1} [1]}}}
% Is there anything else you want me to do?



% Exercise 2 Digital Logic

% (a)

declare
fun {NotGate L}
   case L of nil then nil
   [] H|T then (if H then false else true end)|thread {NotGate L} end
   end
end


% (b)

declare
fun {AndGate X Y}
   case X#Y of nil#R then nil
   [] R#nil then nil
   [] (H1|T1)#(H2|T2) then
      (H1 andthen H2)|thread{AndGate T1 T2}end
   end
end


declare
fun {OrGate X Y}
   case X#Y of nil#R then nil
   [] R#nil then nil
   [] (H1|T1)#(H2|T2) then
      (H1 orelse H2)|thread{AndGate T1 T2}end
   end
end


% (c) summary
declare
fun {Simulate G Ss}
   % la flemme
end
