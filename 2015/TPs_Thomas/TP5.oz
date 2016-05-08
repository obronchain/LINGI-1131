% Lab 5 S5
% Threads and declarative concurrency

% -----------------------
% Ex 1: producer consumer
% -----------------------

% a
declare
fun {Numbers N I J}
   {Delay 500}
   if N==0 then nil
   else ({OS.rand} mod (J-I))+I|thread {Numbers N-1 I J} end end
end

%{Browse {Numbers 3 5 10}}

% b
fun {SumAndCount List}
   local Helper in
      fun {Helper List Acc1 Acc2}
	 {Delay 250}
	 case List of H|T then
	    if T == nil then [Acc1+H Acc2+1]
	    else {Helper T Acc1+H Acc2+1}
	    end
	 end
      end
      {Helper List 0 0}
   end
end

%{Browse {SumAndCount [3 4 4 5]}}

% c
%{Browse {SumAndCount {Numbers 10 5 10}}}
% le temps = (N*500)+250 [ms]

% d
% fun {FilterList Xs Ys}
%    local Helper in
%       fun {Helper Xs Ys Acc}
% 	 case Xs of H|T then
% 	    if T == nil then Acc
% 	    else
% 	       if {IsInList H Ys} then H|{Helper T Ys H}
% 	       else {Helper T Ys Acc}
% 	       end
% 	    end
% 	 end
%       end
%       {Helper Xs Ys


%       end
%    end
% end
declare
fun {FilterList Xs Ys}
   case Xs of H|T then
      if T == nil then nil
      else
	 if {IsInList H Ys} then {Browse 0000} H|{FilterList T Ys}
	 else {Browse 1111} {FilterList T Ys}
	 end
      end
   end
end


fun {IsInList I List}
   case List of H|T then
      if T == nil then
	 if H == I then true
	 else false
	 end
      else
	 if H == I then true
	 else {IsInList I T}
	 end
      end
   end
end

%{Browse {FilterList [1 2 3] [1]}} % faux

%if {IsInList 4 [6 77 9]} then {Browse 0}
%else {Browse 1}
%end


% ------------------------------
% Ex 2: digital logic simulation
% ------------------------------

fun {NotGate St}
   case St of H|T then {Not T}
   else nil
   end
end



%fun {Simulate G}
%   case G
%      of gate(value:'not' input(x) then






% ------------------------
% Ex 3: thread termination
% ------------------------

% a
declare
L1 L2 F
L1 = [1 2 3]
F = fun {$ X} {Delay 200} X*X end
thread L2 = {Map L1 F} end
{Wait L2}
{Show L2}

% b
declare
L1 L2 L3 L4
L1 = [1 2 3]
thread L2 = {Map L1 fun {$ X} {Delay 200} X*X end} end
thread L3 = {Map L1 fun {$ X} {Delay 200} 2*X end} end
thread L4 = {Map L1 fun {$ X} {Delay 200} 3*X end} end
{Wait L2}
{Wait L3}
{Wait L4}
{Show L2#L3#L4}

% c
declare
proc {MapRecord R1 F R2}
   A={Record.arity R1}
   proc {Loop L}
      case L of nil then skip
      [] H|T then
	 thread R2.H={F R1.H} end
	 {Loop T}
      end
   end
in
   R2={Record.make {Record.label R1} A}
   {Loop A}
end

{Show {MapRecord
       '#'(a:1 b:2 c:3 d:4 e:5 f:6 g:7)
       fun{$ X} {Delay 1000} 2*X end}}

