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

proc {NewPortObject2 Proc ?P}
   Sin in
   thread for Msg in Sin do {Proc Msg} end end
   {NewPort Sin P}
end

proc {Controller ?Cid}
   {NewPortObject2
    proc {$ Msg}
       case Msg
       of step(Lid Pos Dest) then
	  if Pos<Dest then
	     {Delay 1000} {Send Lid 'at'(Pos+1)}
	  elseif Pos>Dest then
	     {Delay 1000} {Send Lid 'at'(Pos-1)}
	  end
       end
    end Cid}
end

proc {Floor Num Init Lifts ?Fid}
   {NewPortObject Init
    fun {$ Msg state(Called)}
       case Msg
       of call then
	  {Browse 'Floor '#Num#' calls a lift!'}
	  if {Not Called} then Lran in
	     Lran=Lifts.(1+{OS.rand} mod {Width Lifts})
	     {Send Lran call(Num)}
	  end
	  state(true)
       [] arrive(Ack) then
	  {Browse 'Lift at floor '#Num#': open doors'}
	  {Delay 2000}
	  {Browse 'Lift at floor '#Num#': close doors'}
	  Ack=unit
	  state(false)
       end
    end Fid}
end

proc {Lift Num Init Cid Floors ?Lid}
   {NewPortObject Init
    fun {$ Msg state(Pos Sched Moving)}
       case Msg
       of call(N) then
	  {Browse 'Lift '#Num#' needed at floor '#N}
	  if N==Pos andthen {Not Moving} then
	     {Wait {Send Floors.Pos arrive($)}}
	     state(Pos Sched false)
	  else Sched2 in
	     Sched2={Append Sched [N]}
	     if {Not Moving} then
		{Send Cid step(Lid Pos Sched2.1)} end
	     state(Pos Sched2 true)
	  end
       [] 'at'(NewPos) then
	  {Browse 'Lift '#Num#' at floor '#NewPos}
	  case Sched
	  of nil then
	     state(NewPos Sched Moving)
	  [] S|Sched2 then
	     if NewPos==S then
		{Wait {Send Floors.S arrive($)}}
		if Sched2==nil then
		   state(NewPos nil false)
		else
		   {Send Cid step(Lid NewPos Sched2.1)}
		   state(NewPos Sched2 true)
		end
	     else
		{Send Cid step(Lid NewPos S)}
		state(NewPos Sched true)
	     end
	  end
       end
    end Lid}
end

proc {Building FN LN ?Floors ?Lifts}
   Lifts={MakeTuple lifts LN}
   for I in 1..LN do C in
      {Controller C}
      Lifts.I={Lift I state(1 nil false) C Floors}
   end
   Floors={MakeTuple floors FN}
   for I in 1..FN do
      Floors.I={Floor I state(false) Lifts}
   end
end

local Floors Lifts in
   {Building 10 5 Floors Lifts}
   {Send Floors.5 call}
   {Send Floors.10 call}
end


%1) pas fait

%2 l'impact de mettre ce nouveau Building va faire que les Lifts ne peuvent plus bouger de maniere independante.

declare Building2 
proc {Building2 FN LN ?Floors ?Lifts} C in
   Lifts={MakeTuple lifts LN}
   {Controller C}
   for I in 1..LN do
      Lifts.I={Lift I state(1 nil false) C Floors}
   end
   Floors={MakeTuple floors FN}
   for I in 1..FN do
      Floors.I={Floor I state(false) Lifts}
   end
end

local Floors Lifts in
   {Building 10 5 Floors Lifts}
   {Send Floors.5 call}
   {Send Floors.10 call}
end

%3 Le probleme est ici qu'un controleur ne peut etre utilise qu'une seule fois. A la place de faire {Send Cid}
% on envoie cree un controleur à chaque fois que l'on veut faire bouger un ascenseur. Le state diagramme change alors

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

proc {NewPortObject2 Proc ?P}
   Sin in
   thread for Msg in Sin do {Proc Msg} end end
   {NewPort Sin P}
end

%proc {Controller ?Cid}
%   {NewPortObject2
%    proc {$ Msg}
%       case Msg
%       of step(Lid Pos Dest) then
%	  if Pos<Dest then
%	     {Delay 1000} {Send Lid 'at'(Pos+1)}
%	  elseif Pos>Dest then
%	     {Delay 1000} {Send Lid 'at'(Pos-1)}
%	  end
%       end
%    end Cid}
%end

proc {Controller Msg}
   case Msg
   of step(Lid Pos Dest) then
      if Pos<Dest then
	 {Delay 1000} {Send Lid 'at'(Pos+1)}
      elseif Pos>Dest then
	 {Delay 1000} {Send Lid 'at'(Pos-1)}
      end
   end
end

proc {Floor Num Init Lifts ?Fid}
   {NewPortObject Init
    fun {$ Msg state(Called)}
       case Msg
       of call then
	  {Browse 'Floor '#Num#' calls a lift!'}
	  if {Not Called} then Lran in
	     Lran=Lifts.(1+{OS.rand} mod {Width Lifts})
	     {Send Lran call(Num)}
	  end
	  state(true)
       [] arrive(Ack) then
	  {Browse 'Lift at floor '#Num#': open doors'}
	  {Delay 2000}
	  {Browse 'Lift at floor '#Num#': close doors'}
	  Ack=unit
	  state(false)
       end
    end Fid}
end

proc {Lift Num Init  Floors ?Lid}
   {NewPortObject Init
    fun {$ Msg state(Pos Sched Moving)}
       case Msg
       of call(N) then
	  {Browse 'Lift '#Num#' needed at floor '#N}
	  if N==Pos andthen {Not Moving} then
	     {Wait {Send Floors.Pos arrive($)}}
	     state(Pos Sched false)
	  else Sched2 in
	     Sched2={Append Sched [N]}
	     if {Not Moving} then
		thread {Controller step(Lid Pos Sched2.1)} end end
	     state(Pos Sched2 true)
	  end
       [] 'at'(NewPos) then
	  {Browse 'Lift '#Num#' at floor '#NewPos}
	  case Sched
	  of nil then
	     state(NewPos Sched Moving)
	  [] S|Sched2 then
	     if NewPos==S then
		{Wait {Send Floors.S arrive($)}}
		if Sched2==nil then
		   state(NewPos nil false)
		else
		   thread {Controller step(Lid NewPos Sched2.1)} end
		   state(NewPos Sched2 true)
		end
	     else
		thread {Controller step(Lid NewPos S)} end
		state(NewPos Sched true)
	     end
	  end
       end
    end Lid}
end

proc {Building FN LN ?Floors ?Lifts}
   Lifts={MakeTuple lifts LN}
   for I in 1..LN do 
      Lifts.I={Lift I state(1 nil false)  Floors}
   end
   Floors={MakeTuple floors FN}
   for I in 1..FN do
      Floors.I={Floor I state(false) Lifts}
   end
end

local Floors Lifts in
   {Building 10 5 Floors Lifts}
   {Send Floors.5 call}
   {Send Floors.10 call}
end


%4 Quand on appelle l'ascenseur alors que la porte est ouverte, il le rapelle juste apres et il rouvre donc les portes.

%5 A la place d'appeler le controlleur pour faire un mouvement, le Lift va lui meme choisir ou alors. On doit supprimer les messages 'step' et les 'at'.
% On fait en sorte que ce soit le lift qui gere son temps. On lance un thread pour qu'il calcule sa nouvelle position. Cette nouvelle position sera liee une fois que l'ascenseur aura monte/descendu. 
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

proc {NewPortObject2 Proc ?P}
   Sin in
   thread for Msg in Sin do {Proc Msg} end end
   {NewPort Sin P}
end

fun {NewController Dest Pos}
   if Pos<Dest then
      {Delay 1000} (Pos+1)
   elseif Pos>Dest then
      {Delay 1000} (Pos-1)
   end
end

proc {Floor Num Init Lifts ?Fid}
   {NewPortObject Init
    fun {$ Msg state(Called)}
       case Msg
       of call then
	  {Browse 'Floor '#Num#' calls a lift!'}
	  if {Not Called} then Lran in
	     Lran=Lifts.(1+{OS.rand} mod {Width Lifts})
	     {Send Lran call(Num)}
	  end
	  state(true)
       [] arrive(Ack) then
	  {Browse 'Lift at floor '#Num#': open doors'}
	  {Delay 2000}
	  {Browse 'Lift at floor '#Num#': close doors'}
	  Ack=unit
	  state(false)
       end
    end Fid}
end

proc {Lift Num Init Floors ?Lid}
   {NewPortObject Init
    fun {$ Msg state(Pos Sched Moving)}
       case Msg
       of call(N) then
	  local NewPos in 
	     {Browse 'Lift '#Num#' needed at floor '#N}
	  if N==Pos andthen {Not Moving} then
	     {Wait {Send Floors.Pos arrive($)}}
	     state(Pos Sched false)
	  else Sched2 in
	     Sched2={Append Sched [N]}
%	     if {Not Moving} then
%		thread NewPos = {NewController Sched2.1 Pos} end
%	     else
%		NewPos = Pos
%	     end
	     thread{Send Lid unit} end
	     state(Pos Sched2 true)
	  end
	  end
       else local NewPos in
	       {Wait Pos}
	       {Browse 'Lift '#Num#' at floor '#Pos}
	       case Sched
	       of nil then
		  state(Pos Sched Moving)
	       [] S|Sched2 then
		  if Pos==S then
		     {Wait {Send Floors.S arrive($)}}
		     if Sched2==nil then
			state(Pos nil false)
		     else
			thread {Send Lid unit} end 
			state(Pos Sched2 true)
		     end
		  else
		     thread NewPos =  {NewController  S Pos} end
		     thread {Send Lid unit} end
		     state(NewPos Sched true)
		  end
	       end
	    end
       end
    end Lid}
end

proc {Building FN LN ?Floors ?Lifts}
   Lifts={MakeTuple lifts LN}
   for I in 1..LN do
      Lifts.I={Lift I state(1 nil false) Floors}
   end
   Floors={MakeTuple floors FN}
   for I in 1..FN do
      Floors.I={Floor I state(false) Lifts}
   end
end

local Floors Lifts in
   {Building 10 1 Floors Lifts}
   {Send Floors.5 call}
   {Delay 3500}
   {Send Floors.1 call}
end