% Lab 9: message passing


% Exercice 1
declare
fun {LaunchServer}
   S P
   {NewPort S P}
   proc {Helper S}
      case S of H|T then
	 case H of add(X Y R) then R=X+Y {Wait R}
	 [] pow(X Y R) then R=X*Y {Wait R} % faire pow au lieu de fois ...
	 [] 'div'(X Y R) then R=X/Y {Wait R}
	 else {Browse 'message not understood'}
	 end
	 {Helper T}
      end
   end
in
   thread {Helper S} end
   P
end

declare
A B N S
Res1 Res2 Res3 Res4 Res5 Res6

S = {LaunchServer}
{Send S add(321 345 Res1)}
thread {Browse Res1} end
{Show Res1}
{Browse 'done'}

{Send S pow(2 N Res2)}
N=8
{Show Res2}
{Browse Res2}

{Send S add(A B Res3)}
{Send S add(10 20 Res4)}
{Send S foo}
{Show Res4}
A=3
B = 0−A
{Send S 'div'(90 Res3 Res5)}
{Send S 'div'(90 Res4 Res6)}
{Show Res3}
{Show Res5}
{Show Res6}


% Exercice 2
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

%my function that helps Charlotte (min and max are not implemented)
fun {HelpCharlotte PortList}
   fun {HelpCharlotteHelper PortList State}
      case PortList of nil then State
      [] H|T then
	 local Beers in
	    {Send H ask(howmany:Beers)}
	    {HelpCharlotteHelper T state(tot:State.tot+Beers number:State.number+1 max:State.max min:State.min)}
	 end
      end
   end
in
   thread {HelpCharlotteHelper PortList state(tot:0 number:0 max:0 min:0)} end
end


declare
{Browse {HelpCharlotte {CreateUniversity 10}}}


% Exercice 3
declare
fun {NewPortObject Behaviour Init}
   proc {MsgLoop S1 State}
      case S1 of Msg|S2 then
	 {MsgLoop S2 {Behaviour Msg State}}
      [] nil then skip
      end
   end
   Sin
in
   thread {MsgLoop Sin Init} end
   {NewPort Sin}
end

declare
fun {Porter}
   fun {F Msg State}
      case Msg
      of getIn(N) then State+N
      [] getOut(N) then State-N
      [] getCount(N) then N=State %State %-> pas obligatoire... pourquoi?
      end
   end
in
   {NewPortObject F 0}
end

declare
C
A={Porter}
{Send A getIn(20)}
{Send A getOut(3)}
{Send A getCount(C)}
{Browse C}
{Send A getIn(5)}
{Browse {Send A getCount($)}}


% Exercice 4
declare
proc {Push S X}
   {Send S push(X)}
end

proc {Pop S X}
   {Send S pop(X)}
end

proc {IsEmpty S X}
   {Send S isEmpty(X)}
end

fun {NewStack}
   fun {F Msg State}
      case Msg
      of push(S X) then S|X
      [] pop(S) then case State of H|T then S=T H end
      [] isEmpty(S) then S = State==nil State
      end
   end
in
   {NewPortObject F 0}
end

declare
A
NS={NewStack}
{IsEmpty NS A}
