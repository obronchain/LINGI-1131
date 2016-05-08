% Lab 11: explicit state and objects


% Exercice 1
declare
A={NewCell 0}
B={NewCell 0}
T1=@A
T2=@B
{Show A==B} % a: What will be printed here % true, false, A, B or 0?
{Show T1==T2} % b: What will be printed here % true, false, A, B or 0?
{Show T1=T2} % b: What will be printed here % true, false, A, B or 0?
A:=@B
{Show A==B} % b: What will be printed here % true, false, A, B or 0?

% Answer:
% a) false
% b) true
% c) 0
% d) false


% Exercice 2
declare
fun {NewPortObject Fun Init}
   proc {MsgLoop S1 State}
      case S1 of Msg|S2 then
	 {MsgLoop S2 {Fun Msg State}}
      [] nil then skip
      end
   end
   Sin
in
   thread {MsgLoop Sin Init} end
   {NewPort Sin}
end

fun {NewCell2}
   fun {Behaviour Msg State}
      case Msg
      of access(R) then R=State State
      [] assign(E) then E
      end
   end
in
   {NewPortObject Behaviour nil}
end

proc {Access C R}
   {Send C access(R)}
end

proc {Assign C E}
   {Send C assign(E)}
end


declare
A
C = {NewCell2}
{Assign C 40}
{Assign C 50}
{Access C A}
{Browse A}


% Exercice 3
declare
fun {NewPort2 S}
   {NewCell S}
end

proc {Send2 C Msg}
   C := @C|Msg
end

% tests 1
declare
P S in
P = {NewPort2 S}
{Send2 P 7}
{Browse @P}

% tests 2
declare
P S
in
P = {NewPort2 S}
{Browse S#P}
{Send P 1}
{Send P 2}
{Send P 3} % S = 1|2|3|_ 


% Exercice 4
% flemme...


% Exercice 5
declare
fun {Q A B}
   Res
in
   Res = {NewCell 0}
   for I in A+1..B do
      Res := @Res+I
   end
   @Res
end

declare
{Browse {Q 3 8}}


% Exercice 6
% a)
declare
class Counter
   attr state
   meth init(Val)
      state := Val
   end
   meth add(N)
      state := @state+N
   end
   meth read(N)
      N = @state
   end
end

declare
C = {New Counter init(0)}
{C add(4)}
{Browse {C read($)}}

% b)
declare
class Port
   attr stream
   meth init(S)
      S := @stream
   end
   meth send(X)
      A B in
      A|B = @stream
      stream := B
      A = X
   end
end

fun {NewPort S P}
   {NewPort P init(S)}
end

fun {Send Msg P}
   {P send(Msg)}
end

% c)
declare
class PortClose %from Port?
...
end


   
