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
% on envoie cree un controleur à chaque fois que l'on veut faire bouger un ascenseur. 

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
	 {Delay 1000} {Send Lid 'at'(Pos−1)}
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
