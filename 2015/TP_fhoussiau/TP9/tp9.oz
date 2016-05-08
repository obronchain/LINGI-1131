%%% LAB 9

%% Exercise 1
declare
proc {LaunchServer ?P}
   fun {Power X Y A}
      if Y==0 then A else {Power X Y-1 A*X} end
   end
   
   proc {Treat S}
      case S of nil then skip
      [] H|T then
	 case H of add(X Y R) then R = X+Y
	 [] 'div'(X Y R) then if Y==0 then R=nan else R = X div Y end
	 [] pow(X Y R) then R = {Power X Y 1}
	 else
	    {Show 'message not understood'}
	 end
	 {Treat T}
      end
   end

   S % stream
in
   {NewPort S P}
   thread {Treat S} end
end


% additionnal function for test
proc {ShowT R}
%   {Browse R}
   thread
      {Wait R}
      {Show R}
   end
end

% test by PVR
declare
A B N S
Res1 Res2 Res3 Res4 Res5 Res6

S = {LaunchServer}
{Send S add(321 345 Res1)}
{ShowT Res1}

{Send S pow(2 N Res2)}
N = 8
{ShowT Res2}

{Send S add(A B Res3)}
{Send S add(10 20 Res4)}
{Send S foo}
{ShowT Res4}
A = 3
B = 0-A

{Send S 'div'(90 Res3 Res5)}
{Send S 'div'(90 Res4 Res6)}
{ShowT Res3}
{ShowT Res5}
{ShowT Res6}



%% Exercise 2

% I chose the RMI
declare
fun {StudentRMI}
   S
in
   thread
      for ask(howmany:Beers) in S do
	 Beers = {OS.rand} mod 24
      end
   end
   {NewPort S}
end

% my code:
declare
fun {Charlotte Students}
   % State: data(total n min max)
   fun {CharlotteLoop Students State}
      case Students of nil then State
      [] H|T then
	 NBeers in
	 {Send H ask(howmany:NBeers)}
	 % iterate
	 {CharlotteLoop T data(
			     total:State.total+NBeers
			     n:State.n+1
			     min:if NBeers<State.min then NBeers else State.min end
			     max:if NBeers>State.max then NBeers else State.max end)
	 }
      end
   end
in
   {CharlotteLoop Students state(total:0 n:0 min:0 max:0)}
end

% test by the prof
fun {CreateUniversity Size}
   fun {CreateLoop I}
      if I =< Size then
	 {StudentRMI}|{CreateLoop I+1}
      else
	 nil
      end
   end
in
   {CreateLoop 1}
end

% test!
local S P in
   S = {CreateUniversity 100}
   {Browse {Charlotte S}}
end



%% Exercise 3

declare
fun {NewPortObject B I}
   % a possible implementation of NPO
   proc {MsgLoop S1 State}
      case S1 of Msg|S2 then
	 {MsgLoop S2 {B Msg State}}
      [] nil then skip
      end
   end
   Sin
in
   thread {MsgLoop Sin I} end
   {NewPort Sin}
end

% my function
declare
fun {Porter Msg State}
   case Msg of
      getIn(N)    then State+N
   [] getOut(N)   then State-N
   [] getCount(N) then N=State State
   end
end

% test
local P in
   P = {NewPortObject Porter 0}
   {Send P getIn(10)}
   {Send P getOut(5)}
   local X in {Send P getCount(X)} {Browse X} end
end


%% Exercise 4
declare
fun {NewStack}
   fun {StackLoop Msg State}
       case Msg of
	  push(X) then X|State
       [] pop(R)  then R=State.1 State.2
       [] isempty(R) then R=(State==nil) State
       end
    end
in
   {NewPortObject
    StackLoop
    nil}
end

proc {Push S X}
   {Send S push(X)}
end
proc {Pop S ?R}
   {Send S pop(R)}
end
proc {IsEmpty S ?R}
   {Send S isempty(R)}
end

local S in
   S = {NewStack}
   {Push S hello}
   {Push S world}
   {Browse {Pop S}}
   {Browse {IsEmpty S}}
   {Browse {Pop S}}
   {Browse {IsEmpty S}}
end


%% Exercise 5
declare
fun {NewQ}
   fun {QLoop Msg State}
       case Msg of
	  enqueue(X) then {Append State X|nil}
       [] dequeue(R)  then R=State.1 State.2
       [] isempty(R) then R=(State==nil) State
       end
    end
in
   {NewPortObject
    QLoop
    nil}
end

proc {Enqueue S X}
   {Send S enqueue(X)}
end
proc {Dequeue S ?R}
   {Send S dequeue(R)}
end
proc {IsQEmpty S ?R}
   {Send S isempty(R)}
end

local S in
   S = {NewQ}
   {Enqueue S hello}
   {Enqueue S world}
   {Browse {Dequeue S}}
   {Browse {IsQEmpty S}}
   {Browse {Dequeue S}}
   {Browse {IsQEmpty S}}
end



%% Exercise 6
declare
% let's copy-paste some code
fun {Counter Output}
   fun {AddToState X State}
      case State of (A#B)|Rest then
	 if X==A then (A#(B+1))|Rest
	 else (A#B)|{AddToState X Rest} end
      [] nil then
	 [X#1]
      end
   end
   fun {Cloop Msg State}
      NS in
      NS = {AddToState Msg State}
      {Send Output NS}
      NS
   end
in
   {NewPortObject Cloop nil}
end

proc {Browser S}
   case S of nil then skip
   [] H|T then {Browse H} {Browser T}
   end
end


% test
local S O SO in
   {NewPort SO O}
   S = {Counter O}
   {Send S a}
   {Send S a}
   {Send S b}
   {Browser SO}
end
