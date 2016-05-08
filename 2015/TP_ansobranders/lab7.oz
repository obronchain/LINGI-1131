%lab7
%8/06/15
%ansobr

%1
declare
fun lazy {Ints N}
   N|{Ints N+1}
end

fun lazy {Sum2 Xs Ys}
   case Xs#Ys of (X|Xr)#(Y|Yr) then (X+Y)|{Sum2 Xr Yr} end
end

declare
S=0|{Sum2 S {Ints 1}}

%a
{Browse S.2.2.1} %browse 3 car 0|1|3|6|10|15|21

%b
declare
fun {Si I}
   fun {Si2 I2 Acc}
      if I2 == I then Acc
      else {Si2 I2+1 Acc+I2}
      end
   end
in
   {Si2 1 0} 
end

{Browse {Si 7}}

%c
declare
proc {IntsKer N R}
   thread {WaitNeeded R}
      A in
      R=N|A
      {IntsKer N+1 A}
   end
end

proc {Sum2Ker Xs Ys R}
   thread {WaitNeeded R}
      case Xs#Ys of (X|Xr)#(Y|Yr) then
	 A in
	 R=(X+Y)|A
	 {Sum2Ker Xr Yr A}
      end
   end
end

declare
A B
S=0|A
{IntsKer 1 B}
{Sum2Ker S B A}

{Browse S.2.1} %browse 3 car 0|1|3|6|10|15|21


%2

%a par un stream de bits (0 ou 1)

%b Combitional logic : circuit qui est indépendant du temps (ne dépend pas de la valeur du passé)

%ex : not suivi de and

% declare
% fun {Not Xs}
%    case Xs of X|Xr then 1-X|{Not Xr} end
% end

% fun {And Xs Ys}
%    case Xs#Ys of (X|Xr)#(Y|Yr) then (X*Y)|{And Xr Yr} end
% end

declare
fun {GateMaker F}
   fun {Gate Xs Ys}
      case Xs#Ys of (X|Xr)#(Y|Yr) then {F X Y}|{Gate Xr Yr}
      [] nil#nil then nil
      [] nil#Y then nil
      [] X#nil then nil
      end
   end
in
   Gate
end

declare
And = {GateMaker fun {$ X Y} X*Y end}
Not = {GateMaker fun {$ X Y} 1-X end}
Or = {GateMaker fun {$ X Y} X+Y-(X*Y) end}
Xor = {GateMaker fun {$ X Y} (X+Y) mod 2 end}


declare
X = 0|0|1|0|1|1|1|0|1|0|0|0|_
Y = 1|0|0|1|0|1|1|0|0|0|1|0|_
{Browse thread {And thread {Not X X} end thread {Not Y Y} end} end}


%c : sequential logic : circuit qui dépend de ses valeurs passées

declare
X = 0|0|1|0|1|1|1|0|1|0|0|0|_
Y = 0|thread {Or X Y} end
{Browse Y}


%d
declare
fun {Oscillates Xs}
   case Xs of X|Xr then 1-X|{Oscillates Xr} end
end

declare
{Browse Y}
Y = 0|thread {Oscillates Y} end


%3

declare
proc {Job Type Flag}
   {Delay {OS.rand} mod 3000}
   {Browse Type}
   Flag=unit
end

proc {BuildPs N Ps}
   Ps = {Tuple.make '#' N}
   for I in 1..N do
      Type = {OS.rand} mod 10
      Flag
   in
      Ps.I=ps(type:Type job:proc {$} {Job Type Flag} end flag:Flag)
   end
end


N=100
Ps={BuildPs N}

for I in 1..N do
   thread {Ps.I.job} end
end

proc {WatchPs I Ps}
   for X in 1..N do
      if Ps.X.type==I then {Wait Ps.X.flag} end
   end
   {Browse 'OK lalalalalalalalalalalalalalalalalalala'}
end

{WatchPs 3 Ps}


%4
declare
fun {WaitOr X Y}
   R in
   thread {Wait X} R=unit end
   thread {Wait Y} R=unit end
   {Wait R}
end




%6
declare
fun {Counter Xs}
   fun {CounterAux Xs Xnext R}
     % {Browse Xnext}
      case Xs of nil then {CounterAux Xnext nil R}
      [] Xs1|XsS then	 
	 case Xs1 of Xx|Xr then
	   % {Browse Xs1}
	    fun {Insert L Xx}
	       case L of nil then (Xx#1)|nil
	       [] (H#N)|T then
		  if Xx==H then (Xx#N+1)|T
		  else (H#N)|{Insert T Xx}
		  end
	       end
	    end
	    Res
	 in
	    Res = {Insert R Xx}
	    case Xnext of nil then Res|{CounterAux XsS [Xr] Res}
	    else Res|{CounterAux XsS {Append Xnext [Xr]} Res}
	    end
	 end
      end
   end
in
   {CounterAux Xs nil nil}
end


declare
X = e|c|m|e|m|t|v|i|m|c|i|_
Y = r|z|p|p|z|r|m|a|r|p|z|_
Z = w|x|v|v|x|v|w|x|x|v|w|_
T
thread T={Counter X|Y|Z|nil} end
{Browse T}