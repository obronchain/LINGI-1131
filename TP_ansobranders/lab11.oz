%lab 11
%10/06/15

%ansobr


%1
declare
A={NewCell 0}
B={NewCell 0}

T1=@A
T2=@B

{Show A==B}
%false car A et B sont pas des valeurs mais des cellules

{Show T1==T2}
%true car T1 et T2 sont les valeurs des cellules

{Show T1=T2}
%0 car T1=T2=0

A:=@B
{Show A==B}
%false car on a egale les valeurs mais pas la cellule en elle meme

%2
declare
fun {NewPortObject F State}
   S P={NewPort S}
   proc {Loop S State}
      case S of Msg|S2 then
	 {Loop S2 {F Msg State}}
      end
   end
in
   thread {Loop S State} end
   P
end

fun {F Msg State}
   case Msg of
      access(R) then R = State State
   [] assign(E) then E
   end
end

fun {NewCell2 State}
   {NewPortObject F State}
end

declare
Cell = {NewCell2 empty}
{Browse {Send Cell access($)}}
{Send Cell assign(23)}
{Browse {Send Cell access($)}}


%3
declare
fun {NewPort2 S}
   {NewCell S}
end

proc {Send2 P X}
   P2 in
   @P=X|P2
   P:=P2
end

declare
S
Port = {NewPort2 S}
{Send2 Port 23}
{Browse S}


%4
declare
proc {Close P}
   @P = nil
end

declare
S
Port = {NewPort2 S}
{Send2 Port 23}
{Browse S}
{Close Port}
{Send2 Port 26}


%5
declare
fun {Q A B}
   fun {Sum I C}
      if I>B then @C
      else C:=@C+I {Sum I+1 C} end
   end
   C = {NewCell 0}
in
   {Sum A C}
end

{Browse {Q 1 4}}


%6

%a
declare
class Counter
   attr count
   meth init count:=0 end
   meth add(N) count:=@count+N end
   meth read(N) N=@count end
end

%b
declare
class Port
   attr port
   meth init(S) port:=S end
   meth send(X) S2 in @port=X|S2 port:=S2 end
end

declare
fun {NewPortC S}
   {New Port init(S)}
end

proc {Send P X}
   {P send(X)}
end

%c
declare
class PortClose from Port
   meth close @port=nil end
end

declare
fun {NewPortClose S}
   {New PortClose init(S)}
end
proc {Close P}
   {P close}
end

declare
S
P={NewPortClose S}
{Send P 23}
{Browse S}
{Send P kikou}
{Close P}

