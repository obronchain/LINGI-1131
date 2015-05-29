%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  EXO1                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% le @ permet de recuperer la valeur a l'interrieur
% le := permet d'update la valeur mise dans la Cell
declare
A={NewCell 0}
B={NewCell 0}
T1=@A
T2=@B
{Show A==B} % a: What will be printed here
% true, false, A, B or 0? % false
{Show T1==T2} % b: What will be printed here
% true, false, A, B or 0? true 
{Show T1=T2} % b: What will be printed here
% true, false, A, B or 0? 0
A:=@B
{Show A==B} % b: What will be printed here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  EXO2                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
declare
proc {NewPortObject Init Fun ?P}
   proc {MsgLoop S1 State}
      
      case S1 of Msg|S2 then
	 {MsgLoop S2 {Fun Msg State}}
      [] nil then skip end
   end
   Sin
in
   thread {MsgLoop Sin Init} end
   {NewPort Sin P}
end

fun{NewCell A}
   {NewPortObject state(A)
    fun{$ Msg state(A)}
       case Msg of
	  assign(E) then state(E)
       [] access(R) then R=A state(A)
       end
    end
   }
end

proc{Assign Cell Val}
   {Send Cell assign(Val)}
end

proc{Access Cell R}
   {Send Cell access(R)}
end

local C1 R1 R2 in
   C1 = {NewCell 3}
   {Access C1 R1}
   {Browse R1}
   {Assign C1 42}
   {Access C1 R2}
   {Browse R2}
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  EXO3                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% cree NewPort renvoie un nouveau port qui est represente par une cell
% cree Send qui prend une cellule et un argument. Il rajoute l'element au stream
declare
proc{MyNewPort Stream Cell}
   Cell={NewCell Stream}
end

proc{MySend Cell Val}
   Stream StreamNext in
   Stream=@Cell
   Stream = Val|StreamNext
   Cell:=StreamNext
end

local Stream P1 in
   {Browse Stream}
   {MyNewPort Stream P1}
   {MySend P1 1}
   {MySend P1 42}
   {MySend P1 69}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  EXO4                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
proc{MyNewPortClose Stream Cell}
   Cell={NewCell cell(Stream 'open')}
end

proc{MySendClose Cell Val}
   Stream StreamNext CellState in
   CellState=@Cell
   if CellState.2=='closed' then
      {Browse 'Cell is closed already'}
   else
      Stream=CellState.1
      Stream = Val|StreamNext
      Cell:=cell(StreamNext 'open')
   end
end

proc{MyClose Cell}
   CellState in
   CellState=@Cell
   if CellState.2=='closed' then {Browse 'cell already closed'}
   else
      {Browse 'cell is just closed'}
      CellState.1=nil
      Cell:=cell(CellState.1 'closed')
   end
end

local Stream P1 in
   {Browse Stream}
   {MyNewPortClose Stream P1}
   {MySendClose P1 1}
   {MySendClose P1 42}
   {MySendClose P1 69}
   {MyClose P1}
   {MySendClose P1 11}
   {MySendClose P1 23}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  EXO5                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
declare
fun{Q A B}
   Cell in
   Cell={NewCell 0}
   for I in A..B do
      Cell:=(@Cell+I)
   end
   @Cell
end

local Val in
   Val = {Q 3 5}
   {Browse Val}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  EXO6                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Exemple de classed based object
%class Counter 
%   attr val %val s'utilise comme une cell
%   meth browse 
%      {Browse @val}
%   end 
%   meth inc(Value)
%      val := @val + Value %   end 
%   meth init(Value)
%      val := Value
%   end 
%end

%declare C in 
%C = {New Counter init(0)}
%{C browse}
%{C inc(1)}
%local X in thread {C inc(X)} end X=5 end

%a creer une classe counter avec read et add pour refaire Q
declare
class Counter
   attr val
   meth init(Value)
      val:=Value
   end
   meth add(Value)
      val:= (@val+Value)
   end
   meth read(N)
      N=@val
   end
end

fun{Q A B}
   C Ret in
   C = {New Counter init(0)}
   for I in A..B do
      {C add(I)}
   end
   {C read(Ret)}
   Ret
end

{Browse {Q 3 5}}

%b implementer la classe Port  avec init et send et faire NewPort et Send apres
declare
class Port
   attr stream
   meth init(Stream)
      stream:=Stream
   end
   meth send(Val)
      StreamNext Stream in
      Stream=@stream
      Stream=Val|StreamNext
      stream:=StreamNext
   end
end

proc {NewPortClass Stream P}
   P = {New Port init(Stream)}
end
proc {SendClass Port Val}
   {Port send(Val)}
end
local Stream P in
   {Browse Stream}
   {NewPortClass Stream P}
   {SendClass P 42}
   {SendClass P 11}
end

% c ajouter les closes 

declare
class Port
   attr stream
   meth init(Stream)
      stream:=state(Stream 'open')
   end
   meth send(Val)
      StreamNext Stream State in
      State=@stream
      Stream=State.1
      if State.2=='open' then
	 Stream=Val|StreamNext
	 stream:=state(StreamNext 'open')
      end
   end
   meth close()
      State in
      State=@stream
      if State.2=='open'then
	 State.1=nil
      end
      stream:=state(State.1 'closed')
   end
end

proc {NewPortClassClose Stream P}
   P = {New Port init(Stream)}
end

proc {SendClass Port Val}
   {Port send(Val)}
end

proc{SendClassClose Port}
   {Port close()}
end

local Stream P in
   {Browse Stream}
   {NewPortClassClose Stream P}
   {SendClass P 42}
   {SendClassClose P}
   {SendClass P 11}
end  