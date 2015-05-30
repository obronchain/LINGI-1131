% Lab 4

% 1. (a) because + is blocking while record creation isn't (thanks to incomplete values)
%    (b) just simply add a thread at X binding
local X Y Z in
   thread X = Y+Z end
   Y = 1
   Z = 2
   {Browse X}
end


% 2.
declare
fun {Counter L}
   fun {AddToState C State}
      case State of nil then (C#1)|nil
      [] (C1#N1)|T then N in
	 if C==C1 then N=N1+1 (C1#N)|T
	 else (C1#N)|thread{AddToState C T}end
	 end
      end
   end
   
   fun {SubCounter L State}
      case L of nil then nil
      [] H|T then NewState in
	 NewState = thread{AddToState H State}end
	 NewState|thread {SubCounter T thread NewState end} end
      end
   end
in
      {SubCounter L nil}
end

{Browse {Counter e|m|e|c|_}}

% ca ne marche pas tout a fait :-( la flemme de corriger



% Exercise 3
declare
proc {PassingTheToken Id Tin Tout}
   case Tin of H|T then X in
      {Browse Id#H}
      {Delay 1000}
      Tout = H|X
      {PassingTheToken Id T X}
   [] nil then
      skip
   end
end

local T1 T2 T3 in
   thread {PassingTheToken hello T1 T2} end
   thread {PassingTheToken world T2 T3} end
   thread {PassingTheToken blork T3 T1.2} end
   T1 = token|_
end


% Exercise 4 (daffuq, beer?)
declare
proc {Foo Table}
   case Table of
      Beer|Rest then
      % drink the beer!
      {Browse glouglouglou}
      {Delay 12000}
      {Foo Rest}
   end
end

proc {Bar Table}
   local L1 in
      Table.value = beer|L1
      {Delay 5000}
      {Browse 'you shall be served!'}
      {Bar L1}
   end
end

proc {DisplayTable Table Time}
   {Browse Time#Table}
   {Delay 1000}
   {DisplayTable Table Time+1}
end

local Table in
   thread {Bar Table} end
   thread {Foo Table} end
   thread {DisplayTable Table 0} end
end


