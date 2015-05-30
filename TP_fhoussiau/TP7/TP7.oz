%%% Oz 2 TP 7

%% (1)
declare
fun lazy {Ints N} N|{Ints N+1} end
fun lazy {Sum2 Xs Ys}
   case Xs#Ys of (X|Xr)#(Y|Yr) then (X+Y)|{Sum2 Xr Yr} end
end


S = 0|{Sum2 S {Ints 1}}

% (a) see for yourself
% {Browse S.2.2.1}

% (b) here you go
fun {Nth N L}
   if N<1 then L.1 else {Nth N-1 L.2} end
end

{Browse S}
{Browse {Nth 10 S}}
% this works because magic.

% (c)
declare
proc {LInts N R}
   thread
      {WaitNeeded R}
      local R1 NN in
	 NN = N+1
	 R = '|'(N R1)
	 {LInts NN R1}
      end
   end
end

proc {LSum2 Xs Ys Ss}
   thread
      {WaitNeeded Ss}
      case Xs#Ys of (X|Xr)#(Y|Yr) then SubS SubSs in
	 SubS = X+Y
	 Ss = SubS|SubSs
	 {LSum2 Xr Yr SubSs}
      end
   end
end

local S R L Zero One in
   Zero = 0
   One = 1
   S = '|'(Zero R)
   {Ints One L}
   {LSum2 S L R}
   % display
   {Browse S}
   {Browse S.2.2.1}
end

% (d) trolololololololololololololol


%% (2)

% (a) Cfr PROSTOC

% (b) Cfr Signals and Systems

% (c) trolololololololololololol

% Let's code a bit, this is getting boring

declare
fun lazy {OscStream X}
   X|{OscStream 1-X}
end

declare
fun lazy {CaroStream}
   0|1|{CaroStream}
end

declare
fun lazy {ConstantStream X}
   X|{ConstantStream X}
end


declare
fun lazy {DelayGate X Memory}
   case X of H|T then
      Memory|{DelayGate T H}
   [] nil then [Memory]
   end
end


declare
fun {GateMaker F}
   Gate in
   fun lazy {Gate X Y}
      case X#Y of (X1|Xr)#(Y1|Yr) then
	 {F X1 Y1}|{Gate Xr Yr}
      [] nil#nil then nil
      end
   end
   Gate
end

And = {GateMaker fun {$ X Y} X*Y end}
Or  = {GateMaker fun {$ X Y} X+Y-X*Y end}
 Xor = {GateMaker fun {$ X Y} if (X+Y)==1 then 1 else 0 end end}

% combinatorial logic
% 0101-----v
% 1111----AND--OR--->1111
% 0101--DELAY---^

local Out S in
   Out = {DelayGate {And {CaroStream} {ConstantStream 1}} 1} % 1|0|1|...
   S = {Or Out {CaroStream}}
   {Browse S}
   {Browse {Nth 10 S}}
end

% sequential logic
% 0101--->OR----XOR--->
%         ^      |
% 0101---AND--+  |
%         ^---+  |
%                |
% 1111-----------^

local Out S  in
   S = 1|{And {CaroStream} S}
   Out = {Xor {Or {CaroStream} S} {ConstantStream 1}}
   {Browse Out}
   {Browse {Nth 10 Out}}
end



%% (3)

declare
proc {Job Type Flag}
   {Delay {OS.rand} mod 1000}
   {Browse Type}
   Flag = unit
end

declare
proc {BuildPs N Ps}
   Ps = {Tuple.make '#' N}
   for I in 1..N do
      Type = {OS.rand} mod 10
      Flag
   in
      Ps.I = ps(type:Type
		job:proc {$} {Job Type Flag} end
		flag:Flag)
   end
end

local N Ps in
   N = 100
   Ps = {BuildPs N}
   for I in 1..N do
      thread {Ps.I.job} end
   end
   {WatchPs 3 Ps}
end

% let's work:
declare
proc {WatchPs I Ps}
   for J in 1..100 do
      if Ps.J.type == I then
	 {Wait Ps.J.flag} % wait for this one (this works since we wait for ALL to complete)
      end
   end
   % another correct, yet somewhat cheating, implementation
   % {Delay 1000}
   {Browse 'all the threads of type I are finished'}
end

% Good news, this seems to work (if it doesn't, enlarge Browser's buffer)



%% (4)
declare
proc {WaitOr X Y}
   R in
   thread {Wait X} R=1 end
   thread {Wait Y} R=1 end
   {Wait R}
end

% test
local X Y in
   thread {Delay 1500} X=42 {Browse 'X is done!'} end
   thread {Wait X} {Delay 1500} Y=37 {Browse 'Y is done!'} end
   {WaitOr X Y}
   {Browse 'Either X or Y is set!'}
end




%% (5)
declare
fun {WaitOrValue X Y}
   % declarative concurrency wait (does not work :/)
   R in
   thread {Wait X} R=X end
   thread {Wait Y} R=Y end
   {Wait R}
   R
end

declare
fun {WaitOrValue2 X Y}
   % does not REALLY work in case of race conditions :(
   C R in
   C = {NewCell 0}
   thread {Wait X} R=1 C:=X end
   thread {Wait Y} R=1 C:=Y end
   {Wait R}
   @C
end

declare
fun {WaitOrValue3 X Y}
   C R in
   C = {NewCell 0}
   thread {Wait X} if @C==0 then C:=1 R=X else skip end end
   thread {Wait Y} if @C==0 then C:=1 R=Y else skip end end
   {Wait R}
   R
end




% test
local X Y in
   thread {Delay 1500} X=42 {Browse 'X is done!'} end
   thread {Delay 1500} Y=37 {Browse 'Y is done!'} end
   {Browse {WaitOrValue3 X Y}}
   {Browse 'Either X or Y is set (to previously displayed value)!'}
end


% there does not seem to be a declarative concurrency approach able to solve this problem!
% (that's why we need a NEW paradigm, as would say PVR)



%% (6)
declare
fun {Counter P1}
   fun {AddToState X State}
      case State of (A#B)|Rest then
	 if X==A then (A#(B+1))|Rest
	 else (A#B)|{AddToState X Rest} end
      [] nil then
	 [X#1]
      end
   end
   
   fun {SubCounter P1 State}
      case P1 of nil then State|nil
      [] H|T then
	 CurState in
	 CurState = {AddToState H State}
	 CurState|{SubCounter T CurState}
      end
   end
in
   {SubCounter P1 nil}
end


{Browse {Counter [a b c a a b]}}


% let us generalize to N pipes

declare
fun {CounterN Pipes}
   fun {AddToState X State}
      case State of (A#B)|Rest then
	 if X==A then (A#(B+1))|Rest
	 else (A#B)|{AddToState X Rest} end
      [] nil then
	 [X#1]
      end
   end
   
   N = {Record.width Pipes}
   
   fun {MultiCounter I Pipes State}
      case Pipes.I of nil then {MultiCounter ((I+1) mod N) Pipes State}
      [] H|T then
	 CS in
	 CS = {AddToState H State}
	 CS|{MultiCounter ((I+1) mod N) Pipes CS}
      end

   end
   
in
   {MultiCounter 1 Pipes nil}
end

%test: %{Browse {Record.width a(1:hello 4:world)}}
%{Browse {CounterN pipes(0:[a b a b a b] 1:[a a a a] 2:[d e f])}}

% WARNING: does not work. Sorry.





% useless
fun {RungeKutta4 F T0 X0 Dt}
   K1 K2 K3 K4 in
   K1 = {F T0 X0}
   K2 = {F T0+Dt/2. X0+K1*Dt}
   K3 = {F T0+Dt/2. X0+K2*Dt}
   K4 = {F T0+Dt    X0+K4*Dt}
   (K1+K2*2.0+K3*2.0+K4)/6.0
end

