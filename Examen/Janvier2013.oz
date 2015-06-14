%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Question 2                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%methode
% creer les object pour les dictionnaire
%   - set
%   - get
% Ce dictionnaire contiendra des 
% creer la fonction pour rendre un objet passif
% actif
% creer les fonctions
%    get
%    put

declare
class Dictionnaire
   attr list
   meth init
      X in
      list:= 'q'(0 X X)
      
   end
   meth add(K V)
      X1
      Q = @list
      E1 E
   in
      E = Q.3
      E = '#'(K V)|E1
      list := 'q'(Q.1+1 Q.2 E1)
   end
   meth get(K V)
      Q = @list
      proc{Loop N L}
	 if N==0 then skip
	 else
	    case L of '#'(K1 V1)|T then
	       if K==K1 then V = V1
	       else
		  {Loop N-1 T}
	       end
	    end
	 end
      end
   in
      {Loop Q.1 Q.2}
   end
end

fun{ComputeID K N}
   (K mod N)
end
   
class Peer
   attr nextPeer id dic n
   meth init(ID N)
      id := ID
      n := N
      dic := {NewActiveObject Dictionnaire init}
   end
   meth setNext(Next)
      nextPeer:=Next
   end
   meth get(K V)
      if {ComputeID K @n}== @id then {@dic get(K V)}
      else
	 {@nextPeer get(K V)}
      end
   end
   meth put(K V)
      if {ComputeID K @n}== @id then  {@dic add(K V)}
      else
	 {@nextPeer put(K V)}
      end
   end
end

fun{NewActiveObject Class Init}
   Obj P S Loop in
   Obj = {New Class Init}
   {NewPort S P}
   proc{Loop L}
      case L of H|T then
	 {Obj H} {Loop T}
      end
   end
   thread {Loop S} end
   proc{$ Msg} {Send P Msg} end
end

local
   Peers
   N
   X
   Y
in
   N = 10
   Peers = {MakeTuple 'peers' N}

   for I in 1..N do
      Peers.I = {NewActiveObject Peer init(I N)}
   end

   for I in 1..(N-1) do
      {Peers.I setNext(Peers.(I+1))}
   end
   
   {Peers.N setNext(Peers.1)}
   {Peers.3 put(42 'olitestropcon')}
   {Peers.4 put(68 '69aveclasoeurdenico')}
   {Peers.4 put(58 'oktamere')}
   {Peers.1 get(68 X)}
   {Peers.9 get(58 Y)}
   {Browse X}
   {Browse Y}
end


      