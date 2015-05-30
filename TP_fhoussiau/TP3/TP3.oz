% Exercise 4
declare
% Merge two sorted lists
fun {Merge L1 L2}
   case L1#L2 of
      LL#nil then LL
   [] nil#LL then LL
   [] (H1|T1)#(H2|T2) then
      if H1<H2 then H1|{Merge T1 L2}
      elseif H1>H2 then H2|{Merge L1 T2}
      else H1|H2|{Merge T1 T2}
      end
   end
end
% test
% {Browse {Merge [1 2 4 4] nil}}
      

% Split one list into 2 unbound variable lists
declare
proc {Split L L1 L2}
   case L of nil then L1=nil L2=nil
   [] [H] then L1=H|nil L2=nil
   [] H1|H2|T then R1 R2 in
      L1 = H1|R1
      L2 = H2|R2
      {Split T R1 R2}
   end
end
%local L1 L2 in
%   {Split [1 2 3] L1 L2}
%   {Browse L1#L2}
%end


fun {MergeSort L}
   case L of nil then nil
   [] [H] then [H]
   else L1 L2 in
      {Split L L1 L2}
      {Merge thread {MergeSort L1} end
             thread {MergeSort L2} end }
   end
end



local L Repeat Mod in
   fun {Repeat F N X}
      if N==0 then nil
      else Y in Y={F X} Y|{Repeat F N-1 Y}
      end
   end
   fun {Mod X}
      ((X+119) mod 103)
   end
   L = {Repeat Mod 10000 1}
   {Browse {MergeSort L}}
end




% Exercise 5
declare
fun {IntProducer N Max}
   if N > Max then nil
   else N|thread{IntProducer N+1 Max}end end
end
fun {SumConsumer L}
   case L of nil then 0
   [] H|T then H+{SumConsumer T}
   end
end

{Browse {SumConsumer {IntProducer 1 100}}}


% Exercise 6
declare
fun {OddFilter L}
   case L of nil then nil
   [] H|T then
      if (H mod 2)==0 then thread {OddFilter T} end
      else H|thread {OddFilter T} end end
   end
end


{Browse {SumConsumer {OddFilter {IntProducer 1 5}}}}


% Last Exercise
% first, re-implementation of ping-pong for fun
declare
proc {PingWaiter L MyDelay Label}
   case L of nil then skip
   [] H|T then
      {Browse Label}
      {Delay MyDelay}
      local L1 in
	 T = _|L1
	 {PingWaiter L1 MyDelay Label}
      end
   end
end

local L in
   {Browse start}
   thread {PingWaiter L 1000 ping} end
   thread {PingWaiter L.2 0 pong} end
   L = _|_
end


% Teacher's ping pong
declare
proc {Ping L}
   case L of H|T then T2 in
      {Delay 500} {Browse ping}
      T= _|T2
      {Ping T2}
   end
end
proc {Pong L}
   case L of H|T then T2 in
      {Browse pong}
      T= _|T2
      {Pong T2}
   end
end

local L in
   {Browse teacher}
   thread {Ping L} end
   thread {Pong L.2} end
   L = _|_
end

