% exo 1
declare
fun lazy{Gen I}
   I|{Gen  I+1}
end

local
   L = {Gen 10}
   L2 = L.1
   L3 = L.2.1
   L4 = L.2.2.1
in
   {Browse L}
end

declare
fun {GiveMeNth Nth L}
   case L of H|T then
      if Nth == 1 then H
      else {GiveMeNth Nth-1 T}end
   end
end

{Browse {GiveMeNth 1 {Gen 10}}}

% exo 2
declare
fun lazy{Filter L P}
   case L of nil then nil
   []H|T then
      if {P H} then H|{Filter T P}
      else {Filter T P}end
   end
end
      
declare
fun lazy {Sieve Xs}
   case Xs of nil then nil
   []X|Xr then X|{Sieve {Filter Xr fun{$ Y} Y mod X \= 0 end }}
   end
end

declare
fun {Prime}
   {Sieve {Gen 2}}
end

%exo 3
declare
fun{ShowPrimes N}
   local
      fun{S V L}
	 if V == 0 then nil
	 else L.1|{S V-1 L.2} end
      end
   in
      {S N {Prime}}   
   end
end

{Browse {ShowPrimes 10}}

%exo 4
%sol 1 using thread ... end 
declare
fun {Gen I N}
   {Delay 500}
   if I==N then [I] else I|{Gen I+1 N} end
end

declare
fun {Filter L F}
   case L of nil then nil
   [] H|T then
      if {F H} then H|{Filter T F} else {Filter T F} end
   end
end

declare
fun {Map L F}
   case L of nil then nil
   [] H|T then {F H}|{Map T F}
   end
end

local  Xs Ys Zs in 
   {Browse Zs}
   thread Xs = {Gen 1 100} end 
   thread Ys = {Filter Xs fun {$ X} (X mod 2)==0 end} end
   thread Zs = {Map Ys fun {$ X} X*X end} end 
end

%sol 2 using lazy function

declare
fun lazy {Gen I N}
   {Delay 500}
   if I==N then [I] else I|{Gen I+1 N} end
end

declare
fun lazy {Filter L F}
   case L of nil then nil
   [] H|T then
      if {F H} then H|{Filter T F} else {Filter T F} end
   end
end

declare
fun {Map L F}
   case L of nil then nil
   [] H|T then {F H}|{Map T F}
   end
end

local  Xs Ys Zs in 
   {Browse Zs}
   Xs = {Gen 1 10} 
   Ys = {Filter Xs fun {$ X} (X mod 2)==0 end}
   Zs = {Map Ys fun {$ X} X*X end} 
end
