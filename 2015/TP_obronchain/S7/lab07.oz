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

%exercice 3
declare
%% Delay random time. Print job’s type. Bind the flag.
proc {Job Type Flag}
   {Delay {OS.rand} mod 1000}
   {Browse Type}
   Flag=unit
end


%% BuildPs binds Ps to a tuple of process descriptions.
%% Each process is assigned a random type
declare 
proc{BuildPs N Ps}
   Ps={Tuple.make '#' N}
   for I in 1..N do
      Type={OS.rand} mod 10
      Flag
   in
      Ps.I=ps(type:Type job:proc {$} {Job Type Flag} end flag:Flag)
   end
end

%% Launching 100 processes

declare N PS WaitPs
N=100
Ps={BuildPs N}
for I in 1..N do
   thread {Ps.I.job} end
end

proc{WaitPs I Ps}
   for C in 1..N do
      if Ps.C.type==I then {Wait Ps.C.flag}
      else skip end
   end
   {Browse 'all ended'}
end
{WaitPs 4 Ps}

%exercice 4

declare
proc{WaitOr X Y}
   local Val in
      thread {Wait X} Val=unit end
      thread {Wait Y} Val=unit end
      {Wait Val}
      {Browse 'One is Bound'}
   end
end

declare X Y
{WaitOr X Y}
X = 1
Y = 12

%exo 5
declare
fun{WaitOrValue X Y}
   local LocX={NewCell 0}  LocY={NewCell 0}  Val in
      thread {Wait X} if @LocX==0 then LocY:= 1 Val=X else skip end end
      thread {Wait Y} if @LocY==0 then LocX:= 1 Val=Y else skip end end
      {Wait Val}
      Val
   end 
end

declare X Y
{Browse {WaitOrValue X Y}}
X = 42 

%exo 6
declare N WaitOrValue Counter X Y X1 X2 X3 X4 X5 Y1 Y2 Y3 Y4 Y5 Result
fun{WaitOrValue X Y }
   {Browse 'Waiting'}
   local LocX={NewCell 0}  LocY={NewCell 0}  Val in
      thread {Wait X} if @LocX==0 then LocY:= 1 Val='x' else skip end end
      thread {Wait Y} if @LocY==0 then LocX:= 1 Val='y' else skip end end
      {Wait Val}
      Val
   end 
end

fun{Counter X Y }
   local AddL Run in
      fun{AddL L E}
	 case L of nil then E#1|nil
	 [] C#N|Next then
	    if C==E then C#(N+1)|Next
	    else C#N|{AddL Next E}
	    end
	 end
      end
      fun{Run X Y  Actual}
	 local Other In in 
	    In = {WaitOrValue X Y}
	    if In=='x' then
	       case X of nil then nil
	       [] H|T then local Acc in
			      Acc={AddL Actual H}
			      Acc|{Run T Y Acc}
			   end
	       end
	    else
	       case Y of nil then nil
	       [] H|T then local Acc in
			      Acc={AddL Actual H}
			      Acc|{Run T X Acc}
			   end
	       end
	    end	    
	 end
      end
      {Run X Y nil}
   end
end

thread Result = {Counter X Y } end
{Browse Result}
X1 = e
X = X1|X2
Y1 = f
Y = Y1|Y2
X2 = f|X3
Y2 = e|Y3
Y3 = g|Y4
   
