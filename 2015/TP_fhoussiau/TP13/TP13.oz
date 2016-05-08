%%% TP 13

%% Q1
declare
proc {NewPort2 S P}
   P = {NewCell S}
end
proc {Send2 P Msg}
   NewTail
in
   @P = Msg|NewTail
   P := NewTail
end

% correct: yes. it works
declare
proc {SBrowse S} case S of H|T then {Browse H} {SBrowse T} else skip end end

local Sin Pin in
   thread {SBrowse Sin} end
   Pin = {NewPort2 Sin}
   {Send2 Pin hello}
   {Send2 Pin world}
end

% race conditions: unfortunately, they exist :-(
% example:
%  T1 and T2 executing a send simultaneously
% T1: (1) @P = Msg1|NewTail1
% T2: (2) @P = Msg2|NewTail2
%  --> if Msg1 != Msg2 then IT CRASHES
%  otherwise you are lucky, but it is corrupted

% We need a new paradigm, he!
% Just kidding, let's use the Exchange operation

declare
proc {SendSafe P Msg}
   S in
   S = {Exchange P Msg|S}
end

local Sin Pin in
   thread {SBrowse Sin} end
   Pin = {NewPort2 Sin}
   {SendSafe Pin hello}
   {SendSafe Pin world}
end



%% Q2

% buggy
declare
C = {NewCell 0}
for I in 1..10000 do
     % DOES NOT WORK SINCE X is unbound!
     % Thus, you can't bind X+1 :-P
   local X in X = (C := X+1) end
end
{Browse @C}

% Exchange used
declare
C = {NewCell 0}
for I in 1..10000 do
   thread local X in X = @C C:=X+1 end end
end
{Browse @C}
% But observable non-determinism!

% Solution?
declare
C = {NewCell 0}
for I in 1..100000 do
   thread
      local X Xplus in
	 Xplus = {Exchange C X}
	 Xplus = X+1
      end
   end
end
{Delay 1000}{Browse @C}
% ok, it works (the {Delay 1000} is compulsory since the main thread executes before all threads terminate)

%% Q3
declare
class BankAccount
   attr val locking
   meth init
      val := 0
      locking := {NewLock}
   end
   meth deposit(Amount)
      lock @locking then
	 val := (@val + Amount)
      end
   end
   meth withdraw(Amount)
      lock @locking then
	 val := (@val - Amount)
      end
   end
   meth getBalance($)
      lock @locking then
	 @val
      end
   end
end

% I added locks in order to make it easy to ensure that there were no race conditions.
% Otherwise, it is possible to use the mechanism used in Q2 for counter.

%% Q4
% The following function transfers money from 1 to 2
declare
proc {Transfer BA1 BA2 Money}
   {BA1 withdraw(Money)}
   {BA2 deposit(Money)}
end

% test it!
declare
BA1 = {New BankAccount init}
BA2 = {New BankAccount init}
for I in 1..1000 do
   thread
      {Transfer BA1 BA2 1}
   end
end
local X1 X2 in
   {Delay 2000}
   {BA1 getBalance(X1)}
   {BA2 getBalance(X2)}
   {Browse X1#X2}
end


%% Q5
declare
fun {NewQueue1 ?Enqueue ?Dequeue}
   X C={NewCell q(0 X X)}
   L = {NewLock}
in
   proc {Enqueue X}
      N S E1 in
      lock L then
	 q(N S X|E1) = @C
	 C:=q(N+1 S E1)
      end
   end
   proc {Dequeue ?X}
      N S1 E in
      lock L then
	 q(N X|S1 E) = @C
	 C:=q(N-1 S1 E)
      end
   end
end


fun {NewQueue2 ?Enqueue ?Dequeue}
   X C={NewCell q(0 X X)}
   L1 = {NewLock}
   L2 = {NewLock}
in
   proc {Enqueue X}
      N S E1 in
      lock L1 then
	 q(N S X|E1) = @C
	 C:=q(N+1 S E1)
      end
   end
   proc {Dequeue ?X}
      N S1 E in
      lock L2 then
	 q(N X|S1 E) = @C
	 C:=q(N-1 S1 E)
      end
   end
end

% to investigate
