% Let's solve poor old Flavius-Josephus' problem
% (lucky thing he had a Oz compiler in his cave)
% (Oh, he didn't use Oz 2.0, so there was no real challenge)

declare

% OOP
proc {FlaviusJosephusOOP N Step ?Last}
   class Person
      attr prev succ number
      meth init(I)
	 number := I
      end
      
      meth setSucc(X)
	 succ := X
      end
      meth setPrev(X)
	 prev := X
      end

      meth killtoken( Skip  Remaining )
	 if Remaining == 1 then % end the slaughter
	    Last = @number
	 elseif Skip == 0 then % kill yourself
	    % short-circuit protocol
	    {@succ setPrev(@prev)}
	    {@prev setSucc(@succ)}
	    {@succ killtoken( Step-1 Remaining-1 )}
	 else
	    {@succ killtoken( Skip-1 Remaining )}
	 end
      end
      
   end
   Persons = {MakeTuple people N}
in
   for I in 1..N do
      Persons.I = {New Person init(I)}
   end
   for I in 1..N-1 do
      {Persons.I setSucc(Persons.(I+1))}
   end
   {Persons.N setSucc(Persons.1)}
   for I in 2..N do
      {Persons.I setPrev(Persons.(I-1))}
   end
   {Persons.1 setPrev(Persons.N)}
   % send the first kill message
   {Persons.1 killtoken( Step-1 N )}
end

{Browse {FlaviusJosephusOOP 40 3}}


% OOP sucks! We don't need such a complicated paradigm (he!)
% We can simply use our good old deterministic dataflow (PVRgasm)
declare
proc {FlaviusJosephusDD N Step ?Last} % using STREAMS
   fun {PersonStream I Xs}
      case Xs of kill( Skip Remaining )|Xr then
	 if Remaining==1 then Last=I nil
	 elseif Skip==0 then
	    kill( Step-1 Remaining-1 )|Xr
	 else
	    kill( Skip-1 Remaining )|{PersonStream I Xr}
	 end
      end
   end
   proc {People I Xs ?Ys}
      if I>0 then Xr in 
	 thread Ys={PersonStream I Xr} end
	 Xr = {People I-1 Xs}
      else
	 Ys = Xs
      end
   end
   S
in
   % build list
   S = kill(Step-1 N)|{People N S}
end

{Browse {FlaviusJosephusDD 40 3}}


% let's compare the speed
% for high M, OOP is faster (less thread communication, I guess), but less robust: Oz crashes for too high values (highly unstable)
% for high N, OOP is again faster, but crashes for high values :-( OOP sucks!

local N M FJ1 FJ2 in
   N = 5000
   M = 50
   {Browse benchmarking#N#M}
   %FJ1 = thread {FlaviusJosephusOOP N M} end
   FJ2 = thread {FlaviusJosephusDD  N M} end
   {Browse FJ1#FJ2}
end


% quick reminders

% lazy
declare
proc {LazyFCall F ?R}
   thread
      {WaitNeeded R}
      {F R}
   end
end

local A in
   A = {LazyFCall fun {$} 1+2 end}
   {Browse hello#A}
   {Delay 1000}
   {Wait A}
end


% lock
declare
proc {NewLock ?L}
   C = {NewCell unit}
in
   L = proc {$ P} Xnew Xold in
	  {Exchange C Xold Xnew}
	  {Wait Xold}
	  {P}
	  Xnew = unit
       end
end

local L in
   {NewLock L}
   thread {L proc {$} {Delay 100} {Browse yep} {Delay 100} {Browse yep2} end} end
   thread {L proc {$} {Delay 100} {Browse yop} {Delay 100} {Browse yop2} end} end
end


% Barriers

% Wait for termination of all the threads
declare
proc {Barrier Ps}
   proc {SubBarrier Ps WaitVar}
      case Ps of P|Pr then Xwait in
	 thread {P} {Wait WaitVar} Xwait=unit end
	 {SubBarrier Pr Xwait}
      [] nil then {Wait WaitVar} end
   end
in
   {SubBarrier Ps unit}
end

% test
{Barrier
 [
  proc {$} {Delay 1000} {Browse finished} end
  proc {$} {Delay 2000} {Browse finished} end
  proc {$} {Browse finished} end
 ]
} {Browse released}




% termination detection
declare
proc {NewThread P ?SubThread}
   MsgStream
   Notifier = {NewPort MsgStream}

   proc {Agent S V}
      case S of Msg|T then
	 if Msg==create then
	    {Agent T V+1}
	 elseif Msg==exit then
	    if V==1 then skip % it is over
	    else {Agent T V-1}
	    end
	 end
      end
   end
in
   % execute procedure in its own thread
   SubThread = proc {$ P}
		  {Send Notifier create}
		  thread
		     {P}
		     {Send Notifier exit}
		  end
	       end
   % execute full thread and wait
   {SubThread P}
   {Agent MsgStream 0}
end

% test
local SubThread in
   {NewThread
    proc {$}
       {Browse hello}
       {Delay 500}
       {SubThread proc {$} {Delay 500} {Browse world} end}
       {SubThread proc {$} {SubThread proc{$} {Browse nurse} end} {Delay 1000} {Browse troll} end}
    end
    SubThread}
   {Browse finished}
end



% Bounded buffer

% explicit laziness

declare
proc {ELInts I Xs}
   case Xs of X|Xr then X=I {ELInts I+1 Xr} end
end

proc {ELTouch I Xs}
   if I>0 then Xr in Xs=_|Xr {Delay 500} {ELTouch I-1 Xr} end
end

fun {EmptyList N Tail}
   if N==0 then Tail else _|{EmptyList N-1 Tail} end
end

proc {BBE N Xs Ys}
   proc {BB Xs Ys End}
      case Ys of Y|Yr then Xr End2 in
	 Xs = Y|Xr
	 End = _|End2
	 {BB Xr  Yr End2}
      end
   end
   End
in
   Xs = {EmptyList N End}
   {BB Xs Ys End}
end

% test
local S1 S2 in
   S1 = thread {ELInts 0} end
   S2 = thread {BBE 10 S1} end
   {Browse S1}
   {Browse S2}
   thread {ELTouch 20 S2} end
end


   
% implicit laziness
declare
fun lazy {ILInts I}
   I|{ILInts I+1}
end
proc {ILTouch N X}
   {Delay 500}
   if N==0 then skip else {ILTouch N-1 X.2} end
end
fun {GetNth N L}
   if N==0 then L else {GetNth N-1 L.2} end
end

fun {BBI N Xs}
   fun lazy {BBI Xs End} End2 in End=_|End2
      Xs.1|{BBI Xs.2 End2}
   end
in
   {BBI Xs {GetNth N Xs}}
end

local S1 S2 in
   S1 = {ILInts 0}
   S2 = {BBI 10 S1}
   {Browse S1}
   {Browse S2}
   thread {ILTouch 20 S2} end
end



% reentrant locks and an example on queues


class Queue
   attr head tail n
   meth init()
      n := 0
      head := _
      tail := @head
   end
   meth enqueue(X)
      NewTail R in 
      @tail = X|NewTail
      tail := NewTail
      R = @n + 1
      {Delay 1}
      n := R
   end
   meth dequeue(?R)
      case @head of H|T then R=H head:=T end
      n := @n-1
   end
   meth length(?R)
      R = @n
   end
end

% test
local Q in
   Q = {New Queue init()}
   {Q enqueue(42)}
   {Q enqueue(5)}
   {Q enqueue(7)}
   {Browse {Q length($)}}
   {Browse {Q dequeue($)}}
   {Browse {Q dequeue($)}}
   {Q enqueue(8)}
   {Browse {Q dequeue($)}}
   {Browse {Q dequeue($)}}
   thread{Browse {Q dequeue($)}} end
   thread {Delay 1000} {Q enqueue(42)} end
end

% sequentially, it works... Now, let's use a lot of threads
declare
proc {HardTest Q}
   for I in 1..1000 do
      thread {Delay 1000} {Q enqueue(I)} end
   end
   {Delay 2000} {Browse {Q length($)}}
end

{HardTest {New Queue init()}} % yiels bad results (3 instead of 1000 :-/ )

% Two solutions exist: active objects and locks

% active objects
declare
fun {MakeActiveObject Class Init}
   S Object Port
in
   Object = {New Class Init}
   {NewPort S Port}
   thread
      for Msg in S do
	 {Object Msg}
      end
   end
   proc {$ Msg}
      {Send Port Msg}
   end
end

{HardTest {MakeActiveObject Queue init()}}


% Second solution: locks!

declare
fun {NewLock}
   C = {NewCell unit}
in
   proc {$ P}
      Old New in
      {Exchange C Old New}
      {Wait Old}
      {P}
      New = unit
   end
end

class LockedQueue from Queue
   attr head tail n mylock
   meth init()
      Queue,init()
      mylock := {NewLock}
   end
   meth enqueue(X)
      {@mylock proc {$}
		  Queue,enqueue(X)
	       end}
   end
   meth dequeue(?R)
      {@mylock proc {$}
		  Queue,dequeue(R)
	       end}
   end
   meth length(?R)
      R = @n
   end
end   

{HardTest {New LockedQueue init()}}

% This approach can be generalised, as a matter of fact
declare
fun {MakeLockedObject NewLock Class Init}
   Lock Object in
   {New Class Init Object}
   {NewLock Lock}
   proc {$ Msg}
      {Lock proc {$} {Object Msg} end}
   end
end

{HardTest {MakeLockedObject NewLock Queue init()}}


% However, this does not make us able to implement large atomic operations using the same lock.
% To show this, let us implement a stack with a new Exchange operation, and lock it with MakeLockedObject.
% The exchange will simply call pop then push in the same method. 

declare
class Stack
   attr head n
   meth init()
      head := nil
      n := 0
   end
   meth push(X)
      head := X|@head
      n := @n + 1
   end
   meth pop(?R)
      case @head of H|T then R=H head:=T end
      n := @n - 1
   end
   meth length(?R)
      R = @n
   end
   % new operations
   meth exchange(X ?R)
      {self pop(R)}
      {self push(X)}
   end
end

% Let's try this exchange operation (and test the stack)
local S in
   S = {New Stack init()}
   {S push(42)}
   {S push(32)}
   {Browse {S length($)}}
   {Browse {S pop($)}}
   {Browse {S exchange(~1 $)}}
   {Browse {S length($)}}
   {Browse {S pop($)}}
end

% Exchange works fine! But what if we lock?
local S in
   S = {MakeLockedObject NewLock Stack init()}
   {S push(42)}
   {Browse {S length($)}}
   {Browse {S exchange(32 $)}}
end

% never mind, this works... The Lock does not extend to internal calls (of course ==')
% Let's do another stack then

declare
class LockedStack
   attr head n mylock
   meth init(NewLock)
      head := nil
      n := 0
      mylock := {NewLock}
   end
   meth push(X)
      {@mylock proc{$}
		  head := X|@head
		  n := @n + 1
	       end}
   end
   meth pop(?R)
      {@mylock proc{$}
		  case @head of H|T then R=H head:=T end
		  n := @n - 1
	       end}
   end
   meth length(?R)
      R = @n
   end
   % new operations
   meth exchange(X ?R)
      {@mylock proc{$}
		  {self pop(R)}
		  {self push(X)}
	       end}
   end
end

local S in
   S = {New LockedStack init(NewLock)}
   {S push(42)}
   {Browse {S length($)}}
   {Browse {S exchange(32 $)}} % wow, it doesn't work :o
end


% We need a new kind of Lock: the Reentrant lock!
declare
fun {NewReentrantLock}
   C CurThread in
   {NewCell unit C}
   {NewCell none CurThread} % remember the current thread
   proc {$ P}
      if @CurThread == {Thread.this} then {P}
      else New Old in
	 {Exchange C Old New}
	 {Wait Old}
	 CurThread := {Thread.this}
	 {P}
	 CurThread := none
	 New = unit
      end
   end
end

% let's see if the problem is fixed...
local S in
   S = {New LockedStack init(NewReentrantLock)}
   {S push(42)}
   {Browse {S length($)}}
   {Browse {S exchange(32 $)}} % yay, it works!
end

% let us test if the lock actually works
{HardTest {MakeLockedObject NewReentrantLock Queue init()}}

% Conclusion: reentrant locks are the future!



% Let us solve the Hamming Problem, now
% Goal: create a (lazy) stream with al the number which can be written as a*2+b*3+c*5, a,b,c being integers
declare
fun lazy {Hamming}
   % simple multiplier transducer
   fun lazy {Multiplier P Xs}
      case Xs of X|Xr then X*P|{Multiplier P Xr} end
   end
   % merge transducer
   fun lazy {Merge Xs Ys}
      case Xs#Ys of nil#_ then nil
      [] _#nil then nil
      [] (X|Xr)#(Y|Yr) then
	 if X>Y then Y|{Merge Xs Yr}
	 elseif X<Y then X|{Merge Xr Ys}
	 else X|{Merge Xr Yr}
	 end
      end
   end
   OutStream
in
   OutStream = 1|{Merge {Multiplier 2 OutStream} {Merge {Multiplier 3 OutStream} {Multiplier 5 OutStream}}}
end

% tests
declare
H = {Hamming}
proc {Touch N L} if N==0 then skip else {Touch N-1 L.2} end end
proc {HTouch N} {Touch N H} end

{Browse H}
% *do some HTouch here*
{HTouch 100}


% simple Hamming is too simple, let's do some fun stuff
% generalization to any set of numbers (as a list)
declare
fun {GeneralHamming Numbers}
   %% COPY-PASTING CODE LEADS TO HELL
   % simple multiplier transducer
   fun lazy {Multiplier P Xs}
      case Xs of X|Xr then X*P|{Multiplier P Xr} end
   end
   % merge transducer
   fun lazy {Merge Xs Ys}
      case Xs#Ys of nil#_ then nil
      [] _#nil then nil
      [] (X|Xr)#(Y|Yr) then
	 if X>Y then Y|{Merge Xs Yr}
	 elseif X<Y then X|{Merge Xr Ys}
	 else X|{Merge Xr Yr}
	 end
      end
   end
   % merge-chain of multipliers all linked to OutStream
   fun lazy {MergeChain Numbers}
      case Numbers of N1|N2|nil then
	 {Merge {Multiplier N1 OutStream} {Multiplier N2 OutStream}}
      [] N1|Ns then
	 {Merge {Multiplier N1 OutStream} {MergeChain Ns}}
      end
   end
   OutStream
in
   OutStream = 1|{MergeChain Numbers}
end

% tests
declare
H = {GeneralHamming [2 3 5 7 11 13 17]}
proc {Touch N L} if N==0 orelse L==nil then skip else {Touch N-1 L.2} end end
proc {HTouch N} {Touch N H} end

{Browse H}
% *do some HTouch here*
{HTouch 1250}


% Let's now generate some primes lazily using Eratosthenes' sieve

declare
fun lazy {Primes}
   % lazy agent filtering dividable elements
   fun lazy {Filter N Xs}
      case Xs of X|Xr then
	 if (X mod N)==0 then {Filter N Xr}
	 else X|{Filter N Xr} end
      end
   end

   fun lazy {Ints I}
      I|{Ints I+1}
   end

   fun lazy {SubPrimes Xs}
      case Xs of X|Xr then
	 X|{SubPrimes {Filter X Xr}}
      end
   end

in
   {SubPrimes {Ints 2}}
end

declare
P = {Primes}
{Browse P}

{Touch 1200 P}



% Some sort algorithm

% Merge Sort
% idea: split the list in two lists of smaller length, sort them, then merge them
declare
fun {MergeSort L}
   proc {Split L ?L1 ?L2}
      case L of X|Y|R then R1 R2 in
	 L1=X|R1  L2=Y|R2
	 {Split R R1 R2}
      [] X|nil then L1=[X] L2=nil
      [] nil then L1=nil L2=nil
      end
   end

   fun {Merge L1 L2}
      case L1#L2 of (X1|Xr)#(Y1|Yr) then
	 if X1>Y1 then Y1|{Merge L1 Yr}
	 elseif X1<Y1 then X1|{Merge Xr L2}
	 else X1|Y1|{Merge Xr Yr}
	 end
      [] X#nil then X
      [] nil#Y then Y
      end
   end

in
   case L of nil then nil
   [] X|nil then [X]
   else L1 L2 in
      {Split L L1 L2}
      {Merge {MergeSort L1} {MergeSort L2}}
   end
end

{Browse {MergeSort [5 4 3 2 1]}} % it works!



% Quick Sort
% idea: choose a number X, and create two lists: {L<X} and {L>=X}. Sort these lists, and simply append them.
declare
fun lazy {QuickSort L}
   proc {Split L X ?L1 ?L2}
      case L of H|T then R1 R2 in
	 if H<X then L1=H|R1 L2=R2
	        else L1=R1   L2=H|R2 end
	 {Split T X R1 R2}
      [] nil then L1=nil L2=nil end
   end

   fun lazy {Append L1 L2}
      case L1 of H|T then H|{Append T L2}
      [] nil then L2
      end
   end

in
   case L of nil then nil
   [] X|T then L1 L2 in
      {Split T X L1 L2}
      {Append {QuickSort L1} X|{QuickSort L2}}
   end
end

declare
L = {QuickSort [1 3 0 ~5 6 1 8 9 2 10 3]}

L = {Browse}
L = {Touch 5}



% Logic gates
declare

% general gate generator
fun {GateMaker F}
   fun {$ Xs Ys}
      fun {SubGate Xs Ys}
	 case Xs#Ys of (X|Xr)#(Y|Yr) then
	    {F X Y}|{SubGate Xr Yr}
	 else
	    nil
	 end
      end
   in
      thread {SubGate Xs Ys} end
   end
end

AndGate = {GateMaker fun {$ X Y} X*Y end}
OrGate  = {GateMaker fun {$ X Y} X+Y-X*Y end}
XorGate = {GateMaker fun {$ X Y} X+Y-2*X*Y end}

fun {NotGate Xs}
   fun {Sub Xs}
      case Xs of X|T then (1-X)|{Sub T}
      [] nil then nil end
   end
in
   thread {Sub Xs} end
end

% the delay for digital sequential logic
fun {Delay Xs}
   fun {SubDelay Xs}
      0|Xs
   end
in
   thread {SubDelay Xs} end
end


% bit adder
declare
% X+Y+Z = S+2*Cout
proc {FullAdderCircuit X Y Z S Cout}
   A in
   A = {XorGate X Y}
   Cout = {OrGate {AndGate X Y} {AndGate A Z}}
   S = {XorGate A Z}
end

proc {FullAdderMath X Y Z ?S ?Cout}
   proc {Sub Xs Ys Zs Ss Couts}
      case Xs#Ys#Zs of (X|Xr)#(Y|Yr)#(Z|Zr) then R=X+Y+Z S1 C1 in
	 Ss = (R mod 2)|S1
	 Couts = (R div 2)|C1
	 {Sub Xr Yr Zr S1 C1}
      else Ss=nil Couts=nil end
   end
in
   thread {Sub X Y Z S Cout} end
end

% let us compare those
declare
fun {RandStream N}
   if N>0 then ({OS.rand} mod 2)|{RandStream N-1} else nil end
end

local S1 S2 S3 in
   S1 = {RandStream 10}
   S2 = {RandStream 10}
   S3 = {RandStream 10}
   {Browse {FullAdderCircuit S1 S2 S3 $ _}}
   {Browse {FullAdderMath S1 S2 S3 $ _}}
end

% They are equivalent!

% Now, let's try and build the Nbit adder
% data-driven
declare
proc {NbitAdder Xs Ys Ci Ss Co}
   case Xs#Ys of (X|Xr)#(Y|Yr) then Cnew S Sr in
      {FullAdderCircuit X Y Cnew S Co}
      thread Ss = S|Sr end
      {NbitAdder Xr Yr Ci Sr Cnew}
   else Ss=nil Co=Ci end
end

declare S C
{NbitAdder [1|_ 1|_ 0|_ 1|_] [0|_ 1|_ 0|_ 1|_] 1|_ S C}
{Browse S#C}


% PVR test
declare A3 A2 A1 A0 B3 B2 B1 B0 Ci Co S3 S2 S1 S0 in
{NbitAdder [A3 A2 A1 A0] [B3 B2 B1 B0] Ci [S3 S2 S1 S0] Co}
{Browse [A3 A2 A1 A0]}
{Browse [B3 B2 B1 B0]}
{Browse [S3 S2 S1 S0]}
{Browse Co}

% Example addition: 7+5=12 in binary (0111)_2 + (0101)_2 = (1100)_2
A3=0|1|_
A2=1|0|_
A1=1|1|_
A0=1|1|_
B3=0|1|_
B2=1|1|_
B1=0|0|_
B0=1|0|_
Ci=0|1|_

% IT WOOOOOOOOOOOOOOOOOOOOOOOOOOOORKS




% Working with data-driven flow is boring: let us redefine all as lazy

declare
proc {GateMaker F ?Gate} % much easier!
   fun lazy {Gate Xs Ys}
      case Xs#Ys of (X|Xr)#(Y|Yr) then
	 {F X Y}|{Gate Xr Yr}
      else nil end
   end
end
AndGate = {GateMaker fun {$ X Y} X*Y end}
OrGate  = {GateMaker fun {$ X Y} X+Y-X*Y end}
XorGate = {GateMaker fun {$ X Y} X+Y-2*X*Y end}

fun lazy {NotGate Xs} % so easy
   case Xs of X|Xr then (1-X)|{NotGate Xr} else nil end
end

fun lazy {Delay Xs} % izzy (osbourne) (It's ffunny cause I'm listening to November Rain)
   0|Xs
end

declare

% This cannot be defined ad lazy, yet it implicitely will be (!)
proc {FullAdderCircuitLazy X Y Z S Cout}
   A in
   A = {XorGate X Y}
   Cout = {OrGate {AndGate X Y} {AndGate A Z}}
   S = {XorGate A Z}
end

% this is more complicated...
% for now, we'll make it lazy on the Sum output (not the carry :/)
fun lazy {FullAdderMathLazy Xs Ys Zs ?Cout}
   case Xs#Ys#Zs of (X|Xr)#(Y|Yr)#(Z|Zr) then R=X+Y+Z C1 in
      Cout = (R div 2)|C1
      (R mod 2)|{FullAdderMath Xr Yr Zr C1}
  else Cout=nil nil end
end

fun lazy {RandStream}
   ({OS.rand} mod 2)|{RandStream}
end


declare L1 C1 L2 C2
S1 = {RandStream}
S2 = {RandStream}
S3 = {RandStream }

{FullAdderCircuitLazy S1 S2 S3 L1 C1}
L2 = {FullAdderMathLazy S1 S2 S3 C2}
{Browse l1#L1}
{Browse l2#L2}
{Browse c1#C1}
{Browse c2#C2}

L1 = {Touch 1000}
L2 = {Touch 1000}
C1 = {Touch 1000}


% it works!