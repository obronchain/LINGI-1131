%%%%%%%% Juin 2014 Mineur %%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         Question 2            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
fun{ChooseColor C1 C2}
   L ='#'(green red blue)
   fun{Loop }
      Rand = {OS.rand} mod 3 +1
   in      
      if {And C1\=L.Rand C2\=L.Rand} then L.Rand
      else
	 {Loop}
      end
   end
in
   {Loop}
end

fun{NewPortObject Behaviour Init}
   S P
   proc{Loop L State}
      case L of H|T then
	 {Loop T {Behaviour H State}}
      end
   end
in
   {NewPort S P}
   thread {Loop S Init} end
   P
end

fun{AgentBehaviour Msg '#'(Next Color)}
   case Msg of
      packet(P) then
      NewC E in
      NewC = {ChooseColor Color Color}
      E = {ChooseColor Color NewC}
      {Browse [ 'sending color' E]}
      {Delay 1000}
      {Send Next packet(E)}
      '#'(Next NewC)
   end
end


local
   A B C
in
   A = {NewPortObject AgentBehaviour '#'(B red)}
   B = {NewPortObject AgentBehaviour '#'(C red)}
   C = {NewPortObject AgentBehaviour '#'(A red)}

   {Send C packet(blue)}
end
