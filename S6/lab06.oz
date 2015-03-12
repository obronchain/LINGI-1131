declare
fun lazy {Gen I}
   I|{Gen I+1}
end

local X L1 L2 L3 in
   X = {Gen 1}
   L1 = X.1
   L2 = X.2.1
   L3 = X.2.2.1
   {Browse X}
end

declare
fun{GiveNthElem N L}
   local X Give in
      X = {Gen L}
      fun{Give N L}
	 if N != 0 then L.1|{Give N-1 K
   end
   
end

   


