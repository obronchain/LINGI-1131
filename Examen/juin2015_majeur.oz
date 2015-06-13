%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Question2                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Demarche a suivre
% - implementer newPortObject
% - implementer les fonctions utiles comme
%     - merge
%     - include
% - implementer Replica Behaviour

declare
ListOfReplica
fun{NewName}
   'oli'
end
fun{Include L1 L2 Real}
   case (L1)#(L2) of
      (H1|T1)#(H2|T2) then
      if H1==H2 then {Include T1 T2 Real}
      else {Include T1 Real Real}
      end
   []nil#T then false
   []T#nil then true
   end
end

	 
fun{NewPortObject F Init}
   local
      proc{Loop L State}
	 case L of H|T then
	    {Loop T {F H State}}
	 end 
      end
      P
      S
   in
      {NewPort S P}
      thread {Loop S Init} end
      P
   end
end

fun{Merge A B}
   case A of nil then B
   [] H|T then A|{Merge T B}
   end
end

fun{ReplicaBehaviour Msg State}
   case Msg of
      add(V) then Loop in
      fun{Loop L V}
	 case L of nil then '#'(V {NewName} nil)|nil
	 [] '#'(V1 A1 R1)|T then
	    if V1==V then '#'(V1 {Merge {NewName} A1} R1)|{Loop T V}
	    else '#'(V1 A1 R1)|{Loop T V}
	    end
	 end
      end
      {Loop State V}
   [] query(V X) then Loop in
      proc{Loop L V}
	 case L of nil then X=false
	 [] '#'(V1 A1 R1)|T then if {And V1==V {Include A1 R1 R1}} then X = true
				 else X = false
				 end
	 end
      end
      {Loop State V}
      State
   [] remove(V) then Loop in
      fun{Loop L V}
	 case L of nil then nil
	 []'#'(V1 A1 R1)|T then if V1==V then
				   '#'(V1 A1 A1)|T
				else
				   '#'(V1 A1 R1)|{Loop T V}
				end
	 end
      end
      {Loop State V}
   [] merge(S) then LoopSlow IsIn in
      fun{LoopSlow L1 L2}
	 case L2 of nil then L1
	 []H|T then {LoopSlow {IsIn L1 H} T}
	 end
      end
      fun{IsIn L '#'(V1 A1 R1)}
	 case L of nil then nil
	 []'#'(V2 A2 R2)|T then if V1==V2 then
				   '#'(V1 {Merge A1 A2} {Merge R1 R2})|T
				else
				   '#'(V2 A2 R2)|{IsIn T '#'(V1 A1 R1)}
				end
	 end
      end
      {LoopSlow S State}
   [] getState(S) then S = State State
   end
end

fun{ORsetBehaviour Msg State}
   case Msg of
      init(N) then List in
      List = {MakeTuple 'replicas' N}
      for I in 1..N do Loop S in
	 proc {Loop}
	    {Delay 2000}
	    {Send List.I getState(S)}
	    {Send List.({OS.rand} mod N +1) merge(S)}
	    {Loop}
	 end
	 List.I = {NewPortObject ReplicaBehaviour '#'(I nil nil)}
	 thread {Loop} end 
      end
      List
   end
end

%%%%%%%%%%%%%%%%%%
% Aucunes idees de comment on fait pour tester ca
% et non plus a quoi ca sert ....


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Question 3                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implementer l'object passif Counter
declare
class Counter
   attr v
   meth init(Value)
      v:=Value
   end
   meth inc
      V in
      V = @v +1
      {Delay {OS.rand} mod 50}
      v := V 
   end
   meth get(Value)
      Value = @v
   end
end

% preuve de mauvais fonctionnement
local Obj X  in
   Obj = {New Counter init(0)}
   X= {MakeTuple 'l' 1000}
   for I in 1..1000 do
      thread
	 for J in 1..1000 do Y in 
	    {Obj inc}
	    {Obj get(Y)}
	 end
	 X.I=unit
      end
   end

   for I in 1..1000 do
      {Wait X.I}
   end

   {Browse {Obj get($)}==1000*1000}
end


%Le rendre actif avec un code
declare
fun{NewActiveObject Class Init}
   P S Loop Obj in
   Obj = {New Class Init}
   {NewPort S P}
   proc{Loop S}
      case S of
	 H|T then {Obj H} {Loop T}
      end
   end
   thread {Loop S} end 
   proc{$ M}{Send P M} end 
end

local
   Obj
   X1 X2
in
   Obj={NewActiveObject Counter init(10)}
   {Obj get(X1)}
   {Browse X1}
   {Obj inc}
   {Obj get(X2)}
   {Browse X2}
end

%Faire en sorte en utilisant un lock reantrant
% que counter puisse etre utilise avec diff threads

declare
fun{NewLockReantrant}
   CurThr = {NewCell unit}
   Token = {NewCell unit}
   Lock
in
   proc{Lock P}
      if {Thread.this} == @CurThr then {Browse 'reantrant'} {P}
      else Old New in
	 {Exchange Token Old New}
	 {Wait Old}
	 CurThr := {Thread.this}
	 try {P} finally
	    CurThr := unit
	    New = unit
	 end
      end
   end
   Lock
end

class CounterSave
   attr v l
   meth init(Value)
      v:=Value
      l:={NewLockReantrant}
   end
   meth inc
      {@l proc{$}
	     v := @v+1
	  end
       }
   end  
   meth get(Value)
      {@l proc{$}
	     Value = @v
	  end
       }
   end
end

% preuve de bon fonctionnement
local Obj X  in
   Obj = {New CounterSave init(0)}
   X= {MakeTuple 'l' 1000}
   for I in 1..1000 do
      thread
	 for J in 1..100 do Y in 
		{Obj inc}
		{Obj get(Y)}
	 end
	 X.I=unit
      end
   end

   for I in 1..1000 do
      {Wait X.I}
   end

   {Browse {Obj get($)}==100*1000}
end

%faire la meme chose mais en utilisant exhance
declare 
class CounterExchange
   attr v
   meth init(V)
      v := {NewCell V}
   end
   meth inc
      New Old in
      {Exchange @v Old New}
      {Delay {OS.rand} mod 50}
      New = Old+1
   end
   meth get(V)
      {Exchange @v V V}
   end
end

% preuve de bon fonctionnement
local Obj X  in
   Obj = {New CounterExchange init(0)}
   X= {MakeTuple 'l' 1000}
   for I in 1..1000 do
      thread
	 for J in 1..1000 do Y in 
		{Obj inc}
		{Obj get(Y)}
	 end
	 X.I=unit
      end
   end

   for I in 1..1000 do
      {Wait X.I}
   end

   {Browse {Obj get($)}==1000*1000}
end