% % RAPPEL: traduction du lazy

% fun lazy {F}
%    <p>
% end


% %veut dire:

% proc {F ?R}
%    thread
%       {WaitNeeded R}
%       <p>
%    end
% end

	   


% ----
% Ex 1
% ----

declare
fun lazy {Gen I}
   I|{Gen I+1}
end


local X in
   X = {Gen 1}
   {Browse X} % d'abord ca donne _
   {Browse X.1}
   {Browse X.2.1}
   {Browse X.2.2.1}
end


declare
fun {GiveMeNth N L}
   if N == 1 then L.1
   else {GiveMeNth N-1 L.2}
   end
end

local X Y in
   X = {Gen 5}
   Y = {GiveMeNth 1 X}
   {Browse Y}
end


% ----
% Ex 2
% ----


declare
fun lazy {Filter Xs P}
   case Xs of nil then nil
   [] X|Xr then
      if {P X} then X|{Filter Xr P}
      else {Filter Xr P} end
   end
end

fun lazy {Sieve Xs}
   case Xs of nil then nil
   [] X|Xr then X|{Sieve {Filter Xr fun {$ Y} Y mod X \= 0 end}} end
end

local X in
   X = {Sieve {Gen 2}}

   {Browse X}
   {Wait {Nth X 10}}
   {Wait {Nth X 1000}}
   {Browse {Nth X 1000}}
end





% ----
% Ex 4
% ----

% a)
declare
fun {Gen I N}
   {Delay 250}
   if I==N then [I]
   else I|thread {Gen I+1 N} end end
end

fun {Filter L F}
   case L of nil then nil [] H|T then
      if {F H} then H|thread {Filter T F} end
      else {Filter T F} end
   end
end

fun {Map L F}
   case L of nil then nil
   [] H|T then {F H}|thread {Map T F} end end
end

declare Xs Ys Zs
{Browse Zs}
{Gen 1 10 Xs}
{Filter Xs fun {$ X} (X mod 2)==0 end Ys}
{Map Ys fun {$ X} X*X end Zs}



% b)
declare
fun lazy {Gen I N}
   {Delay 250}
   if I==N then [I]
   else I|{Gen I+1 N} end
end

fun lazy {Filter L F}
   case L of nil then nil [] H|T then
      if {F H} then H|{Filter T F}
      else {Filter T F} end
   end
end

fun {Map L F}
   case L of nil then nil
   [] H|T then {F H}|{Map T F} end
end

declare Xs Ys Zs
{Browse Zs} 
{Gen 1 10 Xs} % don't doing much, going to the next line
{Filter Xs fun {$ X} (X mod 2)==0 end Ys} % don't doing much, going to the next line
{Map Ys fun {$ X} X*X end Zs} % triggering Gen and Filter!



% ----
% Ex 5
% ----

declare
fun lazy {Insert X Ys}
   {Show 'Insert'}
   case Ys of nil then [X]
   [] Y|Yr then
      if X < Y then X|Ys
      else Y|{Insert X Yr} end
   end
end

fun lazy {InSort Xs} %% Sorts list Xs
   {Show 'InSort'}
   case Xs of nil then nil
      [] X|Xr then
   {Insert X {InSort Xr}} end
end

fun {Minimum Xs}
   {InSort Xs}.1
end

declare A1 A2 A3 A4 A5 A6
{Show '-'}
{Insert 6 nil A1}
{Insert 4 A1 A2}
{Insert 5 A2 A3}

{InSort [4 5 6] A4}
{Browse {Minimum [4 3 4]}}
{Browse A3}
{Browse A4}

% Insert:
% complexite max: 2*n avec n le nombre d'elements qu'on insere
% (en fait, si ils sont inseres dans l'ordre croissant on a une complexite de 2*n
% et s'ils sont inseres dans l'ordre decroissant on a une complexite de n)
% InSort:
% complexite: toujours n+1
% => Minimum
% complexite = 2*n + n+1 (ou fois?)
%
% si lazy -> complexite de Minimum = 2*n + 1