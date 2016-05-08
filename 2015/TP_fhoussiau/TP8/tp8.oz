%% TP (8)

% (1)

declare
proc {ReadList L}
   case L of nil then skip
   [] H|T then {Browse H} {ReadList T} end
end



% (2)

declare
P S
{NewPort S P}
{Send P foo}
{Send P bar}
{Browse S}


% (3)

local P S in
   {NewPort S P}
   {Send P gotta}
   {Send P 'catch'}
   {Send P them}
   {Send P all}
   {ReadList S}
end



% (4)

declare
proc {RandomSenderManiac N P}
   for I in 1..N do
      thread {Delay 1000*(1+({OS.rand} mod 3))} {Send P I} end
   end
end

local P S in
   {NewPort S P}
   {RandomSenderManiac 10 P}
   {Browse S} % for fun
end


% (5)

local P S in
   {NewPort S P}
   {RandomSenderManiac 10 P}
   {ReadList S}
end
% oh my god, it's non-deterministic ("we need a new paradigm, he!" - PVR)



% (6) WaitTwo
declare
fun {WaitTwo X Y}
   P S in
   {NewPort S P}
   thread {Wait X} {Send P 1} end
   thread {Wait Y} {Send P 2} end
   case S of H|T then H end
end

local X Y in
   thread {Delay 3000} X=42 end
   thread {Delay 2000} Y=42 end
   {Browse waitedfor|{WaitTwo X Y}}
end

% it is NONDETERMINISTIC!
% and cannot be deterministic!


% (7)

declare
proc {Server S F}
   case S of (Msg#Ack)|T then
      {Delay 500+({OS.rand} mod 1001)}
      {F Msg}
      Ack = unit
      {Server T F}
   end
end

local P S X Y in
   {NewPort S P}
   thread {Server S Browse} end
   {Send P hello#X}
   {Wait X}
   {Send P world#Y}
end


% (8)

declare
fun {SafeSend P M T}
   Ack Timeout in
   {Send P M#Ack}
   thread {Delay T} Timeout=1 end
   {WaitTwo Ack Timeout} == 1
end

local P S in
   {NewPort S P}
   thread {Server S Browse} end
   {Browse result1#{SafeSend P hello 10}}
   {Browse result2#{SafeSend P world 2000}}
end



% (9)

% let's modify code from last TP

declare
fun {Counter Stream}
   
   % Add to the current state (deterministic)
   fun {AddToState X State}
      case State of (A#B)|Rest then
	 if X==A then (A#(B+1))|Rest
	 else (A#B)|{AddToState X Rest} end
      [] nil then
	 [X#1]
      end
   end

   % Add to the counter
   fun {SubCounter P1 State}
      case P1 of nil then State|nil
      [] H|T then
	 CurState in
	 CurState = {AddToState H State}
	 CurState|{SubCounter T CurState}
      end
   end
   
in
   % fully implement
   {SubCounter P1 nil}
end

% In fact, the code does not change. I feel stupid for copy-pasting.

% (a) that depends upon the order of execution of the threads, which is nondeterministic.
% (b) 42



% (10)

% (a) without ports
declare
fun {StreamMerger S1 S2}
   N in
   N = {WaitTwo S1 S2}
   if N==1 then
      case S1 of H|T then
	 H|thread {StreamMerger T S2} end
      else
	 nil
      end
   else
      case S2 of H|T then
	 H|thread {StreamMerger S1 T} end
      else
	 nil
      end
   end
end


% (b)
% nope, it is not. Nope, it does not.




declare % this works!
fun {StreamMergerP S1 S2} 
   proc {FSender S P}
      case S of H|T then {Send P H} {FSender T P} end
   end
   P S
in
   {NewPort S P}
   thread {FSender S1 P} end
   thread {FSender S2 P} end
   S
end



% tests

declare
fun {Gen I N}
   if I<N then {Delay 1000} I|{Gen I+1 N}
   else nil
   end
end

local S1 S2 in
   thread S1 = {Gen 1 10} end
   thread S2 = {Gen 32 42} end
   {Browse {StreamMerger S1 S2} }
end
