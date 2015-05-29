
% Digital logic simulation

% Combinational logic

% One And gate (= "object")
declare
fun {AndLoop As Bs}
   case As|Bs
   of (A|Ar)|(B|Br) then
      (A*B)|{AndLoop Ar Br}
   end
end

declare As Bs Cs in
thread Cs={AndLoop As Bs} end
{Browse As}
{Browse Bs}
{Browse Cs}

% Let's give some input
As=0|1|0|_

Bs=1|1|_

% Let's generalize this using higher-order (= "class")
% This lets us create many and gates
declare
fun {AndGate As Bs}
   fun {AndLoop As Bs}
      case As|Bs
      of (A|Ar)|(B|Br) then
	 (A*B)|{AndLoop Ar Br}
      end
   end
in
   thread {AndLoop As Bs} end
end

declare Ds Es Fs in
Fs={AndGate Ds Es} % Create a new "object"
{Browse Ds}
{Browse Es}
{Browse Fs}

Ds=1|0|_
Es=1|1|_

% Let's create any kind of gate (= "metaclass")
declare
fun {GateMaker F}
   fun {$ As Bs}
      fun {GateLoop As Bs}
      case As|Bs
      of (A|Ar)|(B|Br) then
	 {F A B}|{GateLoop Ar Br}
      end
   end
   in
      thread {GateLoop As Bs} end
   end
end

declare
AndGate={GateMaker fun {$ A B} A*B end}
OrGate={GateMaker fun {$ A B} A+B-A*B end}
XorGate={GateMaker fun {$ A B} A+B-2*A*B end}

declare A B C in
C={XorGate A B}
{Browse A#B#C}
A=0|0|1|1|_
B=0|1|0|1|_

% Full Adder
declare
proc {FullAdder X Y Z C S}
   D E F G H
in
   D={AndGate X Y}
   E={AndGate X Z}
   F={AndGate Y Z}
   G={OrGate D E}
   C={OrGate G F}
   H={XorGate X Y}
   S={XorGate H Z}
end

% Example execution
declare X Y Z C S in
{FullAdder X Y Z C S}
{Browse X}
{Browse Y}
{Browse Z}
{Browse C}
{Browse S}

% Example addition: 1+1+0=(10)_2
X=1|_
Y=1|_
Z=0|_

% N-bit adder
declare
proc {NbitAdder Al Bl Ci Sl Co}
   case Al|Bl of (A|Am)|(B|Bm) then Cmid S Sm in
%      {FullAdder A B Cmid S Co}
      {FullAdder A B Cmid Co S}
      {NbitAdder Am Bm Ci Sm Cmid}
      Sl=S|Sm
   [] nil|nil then % Zero-bit adder
      Co=Ci
      Sl=nil
   end
end

% Let's create a 4-bit adder
% Calling the function NbitAdder builds the adder
declare A3 A2 A1 A0 B3 B2 B1 B0 Ci Co S3 S2 S1 S0 in
{NbitAdder [A3 A2 A1 A0] [B3 B2 B1 B0] Ci [S3 S2 S1 S0] Co}
{Browse [A3 A2 A1 A0]}
{Browse [B3 B2 B1 B0]}
{Browse [S3 S2 S1 S0]}
{Browse Co}

% Example addition: 7+5=12 in binary (0111)_2 + (0101)_2 = (1100)_2
A3=0|_
A2=1|_
A1=1|_
A0=1|_
B3=0|_
B2=1|_
B1=0|_
B0=1|_
Ci=0|_

% Sequential logic

% We need a delay gate
declare
fun {DelayGate X}
   0|X
end

% Not gate
declare
fun {NotGate X}
   fun {NotLoop X}
      case X of E|X2 then 1-E|{NotLoop X2} end
   end
in
   thread {NotLoop X} end
end


% Build a latch
declare
proc {Latch C Din Dout}
   F G H I
in
   F={DelayGate Dout}
   G={AndGate F C}
   I={NotGate C}
   H={AndGate I Din}
   Dout={OrGate G H}
end

declare Din C Dout in
{Latch C Din Dout}
{Browse Din}
{Browse C}
{Browse Dout}

Din=0|1|1|0|0|0|1|0|1|0|0|0|1|_
C=0|0|0|0|1|1|1|1|0|0|0|0|0|_


