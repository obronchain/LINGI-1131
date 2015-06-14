%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          Question 3          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implementer un simple lock avec
% Cell et dataflow Variables.
declare 
fun{LockCreacteCell}
   Token = {NewCell _}
in
   proc{$ P}
      Old New in
      {Exchange Old New}
      {Wait Old}
      try {P} finally New=unit end
   end
end

fun{LockCreateReantrant}
   Token = {NewCell _}
   CurThr = {NewCell unit}
in
   proc{$ P}
      if {Thread.this == @CurThr} then {P}
      else
	 Old New in
	 {Exchange Old New}
	 {Wait Old}
	 CurThr := {Thread.this}
	 try {P}
	 finally
	    CurThr := unit
	    New = unit
	 end
      end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         Question 3            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
declare
fun{NewPortObject F Init}
   S P Loop in
   {NewPort S P}
   proc{Loop L State}
      case L of Msg|T then
	 {Loop T {F Msg State}}
      end
   end
   thread {Loop S Init} end
   P
end

fun{AgentBehaviour Msg '#'(Neight Previous Mod)}
   case Msg of
      ball(N) then
      if (Previous+1 mod Mod)==N then {Browse ['aval' N]} {Show N} '#'(Neight N Mod)
      else
	 {Browse ['forward' N]}
	 {Neight.({OS.rand} mod 4 +1) ball(N)}
	 '#'(Neight N Mod)
      end
   [] setN(Ne) then
      '#'(Ne Previous Mod)
   end
end

fun{MakeAgent  V M}
   AgentObj in
   AgentObj= {NewPortObject AgentBehaviour '#'(unit V M)}
   proc{$ Msg} {Send AgentObj Msg} end
end

fun{FindNeight Rows Imax Jmax PosiI PosiJ}
   '#'(Rows.PosiI.(PosiJ mod Jmax +1 ) Rows.PosiI.((PosiJ+Jmax-2) mod Jmax +1) Rows.(PosiI mod Imax +1).PosiJ Rows.((PosiI+Imax-2) mod Imax +1).PosiJ)
end


local
   Imax
   Jmax
   Rows
in
   Imax = 4
   Jmax = 4
   Rows={MakeTuple 'r' Imax}
   for I in 1..Imax do
      Rows.I={MakeTuple 'l' Jmax}
      for J in 1..Jmax do
	 %{Browse [I J]}
	 Rows.I.J = {MakeAgent ((I-1)*Imax + (J-1)) Imax*Jmax}
      end
   end

   for I in 1..Imax do 
      for J in 1..Jmax do
	 %{Browse [I J]}
	 {Rows.I.J setN({FindNeight Rows Imax Jmax I J})}
      end
   end

   for I in 1..Imax do
      for J in 1..Jmax do
	 {Rows.I.J ball((I-1)*Imax + (J-1))}
      end
   end
end









   

