% nice declarations of gates

declare
fun {NotGate X}
   case X of nil then nil
   [] H|T then (1-H)|thread {NotGate T} end
   end
end

fun {AndGate X Y}
   case X#Y of nil#R then nil
   [] R#nil then nil
   [] (HX|TX)#(HY|TY) then R in
      if HX+HY==2 then R=1 else R=0 end
	  R|thread {AndGate TX TY} end
   end
end

fun {OrGate X Y}
   case X#Y of nil#R then nil
   [] R#nil then nil
   [] (HX|TX)#(HY|TY) then R in
      if HX+HY>0 then R=1 else R=0 end
      R|thread {OrGate TX TY} end
   end
end




% full hardcore exercise

declare
fun {Simulate G Ss}
   case G of
      gate(value:'or' X Y)  then thread {OrGate  {Simulate X Ss} {Simulate Y Ss}} end
   [] gate(value:'and' X Y) then thread {AndGate {Simulate X Ss} {Simulate Y Ss}} end
   [] gate(value:'not' X)   then thread {NotGate {Simulate X Ss}} end
   [] input(L) then Ss.L end
end

declare Ss
{Browse {Simulate gate(value:'or' gate(value:'and' input(x) input(y)) gate(value:'not' input(z))) Ss}}
Ss = input(x:1|0|1|0|_ y:0|1|0|1|_ z:1|1|0|0|_)