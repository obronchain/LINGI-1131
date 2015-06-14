%exam juin 2015 maj
%13/06/15

%ansobr

%Q2
%%%%%%%%%%%%%%%%%%%%%%%%%
%J'ai pas l'impresssion d'avoir vraiment compris completement le but de cette question... Et ma solution est un peu bourrin
%%%%%%%%%%%%%%%%%%%%%%%%%

%  Un ORset est un objet contenant n Replicata. Chaque Replicata a comme état une liste de triple (V A R). Vous devez implémenter le ORset grace à des port object ou des active object.
% Chaque Replicata doit pouvoir "handle" ces méthodes :

% -add(V), ajoute le triple (V {NewName} nil) à la liste du replicata s'il n'est pas présent, sinon si V est deja présent dans les réplicatas, le A correspondant devient A U {NewName}.
% -query(V X) cherche V dans la liste de triples du replicata. Si V n'est pas présent, X bind a false. Si V est présent, alors si R est compris dans A, X bind a true, sinon false
% -remove(V) cherche V dans la liste, si V est trouve, alors le tuple (V A R) devient (V A A)
% -merge(S), S est le state d'un autre replicata, faut "juste merger" les listes de triple (si 2 V sont identiques, tu merges les A et les R respectifs).
% Attention, de maniere périodique, les réplicata envoient un merge de leur state à un Replicata random du ORset. Démerdez vous pour implémenter ca comme vous voulez.

%%%%%%%%%%%%%%%%%%%%%
%Le merge est faux !!
%%%%%%%%%%%%%%%%%%%%%

declare
fun {NewPortObject F State}
   S
   P={NewPort S}
   proc {Loop Xs State}
      case Xs of Msg|T then
	 {Loop T {F Msg State}}
      end
   end
in
   thread {Loop S State} end
   P
end


declare
fun {ReplicataBehavior Msg State}

   %NewName
   fun {NewName}
      'Kikou'#({OS.rand} mod 1000)
   end

   %pour add(V)
   fun {Insert L Vn}
      case L of nil then '#'(Vn {NewName} nil)
      [] '#'(V A R)|T then
	 if V == Vn then '#'(V A|{NewName} R)|T
	 else '#'(V A R)|{Insert T Vn}
	 end
      end
   end

   %pour query
   fun {Search Vn L}
      fun {SearchL X L}
	 case L of nil then false
	 [] H|T then
	    if H==X then true
	    else {SearchL X T}
	    end
	 end
      end
   in
      case L of nil then false
      [] '#'(V A R)|T then
	 if V==Vn then {SearchL R A}
	 else {Search Vn T}
	 end
      end
   end

   %pour remove
   fun {SearchV Vn L}
      case L of nil then nil
      [] '#'(V A R)|T then
	 if V==Vn then '#'(V A A)|T
	 else '#'(V A R)|{SearchV Vn T}
	 end
      end
   end

   %pour merge
   fun {Merge S State}
      fun {MergeList L1 L2}
	 fun {Merge2 X L}
	    case L of nil then X
	    [] H|T then if X==H then H|T
			else H|{Merge2 X T}
			end
	    end
	 end
      in
	 case L1 of nil then L2
	 [] H1|T1 then {MergeList T1 {Merge2 H1 L2}}
	 end
      end
      
      fun {InsertState V A R State}
	 case State of nil then '#'(V A R)
	 [] '#'(Vs As Rs)|T then
	    if V==Vs then '#'(V A|As R|Rs)|T
	    else '#'(Vs As Rs)|{InsertState V A R T}
	    end
	 end
      end
   in
      case S of nil then State
      [] '#'(V A R)|T then {Merge T {InsertState V A R State}}
      end
   end

in
   
   case Msg of add(V) then {Insert State V}
   [] query(V X) then X={Search V State} State
   [] remove(V) then {SearchV V State}
   [] merge(S) then {Merge S State}
      [] getState(S) then S=State State
   end

end


declare
fun {OrSet N}
   List = {MakeTuple 'replicatas' N}
in
   for I in 1..N do MergeLoop State in
      List.I = {NewPortObject ReplicataBehavior '#'(I nil nil)}
      proc {MergeLoop}
	 {Delay 2359}
	 {Send List.I getState(State)}
	 {Send List.({OS.rand} mod N + 1) merge(State)}
	 {MergeLoop}
      end
      thread {MergeLoop} end
   end
   List
end

%


%Q3

% -Implémentez la classe Counter comme objet passif, ayant la méthode inc,init(Value),get(Value).
% -En utilisant les ActiveObject (donner le code pour creer un active Object à partir d'un object), rendez cette classe Counter active.
% -Expliquez pourquoi on a des merdes en utilisant la concurrence sur les classes passives et pas sur les classes actives. Donner un exemple montrant qu'en faisant
% thread {C inc} end
% thread {C inc} end
% avec des passives on peut obtenir 1 comme résultat au lieu de 2 et pourquoi cela n'arrive pas avec des classes actives.
% -Donnez le code d'une LockReentrant et redéfinissez Counter pour qu'elle résiste aux erreurs meme en passif
% -Enfin, en utilisant Exchange pour Inc et Get, rendez aussi la classe Counter (passive) résistantes aux erreurs expliquées au dessus.

%a passive object
declare
class Counter
   attr x
   meth init(Value) x:=Value end
   meth inc x:=@x+1 end
   meth get(Value) Value=@x end
end

fun {NewCounter Value}
   {New Counter init(Value)}
end

proc {Inc Counter}
   {Counter inc}
end

fun {Get Counter}
   {Counter get($)}
end

declare
Count = {NewCounter 23}
{Browse {Get Count}}
{Inc Count}
{Browse {Get Count}}

%b active object
declare
fun {NewActive Class Init}
   Obj = {New Class Init}
   P
in
   thread S in
      {NewPort S P}
      for M in S do {Obj M} end
   end
   proc {$ M} {Send P M} end
end


declare
fun {NewCounterA Value}
   {NewActive Counter init(Value)}
end
proc {IncA Counter}
   {Counter inc}
end
fun {GetA Counter}
   {Counter get($)}
end

declare
CountA = {NewCounterA 22}
{Browse {GetA CountA}}
{IncA CountA}
{Browse {GetA CountA}}

%c passive objects run in the same thread as the caller but active obect has its own thread --> ex du cours avec l'execution de inc pour passive object


%d
declare
proc {ReentrantLock L}
   Token = {NewCell ok}
   CurThread = {NewCell ok}
in
   proc {L P}
      if {Thread.this}==@CurThread then {P}
      else
	 Old New in
	 {Exchange Token Old New}
	 {Wait Old}
	 CurThread := {Thread.this}
	 {P}
	 CurThread := ok
	 New := ok
      end
   end
end

declare
class Counter
   attr x lockR
   meth init(Value) x:=Value {ReentrantLock @lockR} end
   meth inc {@lockR proc{$} x:=@x+1 end} end
   meth get(Value) {@lockR proc{$} Value=@x end} end
end


%e
%je comprends pas trop ce qu'on nous veut... ?