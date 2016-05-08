%%% Lab 11 Explicit State and objects %%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Exo1                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Exo2                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
fun{NewPortObject F State}
   local
      Loop
      S
   in
      proc{Loop S State}
	 case S of H|T then
	    {Loop T {F H State}}
	 end
      end
      thread {Loop S State} end 
      {NewPort S}
   end
end

fun{CellBehaviour Msg State}
   case Msg of
      access(R) then R=State State
   [] assign(X) then X
   end
end

fun{NewCell Init}
   {NewPortObject CellBehaviour Init} 
end

proc{Access C R}
   {Send C access(R)}
end

proc{Assign C R}
   {Send C assign(R)}
end

%%%% Test Exo2 %%%%%
local X1 X2  C in
   C = {NewCell 0}
   {Access C X1}
   {Browse X1}

   {Assign C 42}
   {Access C X2}
   {Browse X2}
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Exo3                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implement NewPort and Send using cells
declare
fun{NewPortCell S} 
   {NewCell S}
end

proc{SendCell C Val}
   local S1 S2 in
      S1 = @C
      S1 = Val|S2
      C:=S2
   end
end

%%%%% Test Exo3 %%%%
local P S in
   {Browse S}
   P = {NewPortCell S}
   {SendCell P 42}
   {Delay 1000}
   {SendCell P 432}
   {Delay 2000}
   {SendCell P 03}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Exo4                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Implement NewPortClose Send Close
declare
fun{NewPortClose S}
   {NewCell 's'(S false)}
end

proc{SendCell C Val}
   local S1 S2 in
      S1 = @C
      if S1.2==false then
	 S1.1 = Val|S2
	 C:='s'(S2 false)
      else
	 {Browse 'can not push because Port is closed'}
      end
   end
end

proc{CloseCell C}
   local V in
      V = @C
      V.1 = nil
      C:='s'(V.1 true)
   end
end

%%%% Test4 %%%%%
local P S in
   {Browse S}
   P = {NewPortClose S}
   {SendCell P 42}
   {Delay 1000}
   {SendCell P 43}
   {Delay 1000}
   {CloseCell P}
   {Delay 1000}
   {SendCell P 44}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Exo5                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fun{Q A B} ... end compute the sum between A and B
declare 
fun{Q A B}
   C in
   C = {NewCell 0}
   for I in A..B do
      C := @C+I
   end
   @C
end

%%%%% Test05 %%%%
{Browse {Q 1 3}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Exo6                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Handeling State with class-based objects
% a) create a class Count with add(N) and read(N) to implement Q
declare
class Counter
   attr val
   meth init(N)
      val:=N
   end
   meth read(N)
      N =@val
   end
   meth add(N)
      val:= @val + N
   end
end

fun{Q A B}
   C Val in
   C = {New Counter init(0)}
   for I in A..B do
      {C add(I)}
   end
   {C read(Val)}
   Val
end

{Browse {Q 1 6}}

% b) implements port with class-based objects. init send
declare
class Ports
   attr stream
   meth init(S)
      stream:= S
   end
   meth send(V)
      X S in
      X = @stream
      X = V|S
      stream:= S
   end
end

fun{NewPortObj S}
   {New Ports init(S)}
end

proc{SendObj P V}
   {P send(V)}
end

local P S in
   {Browse S}
   P = {NewPortObj S}
   {SendObj P 42}
   {SendObj P 33}
   {SendObj P 20}
end


% c) implements portclose with class-based objects. init send
declare
class PortsClose
   attr stream state
   meth init(S)
      stream:=S state:=false 
   end
   meth send(V)
      X S in
      X = @stream
      if @state==false then 
	 X = V|S
	 stream:= S
      else
	 {Browse 'can not push. Port is closed'}
      end
   end
   meth close(X)
      V in
      V = @stream
      V = nil
      state:=true
   end
end

fun{NewPortObjClose S}
   {New PortsClose init(S)}
end

proc{SendObjClose P V}
   {P send(V)}
end

proc{CloseObj P}
   {P close(_)}
end


local P S in
   {Browse S}
   P = {NewPortObjClose S}
   {SendObjClose P 42}
   {SendObjClose P 33}
   {CloseObj P}
   {SendObjClose P 20}
end