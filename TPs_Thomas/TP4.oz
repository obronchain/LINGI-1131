% Lab 4 S4
% Threads and declarative concurrency

% ----
% Ex 1
% ----
% a) Le premier bloque car c’est un seul et même thread qui exécute ce code.
% Donc l’exécution s’arrête à la ligne « X = Y+Z » car il attend que Y et Z soient bound.

% b)
local X Y Z in
   thread X = Y + Z end
   Y = 4
   Z = 9
   {Browse X}
end

% ----
% Ex 2
% ----


declare
fun {Counter L}
   fun {Counter2 L2 A}
      case L2 of nil then nil
      [] H|T then thread {Update A H}|{Counter2 T {Update A H}} end
      end
   end
in
   thread {Counter2 L nil} end
end

{Browse {Counter [a b a c]}}

declare
fun {Update A H}
   case A of nil then [H#1]
   [] H2|T2 then
      case H2 of E#N then
	 if E==H then E#(N+1)|T2
	 else H2|{Update T2 H}
	 end
      end
   end
end

{Browse {Update [b#2 a#3] a}}

local
   InS
in
   {Browse {Counter InS}}
   InS=a|b|a|c|_
end


% ----
% Ex 4
% ----

declare
fun {Bar N Limit}
   {Delay 100}
   if N>Limit then nil
   else N|thread {Bar N+1 Limit} end
   end
end

proc {Buffer N ?Xs Ys}
   fun {Startup N ?Xs}
      if N==0 then Xs
      else Xr in Xs = _|Xr {Startup N-1 Xr} end
   end

   proc {AskLoop Ys ?Xs ?End}
      case Ys of Y|Yr then Xr End2 in
	 Xs = Y|Xr % get element from buffer
	 End = _|End2 % Replenish the buffer
	 {AskLoop Yr Xr End2}
      else
	 skip
      end
   end
   
   End = {Startup N Xs}
in
   {AskLoop Ys Xs End}
end
   

fun {DGenerate N Xs}
   case Xs of X|Xr then
      X = N
      {DGenerate N+1 Xr}
   end
end


declare S1 S2 Xs
{Browse '------'}
thread
   S1 = {Bar 1 10}
   {Browse S1}
end
thread
   {Buffer 4 Xs S1}
   {Browse Xs}
end
