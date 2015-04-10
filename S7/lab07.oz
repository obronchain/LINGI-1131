% 1
declare Ints Sum2 S GetI
fun lazy {Ints N} N|{Ints N+1} end

fun lazy {Sum2 Xs Ys}
   case Xs#Ys of (X|Xr)#(Y|Yr) then (X+Y)|{Sum2 Xr Yr} end
end

S=0|{Sum2 S {Ints 1}}

%a) 3 is browse when {Browse 2.2.1} is exectuted
%b)
fun{GetI S I}
   if I == 0 then S.1
   else {GetI S.2 I-1}
   end
end

{Browse {GetI S 6}}
%c) translation in kernel language

declare IntsProc Sum2Proc GetIProc
proc {IntsProc N Ret}
   local RetNext in
      thread {WaitNeeded Ret} Ret = N|RetNext {IntsProc N+1 RetNext} end
   end
end

proc {Sum2Proc Xs Ys Ret}
   case Xs#Ys
   of (X|Xr)#(Y|Yr) then
      local RetNext in
	 thread {WaitNeeded Ret} Ret = (X+Y)|RetNext {Sum2Proc Xr Yr RetNext}end
      end
   end
end

local S1 S2 S3 in
   {IntsProc 1 S1}
   S2 = 0|S3
   {Sum2Proc S2 S1 S3}
   {Browse {GetI S2 2}}
end

%exercice 2
declare
%% Delay random time. Print job’s type. Bind the flag.
proc {Job Type Flag}
   {Delay {OS.rand} mod 1000}
   {Browse Type}
   Flag=unit
end

%% BuildPs binds Ps to a tuple of process descriptions.
%% Each process is assigned a random type
proc {BuildPs N Ps}
   Ps={Tuple.make ’#’ N}
   for I in 1..N do
      Type={OS.rand} mod 10
      Flag
   in
      Ps.I=ps(type:Type job:proc {$} {Job Type Flag} end flag:Flag)
   end
end
%% Launching 100 processes
N=100
Ps={BuildPs N}
for I in 1..N do
   thread {Ps.I.job} end
end