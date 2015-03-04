declare

proc {PingPong D P}
   {Delay D} % At least D milliseconds
   {Browse P}
   {PingPong D P}
end

% Ping and Pong in alterration
% This does not guarantee strict alternation !
% Importance of Exact timing
% Many many influences on the scheduler
% Relying on the scheduler is BAD approach

thread {PingPong 500 ping} end
thread {PingPong 500 pong} end

% How can we guarantee strict alternation ?

declare
fun{Ping S}
   case S of ok|S2 then
      {Browse ping}
      ok|{Ping S2}
   end
end

declare
fun{Pong S}
   case S of ok|S2 then
      {Browse pong}
      ok|{Pong S2}
   end
end

% Token passing - we need to insert the first token! 
declare S S2 in
S = ok|S2
thread S2 = {Ping S} end
thread S = {Pong S2} end


% Batch versus incremental
% COmpare functional programming with det. dataflow

% Create a list of 10 intefers [ 1 2 ... 10 ]
% Map in this list to crate the squares

%Assume Generate does a lot of work ( adding {Delay 1000})
declare
fun{Generate L H }
   {Delay 1000}
   if L > H then nil
   else L |{Generate L+1 H}
   end
end

% Functional progam - sequential (one thread)
declare S T in
S = {Generate 1 10}
T = {Map S fun{$ X} X*X end}
T = {Browse T}

%Concurrent version
% Deterministic dataflow
% Incremental
declare S T in
thread S = {Generate 1 10} end
thread T = {Map S fun{$ X} X * X end} end 
{Browse T}

% General rule:
% Deterministic dataflow is much more incremental
% Final result will be exactly the same !
% Threads removing roadblocks
% Add thread wherever you want


% Pipeline programs
declare
fun {Gen L}
   {Delay 1000}
   L|{Gen L+1}
end

declare
proc {Disp S}
   case S of E|S2 then {Browse E} {Disp S2}end
end

%Simple pipelibe
declare S in
thread S = {Gen 1} end
thread {Disp S} end

% Adding a filter
declare S T in
thread S = {Gen 1} end
thread T = {Filter S fun{ $ X} X mod 2 \= 0 end} end
thread U = {Filter T fun{ $ X} X mod 3 \= 0 end} end
thread V = {Filter U fun{ $ X} X mod 5 \= 0 end} end 
thread {Disp V} end

% Agent with more than one input and more than one output

declare
proc {AddMul S T U V}
   case S|T
   of(X|S2)|(Y|T2) then U2 V2 in
      U = X+Y|U2
      V = X*Y|V2
      {AddMul S2 T2 U2 V2}
   end
end

% Seven agents in a pipeline structure
declare S T U V V2 U2 in
thread S = {Gen 1} end
thread T = {Map S fun{ $ X} X+1 end}end
thread {AddMul S T U V} end
thread U2 = {Map U fun {$ X } add(X) end} end
thread V2 = {Map V fun{$ X} mul(X) end } end
thread {Disp U2} end
thread {Disp V2} end

% Sieve of Erotosthemes

declare
fun{Sieve S}
   case S of X|S2 then 
   thread T2 = {Filter S2 fun{$ Y} Y mod X \=0 end} end
   X | {Sieve T2}
   end
end

% Program to crate stram of primes
declare S in
thread S = {Gen 2} end
thread T = {Sieve S} end
thread {Disp T} end 
