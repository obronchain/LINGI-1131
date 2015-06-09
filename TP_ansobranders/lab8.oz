%lab8
%9/06/15
%ansobr

%1

declare
proc {ReadList L}
   case L of nil then skip
   [] H|T then {Browse H} {ReadList T}
   end
end

L=17|22|23|nil
{ReadList L}


%2
declare
P S
{NewPort S P}

{Send P foo}
{Send P bar}

{Browse S}

{Send P chaussette}

%le stream affiche n'est pas fini et si on send des trucs encore apres l'avoir affiche, il se complete direct


%3
declare
S
P={NewPort S}
{Send P kikou}
{Send P comment}
{Send P ca}
{Send P va}

{ReadList S}



%4
declare
proc {RandomSenderManiac N P}
   for I in 1..N do
      thread {Delay {OS.rand} mod 5000} {Send P I} end
   end
end

S
P = {NewPort S}
{RandomSenderManiac 23 P}
{Browse S}


%5
%principe des ports : premier arrive, premier ajoute
%nondeteminism car on sait pas predire l'ordre d'arrivee


%6
declare
fun {WaitTwo X Y}
   S
   P={NewPort S}
in
   thread {Wait X} {Send P 1} end
   thread {Wait Y} {Send P 2} end
   case S of H|_ then H end
end

X Y
thread {Browse {WaitTwo X Y}} end
{Delay 1500}
Y = unit


%7

declare
proc {Client P}   
   for I in 1..23 do
      Ack in
      {Send P I#Ack} {Wait Ack} {Browse I#ok}
   end
end

proc {Server S}
   case S of (_#Ack)|T then
      {Delay {OS.rand} mod 1500 + 500}
      Ack = unit
      {Server T}
   end
end

declare
S
P={NewPort S}
thread {Client P} end
thread {Server S} end


%8
declare
fun {SafeSend P M T}
   Ack S P2={NewPort S} in
   {Send P M#Ack}
   thread {Delay T} {Send P2 false} end
   thread {Wait Ack} {Send P2 true} end
   case S of H|_ then H end
end

declare
S P={NewPort S} Ack
thread {Browse {SafeSend P kikou 1000}} end
thread {Server S} end


%9
%a non deterministe donc les inputs peuvent arriver dans le sens qu'on veut : pas d'orde entre chaque thread mais ordre séquentiel au sein d'un meme thread

%b 42 #IWantThisQuestionAtTheExam

%je crois qu'ils ont oublie de le demander dans la question mais bon je vais quand meme implementer ca avec des ports, ca a l'air marrant

declare
fun {Counter S}
   fun {CounterAux S R}
      fun {Insert X L}
	 case L of nil then [X#1]
	 [] (H#N)|T then
	    if H == X then (H#N+1)|T
	    else (H#N)|{Insert X T}
	    end
	 end
      end
      NewR
   in
      case S of nil then nil
      [] H|T then
	 NewR = {Insert H R}
	 NewR|thread {CounterAux T NewR} end
      end
   end
in
   {CounterAux S nil}
end

declare
S
P={NewPort S}
thread {Delay ({OS.rand} mod 1000)} {Send P e} end
thread {Delay ({OS.rand} mod 1000)} {Send P m} end
thread {Delay ({OS.rand} mod 1000)} {Send P c} end
thread {Delay ({OS.rand} mod 1000)} {Send P d} end
thread {Delay ({OS.rand} mod 1000)} {Send P b} end
thread {Delay ({OS.rand} mod 1000)} {Send P a} end
thread {Delay ({OS.rand} mod 1000)} {Send P q} end
thread {Delay ({OS.rand} mod 1000)} {Send P m} end

{Browse {Counter S}}

%10
declare
fun {StreamMerger S1 S2}
   H1 T1 H2 T2 N in
   S1=H1|T1
   S2=H2|T2
   N = {WaitTwo H1 H2}
   if N==1 then H1|thread {StreamMerger T1 S2} end
   else H2|thread {StreamMerger S1 T2} end
   end   	 
end

%pourquoi qd on teste la fonction avec ca :
local X Y Z T T2 in
   {Browse Z}
   thread Z ={StreamMerger 1|2|X 3|4|Y} end
   thread {Delay {OS.rand} mod 3000}
   X=9|T end
   thread {Delay {OS.rand} mod 3000}
   Y=10|11|T2 end
end

%ca marche mais avec ca :

declare
S1 S2 P1={NewPort S1} P2={NewPort S2}

thread {Delay ({OS.rand} mod 1000)} {Send P1 e} end
thread {Delay ({OS.rand} mod 1000)} {Send P1 m} end
thread {Delay ({OS.rand} mod 1000)} {Send P2 c} end
thread {Delay ({OS.rand} mod 1000)} {Send P1 d} end
thread {Delay ({OS.rand} mod 1000)} {Send P2 b} end
thread {Delay ({OS.rand} mod 1000)} {Send P1 a} end
thread {Delay ({OS.rand} mod 1000)} {Send P2 q} end
thread {Delay ({OS.rand} mod 1000)} {Send P2 m} end

{Browse thread {StreamMerger S1 S2} end}

%ca marche pas ?? :'(