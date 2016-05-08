%% Shared-State concurrency: the Monitor

% dependencies
declare
fun {NewQueue}
   X
   Content = {NewCell q(0 X X)}
   proc {Enqueue X} B E N N1 in
      {Exchange Content q(N B X|E) q(N1 B E)}
      N1 = N+1
   end
   proc {Dequeue ?R} B E N N1 in
      {Exchange Content q(N R|B E) q(N1 B E)}
      N1 = N-1
   end
   fun {IsEmpty}
      @Content.1 == 0
   end
in
   queue(enqueue:Enqueue
	 dequeue:Dequeue
	 isEmpty:IsEmpty)
end

% Monitor definition
% We will not implement an explicit waiting queue: rather unbound variables on which the thread wait.
declare
fun {NewMonitor}
   Q = {NewQueue} % Waiting threads
   Token = {NewCell unit}
   CurThr = {NewCell unit} % for reentrant locks
   LatestToken = {NewCell unit}
   
   proc {Lock}
      if @CurThr == {Thread.this} then skip
      else
	 New Old in
	 {Exchange Token Old New}
	 {Wait Old}
	 LatestToken := New
	 CurThr := {Thread.this}
      end
   end

   proc {ReleaseLock}
      CurThr := unit
      @LatestToken = unit
   end

   proc {MWait} WaitingVar in
      {Q.enqueue WaitingVar}
      {ReleaseLock}
      {Wait WaitingVar}
      {Lock}
   end

   proc {Notify}
      if {Q.isEmpty} then skip else
	 {Q.dequeue} = unit
      end
   end

   proc {NotifyAll}
      if {Q.isEmpty} then skip else
	 {Notify}
	 {NotifyAll}
      end
   end
   
in
   monitor('lock':Lock
	   release:ReleaseLock
	   wait:MWait
	   notify:Notify
	   notifyAll:NotifyAll)
end


% test
local M C in
   {NewMonitor M}
   {NewCell 0 C}
   for I in 1..100 do
      thread R in
	 {M.'lock'}
	 R = @C
	 {Delay 10}
	 C := R+1
	 {M.release}
      end
   end
   {Browse hello}{Delay 2000}{Browse @C}
end

% The lock works!
% We should try the wait and notify operations now
local M C in
   {NewMonitor M}
   {NewCell 0 C}
   for I in 1..10 do
      % thread 1 to 10
      thread R in
	 {M.'lock'}
	 {M.wait}
	 {Browse blood}
	 R = @C
	 {Delay 100}
	 C := R+1
	 {M.release}
      end
   end

   % thread 11
   thread
      {Delay 500}
      {M.'lock'}
      {Browse first}
      {M.notifyAll}
      {M.release}
   end

   % display final result
   {Delay 2000} {Browse @C}
end

% My monitor works :D


% Let's do some Bounded Buffer for fun
declare
class BoundedBuffer
   attr monitor n i head last data
   meth init(N)
      n := N
      i := 0
      head := 0
      last := 0
      monitor := {NewMonitor}
      data := {Array.new 1 10 _}
   end

   meth add(X)
      {@monitor.'lock'}
      if @i == @n then
	 {@monitor.wait}{self add(X)}
      else
	 last := (@last + 1) mod @n
	 @data.(@last+1) := X
	 i := @i + 1
	 {@monitor.notifyAll}
	 {@monitor.release}
      end
   end

   meth get(?R)
      {@monitor.'lock'}
      if @i == 0 then
	 {@monitor.wait} {self get(R)}
      else
	 head := (@head + 1) mod @n
	 R = @data.(@head+1)
	 i := @i - 1
	 {@monitor.notifyAll}
	 {@monitor.release}
      end
   end
   
end



% let us test this bounded buffer with readers and writers
local BB NReaders in
   NReaders = 8
   BB = {New BoundedBuffer init(10)}
   for I in 1..(5*NReaders) do
      thread % writer
	 {Delay {OS.rand} mod 1000}
	 {BB add(I)}
	 {Browse [wrote I]}
      end
   end
   for I in 1..NReaders do
      thread
	 Data = d(_ _ _ _ _) in
	 {Delay 99}
	 for J in 1..5 do % read 5 elements
	    {BB get(Data.J)}
	    {Browse [read Data.J]}
	    {Delay {OS.rand} mod 100}
	 end
	 {Browse [I Data]}
      end
   end
end


% Yep, it works!!!!