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
{Show A==B} % b: What will be printed here
% true, false, A, B or 0?

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

fun {NewCell}
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
C = {NewCell}
{Assign C 40}
{Assign C 50}
{Access C A}
{Browse A}