declare
fun lazy {NFullAdder Xs Ys C}
   % as a stream: X and Y are streams, as is Z
   case Xs#Ys of nil#D then nil
   [] D#nil then nil
   [](X|Xr)#(Y|Yr) then R = X+Y+C in
      (R mod 2) | {NFullAdder Xr Yr (R div 2)}
   end
end


%% PVR's Full Adder
declare
proc {FullAdder X Y Z C S}
   thread R in R=X+Y+Z  C=(R div 2) S=(R mod 2) end
end
 
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
% with test
local S C in
   {NbitAdder [1 0 0 1] [1 1 0 1] 1 S C}
   {Browse S#C}
end


% Gate Maker "class"
fun lazy {GateMaker Op}
   % {Op <bool> <bool>} = <bool>
   % bool := 1|0
   fun {Gate X Y}
      case X#Y of nil#D then nil
      [] D#nil then nil
      [] (X|Xr)#(Y|Yr) then {Op X Y}|{Gate Xr Yr}
      end
   end
in
   Gate
end

fun lazy {DelayGate Xs}
   0|Xs
end

fun lazy {NotGate Xs}
   case Xs of nil then nil [] H|T then (1-H)|{NotGate T} end
end



AndGate = {GateMaker fun {$ X Y} X*Y end}
OrGate  = {GateMaker fun {$ X Y} X+Y-X*Y end}
XorGate = {GateMaker fun {$ X Y} X+Y-2*X*Y end}


% streams
fun lazy {Constant S}
   S|{Constant S}
end
fun lazy {Alternating V}
   V|{Alternating 1-V}
end
fun lazy {Sequence S}
   case S of nil then nil
   [] H|T then H|{Sequence T}
   end
end

% tests
proc {Touch L N}
   case L of nil then skip else
      if N>0 then {Touch L.2 N-1} end
   end
end

fun {Summer X}
   % little endian adder: the first bit received is the most significant
   fun {SubSum X A}
      case X of Xs|Xr then {SubSum Xr Xs+2*A}
      [] nil then A end
   end
in
   {SubSum X 0}
end

fun {IndianSummer X}
   % other summer: the last bit is most significant
   fun {SubSum X A Mul}
      case X of Xs|Xr then {SubSum Xr Xs*Mul+A 2*Mul}
      [] nil then A
      end
   end
in
   {SubSum X 0 1}
end

local
   In1 = {Sequence [1 1 1 1 1 1 1 1]}
   In2 = {Sequence [0 0 0 0 0 0 0 0]}
   Out = {NFullAdder In1 In2 0}
in
  % {Touch Out 10}
   {Browse 'input 1 '#In1}
   {Browse 'input 2 '#In2}
   {Browse 'output '#Out}
   {Delay 1000}
   {Browse 'sum '#{IndianSummer Out}}
end


% Make a combinatorial logic circuit
% basically, a circuit is a recursive record, with following syntax:
%  circuit := 'and'(circuit circuit) | 'or'(circuit circuit) | 'xor'(circuit circuit) | 'not'(circuit) | 'adder'(circuit circuit) | input
%  input   := 'input'(field)
% You must also define inputs to the circuits in a record whoses fields are the fields used in the above definition of input.
% This creates a stream (output stream of the circuit).

declare
fun {MakeCircuit Inputs Circuit}
   fun {SubMaker C} {MakeCircuit Inputs C} end
in
   case Circuit of
      and(C1 C2)   then {AndGate {SubMaker C1} {SubMaker C2}}
   [] 'or'(C1 C2)  then {OrGate {SubMaker C1} {SubMaker C2}}
   [] xor(C1 C2)   then {XorGate {SubMaker C1} {SubMaker C2}}
   [] 'not'(C1)    then {NotGate {SubMaker C1}}
   [] adder(C1 C2) then {NFullAdder {SubMaker C1} {SubMaker C2} 0}
   [] input(F)     then Inputs.F
   end
end


% tests
local Inputs=inputs(1:_ 2:_ 3:_) C in
   Inputs.1 = {Sequence [0 1 0 1 1 1 0]}
   Inputs.2 = {Alternating 1}
   Inputs.3 = {Constant 1}
   C = {MakeCircuit Inputs
	xor( adder( 'not'(input(1)) adder(input(2) input(1)) ) input(3))
       }
   {Browse created}
   {Touch C 10}
   {Browse C}
end






% add digits

% declare
% fun {AddDigit X Y C}
%    Sum = X+Y+C
% in
%    output(sum:(Sum mod 2) carry:(Sum div 2))
% end

% fun {Add X Y}
%    fun {SubAdd X Y PreviousC}
%       case X#Y of nil#D then nil
%       [] D#nil then nil
%       [] (X|Xr)#(Y|Yr) then
% 	 S C in output(sum:S carry:C) = {AddDigit X Y PreviousC}
% 	 S|{SubAdd Xr Yr C}
%       end
%    end
% in
%    {SubAdd X Y 0}
% end

% proc {AddWithGates X Y ?Out}
%    S1 S2 in
%    S1 = {Sequence X}
%    S2 = {Sequence Y}
%    Out = {NFullAdder S1 S2 0}
%    {Touch Out {Length X}+1}
% end

% local L1 L2 in
%    L1 = [1 1 1 0 1 1 0]
%    L2 = [1 0 1 0 1 0 1]
%    {Browse {Add L1 L2}}
%    {Browse {AddWithGates L1 L2}}
% end