% Nondeterministic choice (WaitTwo)

% This is the WaitTwo operation, which is needed by the
% nondeterministic concurrent model.  The function call
% {WaitTwo X Y} waits until at least one of X and Y is determined.
% It can return 1 if X is determined and 2 if Y is determined.
% (If both are determined, it can return either 1 or 2.)
declare
fun {WaitTwo X Y}
   {Record.waitOr X#Y}
end


declare X Y in
{Browse {WaitTwo X Y}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Ports

declare P S in
P={NewPort S}
{Browse S}

{Send P a}

thread {Send P b} end
thread {Send P c} end

thread {Delay 10} {Send P d} end
thread {Send P e} end

% Port object (agent) = port + thread + recursive function

% Simple counter port object

declare P S F Loop in
P={NewPort S}
fun {F Msg State}
   % Returns new state
   case Msg
   of inc(X) then State+X
   [] get(X) then X=State State
   [] dec(X) then State-X
   end
end
proc {Loop S State}
   case S of Msg|S2 then
      {Loop S2 {F Msg State}}
   end
end
thread {Loop S 0} end % Port object is sequential internally

{Send P inc(10)}
local X in {Send P get(X)} {Browse X} end

{Send P inc(100)}
local X in {Send P get(X)} {Browse X} end

thread {Send P inc(9)} end
thread {Send P inc(111)} end

% Port object abstraction
% Init = initial state
% Func = function: (Msg x State) -> State
declare
fun {NewPortObject Func Init}
   proc {Loop S State}
      case S of Msg|S2 then
	 {Loop S2 {Func Msg State}}
      end
   end
   P S
in
   P={NewPort S}
   thread {Loop S Init} end % Port object is sequential internally
   P
end

% Simple counter object
declare
Ctr={NewPortObject
     fun {$ Msg State}
	case Msg
	of inc(X) then State+X
	[] get(X) then X=State State
	[] dec(X) then State-X
	end
     end
     0}

local X in {Send Ctr get(X)} {Browse X} end
{Send Ctr inc(123)}

% Port object is really an object
% Analogy to a object in object-oriented programming
% Function = class
% Each case = method
% Pattern = method head
% Only difference with classes is syntax

% Note difference in execution: port object is concurrent
% Port object = active object (runs in its own thread)
% Standard object = passive object (runs in caller's thread)
% Port object behaves correctly with concurrent invocations!

% Active objects natural in concurrent setting
% Language: Erlang based on active objects ("processes")
% It is natural for concurrent distributed programming
% Angry Birds uses Erlang for its central server
% Scala (successor to Java) => Akka library (Erlang functionality)

% Simple example of a multi-agent program: playing ball

% Defining the function
declare F Players P1 P2 P3 in
Players=rec(P1 P2 P3)
fun {F Msg State}
   case Msg
   of ball then RanP in
      % Pick a random player
      RanP=Players.( ({OS.rand} mod {Width Players})+1)
      {Send RanP ball}
      % Increment state
      State+1
   [] get(X) then X=State State
   end
end
P1={NewPortObject F 0}
P2={NewPortObject F 0}
P3={NewPortObject F 0}

local X in {Send P1 get(X)} {Browse X} end
{Send P1 ball}

for I in 1..10 do
   {Delay 1000}
   {Browse {Send P1 get($)}}
end

% Message protocols

% Port object without state
declare
fun {NewPortObject2 Proc}
   P S
in
   {NewPort S P}
   thread
      % A loop that waits for elements appearing in S
      for M in S do {Proc M} end
   end
   P
end


% RMI (Synchronous version)
declare
proc {ServerProc Msg}
   case Msg
   of calc(X Y) then
      Y=X*X*X+123.3*X*X+23.0*X+23.3
   end
end
Server={NewPortObject2 ServerProc}

declare
proc {ClientProc Msg}
   case Msg
   of work(Y) then Y1 Y2 in
      {Send Server calc(10.0 Y1)}
      {Wait Y1}
      {Send Server calc(20.0 Y2)}
      {Wait Y2}
      Y=Y1+Y2
   end
end
Client={NewPortObject2 ClientProc}

declare Y in
{Send Client work(Y)}
{Wait Y}
{Browse Y}

% Asynchronous RMI
declare
proc {ClientProc Msg}
   case Msg
   of work(Y) then Y1 Y2 in
      {Send Server calc(10.0 Y1)}
      {Send Server calc(20.0 Y2)}
%      {Wait Y1}
%      {Wait Y2}
      Y=Y1+Y2
   end
end
Client2={NewPortObject2 ClientProc}

% Use the same server as before, same client interface as before
% Only the client itself has changed
declare Y in
{Send Client2 work(Y)}
{Wait Y}
{Browse Y}

% RMI with callback
declare
proc {ServerProc Msg}
   case Msg
   of calc(X Y Client) then D in
      {Send Client delta(D)}
      Y=X*X*12.3+23.33*X+34.4*D*X+232.2
   end
end
Server={NewPortObject2 ServerProc}

% Incorrect version of client
declare
proc {ClientProc Msg}
   case Msg
   of work(Y) then Z in
      {Send Server calc(10.0 Z Client)}
      Y=Z+100.0
   [] delta(D) then
      D=0.01
   end
end
Client={NewPortObject2 ClientProc}

declare Y in
{Send Client work(Y)}
{Browse Y}

% Correct version of client (uses threads)
% Best fix - simplest (only if threads are cheap!)
declare
proc {ClientProc Msg}
   case Msg
   of work(Y) then Z in
      {Send Server calc(10.0 Z Client)}
      thread Y=Z+100.0 end
   [] delta(D) then
      D=0.01
   end
end
Client={NewPortObject2 ClientProc}

declare Y in
{Send Client work(Y)}
{Browse Y}

% Another correct version (uses continuations)
% This one is useful if threads are expensive
% It's a little bit more complicated
declare
proc {ServerProc Msg}
   case Msg
   of calc(X Y Client Cont) then D in
      {Send Client delta(D)}
      Y=X*X*12.3+23.33*X+34.4*D*X+232.2
      {Send Client Cont}
   end
end
Server={NewPortObject2 ServerProc}

declare
proc {ClientProc Msg}
   case Msg
   of work(Y) then Z in
      {Send Server calc(10.0 Z Client cont(Y Z))}
      % Y=Z+100.0
   [] delta(D) then
      D=0.01
   [] cont(Y Z) then
      Y=Z+100.0
   end
end
Client={NewPortObject2 ClientProc}

declare Y in
{Send Client work(Y)}
{Browse Y}