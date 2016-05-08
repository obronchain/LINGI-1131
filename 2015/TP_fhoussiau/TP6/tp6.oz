% Exercise (1)

declare
fun lazy {Gen I}
   I|{Gen I+1}
end

proc {Touch L N}
   if N==0 then skip
   else {Touch L.2 N-1} end
end

declare
fun {GiveMeNth L N}
   if N==0 then L.1 else {GiveMeNth L.2 N-1} end
end

declare L 
L = {Gen 0}
{Browse L}
{Touch L 5}
{Browse {GiveMeNth L 42}}


% Exercise (2)

declare
fun lazy {Filter Xs P}
   case Xs of nil then nil
   [] X|Xr then
      if {P X} then
	 X|{Filter Xr P}
      else
	 {Filter Xr P}
      end
   end
end

declare
fun lazy {Sieve Xs}
   case Xs of nil then nil
   [] X|Xr then
      X|{Sieve {Filter Xr fun {$ Y} Y mod X \= 0 end}}
   end
end

declare
fun lazy {Primes}
   {Sieve {Gen 2}}
end


declare Lp
Lp = {Primes}
{Browse Lp}
{Touch Lp 5}


% Exercise (3)
declare
proc {ShowPrimes N}
   proc {ShowN L N}
      if N==0 then skip else {Show L.1} {ShowN L.2 N-1} end
   end
in
   {ShowN {Primes} N}
end


{ShowPrimes 10}




% Exercise (4)
% given code:
declare
fun {Gen I N}
   {Delay 500}
   if I==N then [I] else I|{Gen I+1 N} end
end
fun {Filter L F}
   case L of nil then nil
   [] H|T then
      if {F H} then H|{Filter T F} else {Filter T F} end
   end
end
fun {Map L F}
   case L of nil then nil
   [] H|T then {F H}|{Map T F}
   end
end

% original 
declare Xs Ys Zs
{Browse Zs}
{Gen 1 100 Xs}
{Filter Xs fun {$ X} (X mod 2)==0 end Ys}
{Map Ys fun {$ X} X*X end Zs}

% (a) using threads
declare Xs Ys Zs
{Browse Zs}
thread {Gen 1 100 Xs} end
thread {Filter Xs fun {$ X} (X mod 2)==0 end Ys} end
thread {Map Ys fun {$ X} X*X end Zs} end

% (b) using lazy
declare
fun lazy {Gen I N}
   {Delay 500}
   if I==N then [I] else I|{Gen I+1 N} end
end
fun lazy {Filter L F}
   case L of nil then nil
   [] H|T then
      if {F H} then H|{Filter T F} else {Filter T F} end
   end
end
fun lazy {Map L F}
   case L of nil then nil
   [] H|T then {F H}|{Map T F}
   end
end
declare Xs Ys Zs
{Browse Zs}
{Gen 1 100 Xs}
{Filter Xs fun {$ X} (X mod 2)==0 end Ys}
{Map Ys fun {$ X} X*X end Zs}
{Touch Zs 100}



% Exercise (5)
declare
fun {Insert X Ys}
   {Browse insert}
   case Ys of
      nil then [X]
   [] Y|Yr then
      if X < Y then
	 X|Ys
      else
	 Y|{Insert X Yr}
      end
   end
end

fun {InSort Xs} %% Sorts list Xs
   {Browse insort}
   case Xs of
      nil then nil
   [] X|Xr then
      {Insert X {InSort Xr}}
   end
end
fun {Minimum Xs}
   {InSort Xs}.1
end

% quelle est la complexite?
% O(n^2) car pour chaque insertion il faut potentiellement parcourir toute la liste (de taille croissante % n)
% Exemple de worst case: [1 2 3 4 5]

local X in X = {Minimum [4 3 2 1]} {Browse X} end
% [1] : 3 operations
% [2 1] : 6 operations
% [3 2 1] : 10 operations
% [4 3 2 1] : 15 operations

