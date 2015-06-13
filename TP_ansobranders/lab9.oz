%lab9
%9/06/15
%ansobr


%1
declare
fun {LaunchServer}
   S P={NewPort S}
   proc {ExecutePort S}
      case S of H|T then
	 case H of add(X Y R) then R=X+Y
	 [] 'div'(X Y R) then if Y==0 then {Show 'div by 0'} else R = X div Y end
	 else {Show 'message not understood'}
	 end
	 {ExecutePort T}
      end 
   end
in
   thread {ExecutePort S} end
   P
end

declare
A B S
Res1 Res2 Res3 Res4 Res5 Res6

S = {LaunchServer}
{Send S add(321 345 Res1)}
{Wait Res1} {Show Res1}


{Send S add(A B Res3)}
{Send S add(10 20 Res4)}
{Send S foo}
thread {Wait Res4} {Show Res4} end
A = 3
B = 0-A
{Send S 'div'(90 Res3 Res5)}
{Send S 'div'(90 Res4 Res6)}
{Wait Res3} {Show Res3}
{Wait Res5} {Show Res5}
{Wait Res6} {Show Res6}


%2

%a RMI
declare
fun {StudentRMI}
   S
in
   thread
      for ask(howmany:Beers) in S do
	 Beers={OS.rand} mod 24
      end
   end
   {NewPort S}
end

fun {CreateUniversityRMI Size}
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

fun {CharlotteWorks Size}
   AskBeer Loop Min2 Max2 List in
   List={CreateUniversityRMI Size} %cree university

   fun {AskBeer P}
      Beers in
      {Send P ask(howmany:Beers)}
      Beers
   end

   fun {Min2 X Y} if X<Y then X else Y end end
   fun {Max2 X Y} if X>Y then X else Y end end
      
   fun {Loop L Av Min Max}
      case L of nil then [('Av'#(Av div Size)) ('Min'#Min) ('Max'#Max)]
      [] H|T then
	 N={AskBeer H} in
	 {Loop T Av+N {Min2 Min N} {Max2 Max N}}
      end
   end
   
   {Loop List 0 1000 0}
end


declare
N=15
{Browse {CharlotteWorks N}}



%b Callback
declare
fun {StudentCallBack}
   S
in
   thread
      for ask(howmany:P) in S do
	 {Send P {OS.rand} mod 24}
      end
   end
   {NewPort S}
end

fun {CreateUniversityCallBack Size}
   fun {CreateLoop I}
      if I =< Size then
	 {StudentCallBack}|{CreateLoop I+1}
      else
	 nil
      end
   end
in
   {CreateLoop 1}
end

fun {CharlotteWorks2 Size}
   AskBeer Loop Min2 Max2 List PCharlotte SCharlotte in
   List={CreateUniversityCallBack Size} %cree university
   PCharlotte = {NewPort SCharlotte}
   fun {Min2 X Y} if X<Y then X else Y end end
   fun {Max2 X Y} if X>Y then X else Y end end

   proc {AskBeer L}
      case L of H|T then {Send H ask(howmany:PCharlotte)} {AskBeer T}
      [] nil then skip end
   end
   
   fun {Loop S Av Min Max N}
      if N==Size then [('Av'#(Av div Size)) ('Min'#Min) ('Max'#Max)]
      else
	 case S of H|T then
	    {Loop T Av+H {Min2 Min H} {Max2 Max H} N+1}
	 end
      end
   end
   thread {AskBeer List} end
   thread {Loop SCharlotte 0 1000 0 0} end
end


declare
N=15
{Browse {CharlotteWorks2 N}}


%3
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

fun {PorterBehaviour Msg State}
   case Msg of getIn(N) then State+N
   [] getOut(N) then State-N
   [] getCount(N) then N=State State
   end
end

declare
Porter = {NewPortObject PorterBehaviour 0}
{Send Porter getIn(100)}
{Send Porter getOut(23)}
{Browse {Send Porter getCount($)}}



%4
declare
fun {NewStack}
   fun {StackBehaviour Msg State}
      case Msg of pop(X) then X=State State
      [] push(X) then X
      [] isEmpty(X) then X=(State==empty) State
      end
   end
in
   {NewPortObject StackBehaviour empty}
end

declare
Stack = {NewStack}
{Browse {Send Stack isEmpty($)}}
{Send Stack push(5)}
{Send Stack push(3)}
{Browse {Send Stack pop($)}}


%5
declare
fun {NewQueue}
   fun {QueueBehaviour Msg State}
      case Msg of enqueue(X) then {Append State [X]}
      [] dequeue(X) then X=State.1 State.2
      [] isEmpty(X) then X=(State==nil) State
      [] getElements(L) then L=State State
      end
   end
in
   {NewPortObject QueueBehaviour nil}
end

declare
Queue = {NewQueue}
{Browse {Send Queue isEmpty($)}}
{Send Queue enqueue(26)}
{Browse {Send Queue dequeue($)}}
{Send Queue enqueue(23)}
{Browse {Send Queue isEmpty($)}}
{Send Queue enqueue(22)}
{Send Queue enqueue(17)}
{Browse {Send Queue getElements($)}}


%6
declare
fun {Counter Output}
   fun {CounterBehaviour Msg State}
      fun {Compare L X}
	 case L of nil then [X#1]
	 [] (H#N)|T then
	    if X==H then (H#N+1)|T
	    else (H#N)|{Compare T X}
	    end
	 end
      end
      NewState
   in
      NewState={Compare State Msg}
      {Send Output NewState}
      NewState
   end
in
   {NewPortObject CounterBehaviour nil}
end

declare
S
Output={NewPort S}
Miners = {Counter Output}
thread {Browse S} end
{Send Miners c}
{Send Miners v}
{Send Miners c}
{Send Miners a}
{Send Miners s}
{Send Miners v}
{Send Miners a}





