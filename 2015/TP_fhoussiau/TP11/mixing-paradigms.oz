% In this file, we mix paradigms, by creating one from the other. Have a look!
% I put this under TP11, while it actually does some of the things from the TP (yet, not all).
% In particular, we do cells from ports, ports from cells, cells from isDet, lock from cells, lock from ports and a barrier (and lazy).
% Actually, this is more like some kind of revision.


% cell using ports (done with a listening agent!)
declare
proc {NewCellP X C}
   proc {Listen S V}
      case S of exchange(X Y)|T then X=V {Listen T Y} end
   end
   S in
   {NewPort S C}
   thread
      {Listen S X}
   end
end

proc {ExchangeP C X Y}
   {Send C exchange(X Y)}
end

% test
local C in
   {NewCellP 0 C}
   {Browse {ExchangeP C $ 1}}
   {Browse {ExchangeP C $ 42}}
end




% port using cells (particularly clean!)
declare
proc {NewPortC S P}
   {NewCell S P}
end

proc {SendC P M}
   S1 in
   {Exchange P M|S1 S1}
end

% additional challenge
proc {PortClose P} X in
   {Exchange P nil nil}
end

% test
local P S in
   {NewPortC S P}
   %thread for I in S do {Browse I} end end
   {Browse S}
   {SendC P 42}
   {SendC P hello}
   {SendC P sequential#'?'}
   {PortClose P}
end



% Cells using IsDet
declare
fun {NewCellD X}
   X|_
end

proc {ExchangeD C X Y}
   if {IsDet C.2  } then {ExchangeD C.2 X Y}
   else
      X = C.1
      C.2 = Y|_
   end
end


% test (same as above)
local C in
   {Browse C}
   {NewCellD 0 C}
   {Browse {ExchangeD C $ 1}}
   {Browse {ExchangeD C $ 42}}
   {Browse {ExchangeD C $ 84}}
end




% barrier starting all procedures on threads and waiting for termination
declare
proc {Barrier Ps}
   proc {SubBarrier Ps WaitOn}
      case Ps of nil then {Wait WaitOn} W=unit
      [] P|Pr then X in thread {P} X = unit {Wait WaitOn} end {SubBarrier Pr X}
      end
   end
   W
in 
   {SubBarrier Ps unit}
   {Wait W}
end

% test ok!
{Browse hello}
{Barrier [ proc {$} {Delay 2000} {Browse 1} end proc {$} {Delay 2000} {Browse 2} end] }
{Browse world}



% Let us define a test on locks to determine if our implementations (further) are correct
declare
fun {Test NewLock1 N}
   L = {NewLock1}
   Cell = {NewCell 0}
   proc {Tick} R in R = @Cell {Delay 1} Cell := R + 1  end
   fun {BuildPList I}
      if I>N then nil else proc {$} {L Tick} end | {BuildPList I+1} end
   end
in
   {Barrier {BuildPList 1}}
   @Cell
end

fun {NoLock} proc {$ P} {P} end end
fun {OzLock} L in {NewLock L} proc {$ P} lock L then {P} end end end

{Browse {Test NoLock 1000}}
% NoLock yields 1
% OzLock yields 1000 (so it works) (nss)



% lock using cells
declare
fun {NewLockC}
   C in % actual lock
   {NewCell unit C}
   proc {$ P}
      local Old New in % token passing
	 {Exchange C Old New} {Wait Old} {P} unit=New
      end
   end
end

{Browse {Test NewLockC 1000}} % yay! tests succeed! (so it works, i guess)


% lock using ports (kinda useless)
declare
fun {NewLockP}
   P S
in
   {NewPort S P}
   thread for apply(Proc WaitVar) in S do {Proc} WaitVar=unit end end
   proc {$ Proc} X in
      {Send P apply(Proc X)}
      {Wait X}
   end
end

{Browse {Test NewLockP 2000}} % yep! it works!


% lazy using stuff
declare
proc {Lazy F ?R}
   % lazily evaluate the given function
   thread
      {WaitNeeded R}
      R = {F}
   end
end

declare
Ints L
fun {Ints I}
   I|{Lazy fun {$} {Ints I+1} end}
end
L = {Ints 0}
{Browse L.2.2.2.2.2.2.2.1}

