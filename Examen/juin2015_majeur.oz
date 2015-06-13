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
