%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This is a review for Monitors implementation%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
declare
fun{NewQueu}
   X in
   q(0 X X)
end

fun{Insert q(N S E) X}
   E1 in
   E = X|E1
   q(N+1 S E)
end

fun{DeleteNonBlock q(N S E) X}
   if N>0 then S1 H in
      X = [H] S=H|S1 q(N-1 S1 E)
   else
      X=nil q(N S E)
   end
end

fun{DeleteAll q(N S E) X}
   X1 in
   X = S
   E = nil
   q(0 X1 X1)
end

proc{NewMonitor LockM WaitM NotifyM NotifyAll}
   Q = {NewCell {NewQueu}}
   Token1 = {NewCell unit}
   Token2 = {NewCell unit}
   CurThr = {NewCell unit}
   fun{GetLock}
      if {Thread.this}== @CurThr then false
      else
	 Old New in
	 {Exchange Token1 Old New}
	 {Wait Old}
	 Token2:=New
	 CurThr := {Thread.this}
	 true
      end
   end
   proc{ReleaseLock}
      CurThr:=unit
      unit=@Token2
   end
in
   proc{LockM P}
      if {GetLock}then
	 try {P} finally {ReleaseLock} end
      else
	 {P}
      end
   end

   proc{WaitM}
      X in
      Q:={Insert @Q X}
      {ReleaseLock}
      {Wait X}
      if {GetLock} then skip end
   end

   proc{NotifyM}
      X in
      Q:={DeleteNonBlock @Q X}
      case X of [U] then U = unit
      else skip end
   end
   
   proc{NotifyAll}
      L in
      Q:={DeleteAll @Q L}
      {ForAll L proc{$ X} X=unit end}
   end
end

proc{MakeMvar Put Get }
   Box = {NewCell unit}
   LockM NotifyM NotifyAll WaitM
in
   {NewMonitor LockM WaitM NotifyM NotifyAll}
   proc{Put X}
      {LockM proc{$}
		if @Box==unit then Box:=X {NotifyM}
		else
		   {WaitM}
		   {Put X}
		end
	     end
      }
   end
   proc{Get X}
      {LockM proc{$}
		if @Box\=unit then X=@Box Box:=unit {NotifyM}
		else
		   {WaitM}
		   {Get X}
		end
	     end
      }
   end
end

local Put Get in
   {MakeMvar Put Get }
   thread {Put 4} end 
   thread {Put 3} end 
   thread {Browse {Get $}} end 
   thread {Put 43} end 
   thread {Browse {Get $}} end 
   thread {Browse {Get $}}end 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    Implementation FullAdder    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
fun{GateMaker F}
   fun{Loop X Y}
      case X|Y of
	 (H1|T1)|(H2|T2) then
	 {F H1 H2}|{Loop T1 T2}
      end
   end
in
   fun{$ X Y}
      thread {Loop X Y} end 
   end
end

AndGate={GateMaker fun{$ X Y} X*Y end}
OrGate = {GateMaker fun{$ X Y} X+Y-(X*Y) end}
XorGate = {GateMaker fun{$ X Y} X+Y-(2*X*Y) end}
fun{NotGateMaker}
   fun{Loop X}
      case X of H|T then
	 ((H+1)mod 2)|{Loop T}
      end
   end
in
   fun{$ X}
      thread {Loop X} end
   end
end

fun{DelayGate X}
   0|X
end
NotGate = {NotGateMaker}

proc{FullAdder X Y Z Ci Co}
   A B C D E in
   A = {AndGate X Ci}
   B = {AndGate Y Ci}
   C = {AndGate X Y}
   D = {OrGate A B}
   Co = {OrGate C D}
   E = {XorGate X Y}
   Z = {XorGate Ci E}
end

local
   X = 1|1|0|0|_
   Y = 0|1|0|1|_
   Ci = 0|0|0|1|_
   Co
   Z
in
   {FullAdder X Y Z Ci Co}
   {Browse Z}
   {Browse Co}
end

declare
proc{NBitFullAdder A B Ci Co S}
   Cm X Sl in
   case A|B of
      (H1|T1)|(H2|T2) then
      {FullAdder H1|_ H2|_ X Cm Co}
      {NBitFullAdder T1 T2 Ci Cm Sl}
      S = thread X.1 end|Sl
   [] nil|nil then Co=Ci S=nil
   end
end


local
   A = [0 1 0 1 0]
   B = [0 0 0 0 1]
   Ci = 1|_
   Co
   Z
in
   Z ={NBitFullAdder A B Ci Co}
   {Browse Z}
end


declare
proc{Latch X C Z}
   I F G H in
   I = {NotGate C}
   H = {AndGate I X}
   G = {AndGate C F}
   Z = {OrGate G H}
   F = {DelayGate Z}
end

local
   X = 0|1|1|1|0|0|0|0|_
   C = 0|0|0|0|1|1|0|0|_
   Z
in
   {Browse X}
   {Browse C}
   {Browse {Latch X C $ }}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        Hamming Problem        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
declare 
fun lazy {Times N L}
   case L of H|T
   then H*N|{Times N T}
   end
end

fun lazy {Merge L1 L2}
   case L1|L2 of
      (H1|T1)|(H2|T2) then
      if H1<H2 then H1|{Merge T1 L2}
      elseif H1>H2 then H2|{Merge L1 T2}
      else H1|{Merge T1 T2}
      end
   end
end
proc{Touch L N}
   if N==0 then skip
   else
      {Touch L.2 N-1}
   end
end

local
   H
   X
in
   H = 1|{Merge {Times 2 H} {Merge {Times 3 H} {Times 5 H}}}
   {Browse H}
   {Browse H.2}
   {Browse H.2.2}
end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         EndThread            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ZeroSum
declare
proc{ZeroSum L N}
   case L of H|T then
      if H+N \=0 then {ZeroSum T H+N}
      else
	 skip
      end
   end 
end

proc{NewThread P SubThread}
   S Pt={NewPort S}
in
   proc{SubThread P}
      {Send Pt 1}
      thread
	 try {P}
	 finally
	    {Send Pt ~1}
	 end
      end
   end
   {SubThread P}
   {ZeroSum S 0}
end

local
   Sub
in
   P = proc{$}
	  {Sub proc{$} {Delay {OS.rand}mod 5000} {Browse a} end }
	  {Sub proc{$} {Delay {OS.rand}mod 5000} {Browse b} end }
	  {Sub proc{$} {Delay {OS.rand}mod 5000} {Browse c} end }
       end
   {NewThread P Sub}
   {Browse 'c est finit'}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      Flavius Josephus Problem       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% With PortObject in order to change from
% the course

declare
fun{NewPortObject Behaviour Init}
   S P
   proc{Loop L State}
      case L of Msg|T then
	 {Loop T {Behaviour Msg State}}
      end
   end
in
   thread {Loop S Init} end
   {NewPort S P}
   P
end

fun{VictimBehaviour Msg '#'(Next Id N State Last)}
    case Msg of 
       kill(X S) then
       if State==alive then
	  if S==1 then Last=Id
	  elseif X mod N\=0 then {Send Next kill(X+1 S)} '#'(Next Id N alive Last)
	  else
	     {Send Next kill(X+1 S-1)} '#'(Next Id N dead Last)
	  end
       else
	  {Send Next kill(X S)} '#'(Next Id N State Last)
       end
    end
end

fun{Josephus N Step}
   L = {MakeTuple victim N}
   Last in
   for I in 0..N-1 do
      L.(I+1)={NewPortObject VictimBehaviour '#'(L.((I+1) mod N +1) I Step alive Last)}
   end
   {Send L.1 kill(0 N)}
   Last+1 % because in the problem, ID is 1->10 and not 0->9
end

{Browse {Josephus 11 3}}

   

	     
	     