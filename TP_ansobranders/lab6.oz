%Lab6
%08/06/15
%ansobr

%1

declare
fun lazy {Gen I}
   I|{Gen I+1}
end

{Browse {Gen 23}.1}

declare
fun {GiveMeNth N L}
   fun {Nth I L2}
      case L2 of X|L3 then
	 if I==N then X	 
	 else {Nth I+1 L3}
	 end
      end
   end
in
   
   {Nth 1 L}
end

{Browse {GiveMeNth 6 {Gen 17}}}


%2

declare
proc {Filter Xs P R}
   thread {WaitNeeded R}
      case Xs of
	 nil then R=nil
      [] X|Xr then
	 if {P X} then A in
	    {Filter Xr P A}
	    R= X|A
	 else
	    {Filter Xr P R}
	 end
      end
   end
end

fun lazy {Primes}
   fun {P X}
      fun {Pr I}
	 if I<2 then true
	 elseif X mod I == 0 then false
	 else {Pr I-1}
	 end
      end
   in
      {Pr (X div 2)}
   end
   R
in
   {Filter {Gen 1} P R}
   R
end

declare
L = {Primes}
{Browse {GiveMeNth 4 L}}


declare
proc {Sieve Xs R}
   thread {WaitNeeded R}
      case Xs of nil then R=nil
      [] X|Xr then
	 if X==1 then B in
	    {Sieve Xr B}
	    R=X|B
	 else A B in
	    {Filter Xr fun {$ Y} Y mod X \= 0 end A}
	    {Sieve A B}
	    R=X|B
	 end
      end
   end
end

{Browse {GiveMeNth 4 {Sieve {Gen 1} $}}}


%3
declare
fun {ShowPrimes N}
   fun {Show2 I Xs}
      case Xs of X|Xr then	 
	 if I > N then nil
	 else X|{Show2 I+1 Xr}
	 end
      end
   end
in
   {Show2 1 {Primes}}
end

{Browse {ShowPrimes 10}}


%4

declare
fun lazy {Gen I N} {Delay 200}
   if I==N then [I] else I|{Gen I+1 N} end end

fun lazy {Filter L F}
   case L of nil then nil [] H|T then
      if {F H} then H|{Filter T F} else {Filter T F} end end
end
fun {Map L F}
   case L of nil then nil
   [] H|T then {F H}|{Map T F} end
end

declare Xs Ys Zs
{Browse Zs}
%thread {Gen 1 100 Xs} end
%thread {Filter Xs fun {$ X} (X mod 2)==0 end Ys} end
%{Map Ys fun {$ X} X*X end Zs}
{Gen 1 100 Xs}
{Filter Xs fun {$ X} (X mod 2)==0 end Ys}
{Map Ys fun {$ X} X*X end Zs}



%8

declare

fun {Buffer In N}
   End=thread {List.drop In N} end
   fun lazy {Loop In End}
      case In of I|In2 then
	 I|{Loop In2 thread End.2 end}
      end
   end
in
   {Loop In End}
end


proc {DGenerate N Xs}
   case Xs of X|Xr then
      X=N
      {DGenerate N+1 Xr}
   end
end

fun {DSum01 ?Xs A Limit}
   {Delay {OS.rand} mod 10}
   if Limit>0 then
      X|Xr=Xs
   in
      {DSum01 Xr A+X Limit-1}
   else A end
end

fun {DSum02 ?Xs A Limit}
   {Delay {OS.rand} mod 10}
   if Limit>0 then X|Xr=Xs
   in
      {DSum02 Xr A+X Limit-1}
   else A end
end

local Xs Ys V1 V2 in
   thread {DGenerate 1 Xs} end %producer thread
   thread {Buffer 4 Xs Ys} end %Buffer thread
   thread V1={DSum01 Ys 0 1500} end %consummer thread
   thread V2={DSum02 Ys 2 1500} end %consummer thread
   {Browse [Xs Ys V1 V2]}
end


%Sol
% declare
% fun lazy {DGenerate N}
%       N|{DGenerate N+1}
% end
% fun {DSum01 ?Xs A Limit}
%    if Limit>0 then
%       {Delay {OS.rand} mod 10}
%       {DSum01 Xs.2 A+Xs.1 Limit-1}
%    else A end
% end
% fun {DSum02 ?Xs A Limit}
%    {Delay {OS.rand} mod 10}
%    if Limit>0 then
%       X|Xr=Xs
%    in
%       {DSum02 Xr A+X Limit-1}
%    else A end
% end
% local Xs Ys V1 V2 in
%     {DGenerate 1 Xs} % Producer thread
%     {Buffer Xs 4 Ys}  % Buffer thread
%    thread V1={DSum01 Ys 0 100} end % Consumer thread
%    thread V2={DSum02 Ys 2 100} end % Consumer thread
%    {Browse [Xs Ys V1 V2]}
% end