
declare X in
{WaitNeeded X}  % Execution blocks until X is needed
X=100*100

{Browse X}

{Browse X+5}

% Example with Wait

declare X in
{WaitNeeded X}
X=12345

{Wait X}

{Browse X}

% Lazy functions

declare
fun lazy {F A}
   A*A
end

declare X in
X={F 111}

{Browse X}

{Browse X+1}

% Lazy functions are syntax for WaitNeeded
% Translate into kernel language

% Nonlazy version
declare
proc {F A R}
   R=A*A
end

% Lazy version (this is still incorrect)
declare
proc {F A R}
   {WaitNeeded R} R=A*A
end

% Lazy version (correct)
declare
proc {F A R}
   thread {WaitNeeded R} R=A*A end
end

% An infinite list of integers
declare
fun lazy {Ints X}
   X|{Ints X+1}
end

declare
L={Ints 1}
{Browse L}

{Browse L.1} % Need first element
{Browse L.2.1} % Need second element

{Browse L.2.2.2.1}
{Browse L.2.2.1}

{Browse L.2}

% Need the first N elements
declare
proc {Touch L N}
   if N==0 then skip
   else
      {Touch L.2 N-1}
   end
end

{Touch L 10}

{Touch L 20}

% Translation of Ints
declare
proc {Ints I R}
   % Lazy suspension:
   thread {WaitNeeded R} R=I|{Ints I+1} end
end


% Producer-consumer

% Eager version (producer has the limit)
declare
fun {Producer L H}
   if L>H then nil
   else L|{Producer L+1 H}
   end
end
fun {Consumer L A}
   case L of H|T then
      {Consumer T A+H}
   [] nil then A
   end
end

declare L S in
L={Producer 1 100}
S={Consumer L 0}
{Browse S}

% Lazy version
declare
fun lazy {ProducerL L}
   L|{ProducerL L+1}
end
fun {ConsumerL L A N}
   if N==0 then A
   else
      {ConsumerL L.2 A+L.1 N-1}
   end
end

declare L S in
L={ProducerL 1}
S={ConsumerL L 0 100}
{Browse S}

% Bounded buffer in lazy det. dataflow

% Producer-consumer with an unbounded stream
declare
fun lazy {Prod I}
   {Delay 1000}  % Big computation
   I|{Prod I+1}
end

% Consumer also takes a stream and generates a stream
declare
fun lazy {Cons S1 A}
   case S1 of H|T1 then
      {Delay 2000} % Even bigger computation
      A+H|{Cons T1 A+H}
   end
end

% Example use
declare S1 S2 in
S1={Prod 1}
S2={Cons S1 0}
{Browse S2}

{Touch S2 4}

% Let's make the bounded buffer in stages

% First step: a BB that does nothing
declare
proc {BB Xs Ys N}
   fun lazy {Loop Xs}
      case Xs of X|Xr then
	 X|{Loop Xr}
      end
   end
in
   Ys={Loop Xs}
end

declare S1 S2 S3 in
S1={Prod 1}
{BB S1 S2 3}
S3={Cons S2 0}
{Browse S3}

{Touch S3 4}

% Second step: the producer must be ahead of consumer
declare
proc {BB Xs Ys N}
   fun lazy {Loop Xs End}
      case Xs of X|Xr then
	 X|{Loop Xr End.2}
      end
   end End
in
   End={List.drop Xs N} % Force producer to make N el
   Ys={Loop Xs End}
end

% Third step: final version
declare
proc {BB Xs Ys N}
   fun lazy {Loop Xs End}
      case Xs of X|Xr then
	 X|{Loop Xr thread End.2 end}
      end
   end End
in
   thread End={List.drop Xs N} end
   Ys={Loop Xs End}
end
declare S1 S2 S3 in
S1={Prod 1}
{BB S1 S2 3}
S3={Cons S2 0}
{Browse S3}

{Touch S3 4}

{Browse S1}
{Browse S2}

{Touch S3 15}

% Hamming problem

declare
fun lazy {Times S N}
   case S of H|T then N*H|{Times T N} end
end

declare
fun lazy {Merge S1 S2}
   case S1|S2 of (H1|T1)|(H2|T2) then
      if H1<H2 then H1|{Merge T1 S2}
      elseif H1>H2 then H2|{Merge S1 T2}
      else H1|{Merge T1 T2} % Watch out!
      end
   end
end

declare
H=1|{Merge {Times H 2}
     {Merge {Times H 3}
      {Times H 5}}}
{Browse H}
{Touch H 1000}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Extra code added in lecture 07

% Quicksort algorithm: eager version
declare
proc {Partition L X L1 L2}
   case L of H|T then
      if H<X then M1 in
	 L1=H|M1 {Partition T X M1 L2}
      else M2 in
	 L2=H|M2 {Partition T X L1 M2}
      end
   [] nil then L1=nil L2=nil end
end
fun {Append L1 L2}
   case L1 of H|T then H|{Append T L2}
   [] nil then L2 end
end
fun {Quicksort L}
   case L of X|T then L1 L2 S1 S2 in
      {Partition T X L1 L2}
      S1={Quicksort L1}
      S2={Quicksort L2}
      {Append S1 X|S2}
   [] nil then nil
   end
end

{Browse {Quicksort [4 7 3 5 4 3 2]}}
{Browse {Quicksort [4 3]}}

% Quicksort algorithm: lazy version
% (We keep the same Partition as before)
% This does many fewer operations than
% the eager version if not all the sorted
% list is required.
declare
fun lazy {LAppend L1 L2}
   case L1 of H|T then H|{LAppend T L2}
   [] nil then L2 end
end
fun lazy {LQuicksort L}
   case L of X|T then L1 L2 S1 S2 in
      {Partition T X L1 L2}
      S1={LQuicksort L1}
      S2={LQuicksort L2}
      {LAppend S1 X|S2}
   [] nil then nil
   end
end

declare S in
S={LQuicksort [4 7 3 5 4 3 2]} % O(n log n)
{Browse S}

{Browse S.1} % Much less time: O(n)

% k smallest elements out of n
% This code shows the 5th smallest element.
% The first five elements of S give the 5
% smallest elements.
{Browse S.2.2.2.2.1}