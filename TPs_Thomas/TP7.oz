% Lab 7: more laziness and the limitations of declarative concurrency

% ----
% Ex 1
% ----

% a)

declare
fun lazy {Ints N}
   N|{Ints N+1}
end

fun lazy {Sum2 Xs Ys}
   case Xs#Ys of (X|Xr)#(Y|Yr) then (X+Y)|{Sum2 Xr Yr} end
end % the trick is at 'of (X|Xr)#(Y|Yr)' -> there the (Y|Yr) unleashed the lazy {Ints N}

S = 0|{Sum2 S {Ints 1}}

{Browse S.2.2.1} % What is browsed: 3

{Browse S}
{Browse S.2.1}
{Browse S.2.2.1}
{Browse S.2.2.2.1}
{Browse S.2.2.2.2.1}
{Browse S.2.2.2.2.2.1}
{Browse S.2.2.2.2.2.2.1} % S = 0|1|3|6|10|15|21|_

% b)

declare
fun {Touch I}
   local S
      fun {TouchHelper I Acc}
	 if I == 0 then Acc.1
	 else {TouchHelper I-1 Acc.2}
	 end
      end
   in
      S = 0|{Sum2 S {Ints 1}}
      {TouchHelper I S}
   end
end

{Browse {Touch 2}}

% c)

% oktm


% d)

% oktm


% ----
% Ex 2
% ----

% oktm


% ----
% Ex 3
% ----

declare
%% Delay random time. Print job’s type. Bind the flag.
proc {Job Type Flag}
   {Delay {OS.rand} mod 1000}
   %{Browse Type}
   Flag=unit
end

%% BuildPs binds Ps to a tuple of process descriptions.
%% Each process is assigned a random type
proc {BuildPs N Ps}
   Ps={Tuple.make '#' N} % creates a tuple of N (empty) elements
   {Browse Ps}
   for I in 1..N do
      Type={OS.rand} mod 10
      Flag
   in
      Ps.I=ps(type:Type job:proc {$} {Job Type Flag} end flag:Flag)
      %{Browse Ps}
   end
end

proc {WatchPs I Ps}
   for K in 1..{Record.width Ps} do
      if Ps.K.type == I then {Wait Ps.K.flag} end
   end
   {Browse 'all the threads of type '#I#' are finished'}
end

%% Launching 100 processes
declare
N=30
Ps={BuildPs N}
for I in 1..N do
   thread {Ps.I.job} end
end
thread {WatchPs 4 Ps} end


% ----
% Ex 4
% ----

declare
proc {WaitOr X Y}
   local A in
      thread {Wait X} A=1 end
      thread {Wait Y} A=1 end
      {Wait A}
      {Browse 'unlocked'}
   end
end

declare
A=_
B=_
{WaitOr A B}
{Browse 'finish'}


% ----
% Ex 5
% ----


declare
fun {WaitOr X Y}
   local A in
      thread {Wait X} A=1 end
      thread {Wait Y} A=1 end
      {Wait A}
      {Browse 'unlocked'}
      X % or Y !! it doesn't work with this paradigm
        % it does work with ports (see next lab)
   end
end

declare
A=_
B=_
{Browse {WaitOr A B}}
{Browse 'finish'}
B=500 % wrong, {WaitOr A B} returns A instead of B


% ----
% Ex 6
% ----




