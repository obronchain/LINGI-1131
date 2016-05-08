%%% The mine counter

% declarative lazy definition
declare
fun {Counter Xs State}
   fun {AddToState X State}
      case State of (Y#N)|T then
	 if Y==X then (Y#N+1)|T
	 else (Y#N)|{AddToState X T} end
      [] nil then [(X#1)]
      end
   end
in
   case Xs of X|Xr then NewState in
      NewState = {AddToState X State}
      NewState|{Counter Xr NewState}
   end
end

fun lazy {Mine}
   Miners = m(0:juan 1:rodrigo 2:suarez)
   N = {Width Miners}
in
   Miners.({OS.rand} mod N) | {Mine}
end

% test
declare
L = {Counter {Mine} nil}
{Browse L}
_ = {List.drop L 10}

% as you may notice, it works

% let us just define touch
declare proc {Touch L N} _ = {List.drop L N} end



% now, let's do a stream merge (non-deterministic).
% Streams is a tuple containing some streams.
declare
proc {Merger Streams ?OutputStream}
   proc {InputStream S}
      case S of H|T then
	 {Send Port H}
	 {InputStream T}
      else skip end
   end
   Port
in
   for I in 1..{Width Streams} do
      thread {InputStream Streams.I} end
   end
   {NewPort OutputStream Port}
end

% This WILL NOT WORK with laziness, therefore, we must remove the lazy flags from previous functions to reuse them here:
declare
fun {Counter Xs State}
   fun {AddToState X State}
      case State of (Y#N)|T then
	 if Y==X then (Y#N+1)|T
	 else (Y#N)|{AddToState X T} end
      [] nil then [(X#1)]
      end
   end
in
   case Xs of X|Xr then NewState in
      NewState = {AddToState X State}
      NewState|{Counter Xr NewState}
   end
end

% Also, let's change this mine to a more suitable one (you extract people slowly)
fun {Mine}
   Miners = m(0:juan 1:rodrigo 2:suarez)
   N = {Width Miners}
   Miner = Miners.({OS.rand} mod N)
in
   {Delay 500+({OS.rand} mod 2000)}
   {Browse 'just saved '#Miner}
    Miner|{Mine}
end

fun {TMine}
   thread {Mine} end
end


% Mine simulation!
{Browse 'saving miners!'}
for Item in thread {Counter thread {Merger {TMine}#{TMine}#{TMine}}end nil} end do
   {Browse 'current status: '|Item}
end




%%% Passing the token
declare
proc {PassingTheToken Id Prev Succ}
   case Prev of H|T then Next in
      {Browse Id#H}
      {Delay 1000}
      Succ = H|Next
      {PassingTheToken Id T Next}
   [] nil then
      skip
   end
end

local T1 T2 T3 in
   thread {PassingTheToken 1 token|T1 T2} end
   thread {PassingTheToken 2 T2 T3} end
   thread {PassingTheToken 3 T3 T1} end
end







%%% Foo vs Bar
declare

% but first, let's make a better browse
Clock = {NewCell 0}
proc {ClockProcess}
   {Delay 99}
   Clock := @Clock + 1
   {ClockProcess}
end

proc {TBrowse Browsable}
   {Browse 'time: '|@Clock|' '|Browsable}
end


proc {BB N Xs ?Ys}  % Bounded Buffer with explicit laziness
   proc {BB Xs End ?Ys}
      case Ys of Y|Yr then End2 Xr in
	 Y|Xr = Xs
	 End = _|End2
	 {BB Xr End2 Yr}
      end
   end
   fun {EmptyList N} if N>0 then _|{EmptyList N-1} else End end end
   End
in
   Xs = {EmptyList N}
   {BB Xs End Ys}
end

proc {Bar ?Ys}
   case Ys of Y|Yr then
      Y = beer
      {TBrowse 'served!'}
      {Delay 500}
      {Bar Yr}
   end
end

proc {Foo Xs N}
   X Xr in
   Xs = X|Xr
   if X==beer then
      {TBrowse 'drank! '#N}
      {Delay 1200}
   else
      {Browse 'wait? That is not beer!'}
   end
   {Foo Xr N+1}
end

% test
thread {ClockProcess} end
{Foo thread {BB 4 thread {Bar} end} end 0}



%%% MapRecord

declare
proc {MapRecordWait R1 F WaitVar ?R2}
   A = {Arity R1}
   WT = {Record.make threads A}
   proc {Loop L}
      case L of nil then skip
      [] H|T then
	 thread R2.H = {F R1.H} WT.H=unit end
	 {Loop T}
      end
   end
in
   R2 = {Record.make {Label R1} A}
   {Loop A}
   % wait for all to complete on this thread:
   thread for X in A do {Wait WT.X} end WaitVar=unit end
end

local W in
   {Browse {MapRecordWait hello(1 1000 2000 3000) fun {$ X} {Delay X} X*X end W}}
   {Wait W} {Browse done}
end
