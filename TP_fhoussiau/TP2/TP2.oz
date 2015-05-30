declare
proc {Max L R}
   proc {MaxLoop L M R1}
      case L of nil then R1=M
      [] H|T then
	 if M>H then {MaxLoop T M R1}
	 else {MaxLoop T H R1} end
      end
   end
in
   if L==nil then R=error
   else {MaxLoop L.2 L.1 R}
   end
end

local R in R =  {Max [1 2 4 1]} {Browse R} end



declare
fun {Fact N}
   fun {FactList N1 PrevFact}
      if N1>N then nil
      else
	 local Z in
	    Z = PrevFact*N1
	    Z|{FactList N1+1 Z}
	 end
      end
   end
in
   {FactList 1 1}
end

{Browse {Fact 4}}



% Exercise 2
% (a) Not tail recursive, but this version is:
declare
fun {Sum N}
   fun {SubSum N A}
      if N<0 then A
      else {SubSum N-1 N+A}
      end
   end
in
   {SubSum N 0}
end

{Browse {Sum 10}}

% (b) Tail Recursive !
% (c) Already done

local X Y in
   {Browse 'hello nurse'}
   X = sum(2 Y)
   {Browse X}
   {Delay 1000}
   Y = 40
end





% Exercise 4

% (a)
declare
fun {ForAllTail Xs P}
   case Xs of nil then nil
   [] H|T then
      {P Xs}|{ForAllTail T P}
   end
end

{Browse {ForAllTail [1 2 5 4] Max}}


% (b)
declare
Tree = tree(info:10
	    left:tree(info:7
		      left:nil
		      right:tree(info:9
				 left:nil
				 right:nil)
		     )
	    right:tree(info:18
		       left:tree(info:14
				 left:nil
				 right:nil)
		       right:nil)
	    )

declare
fun {GetElementsInOrder Tree}
   case Tree of nil then nil
   [] tree(info:I left:L right:R) then
      {Append {Append {GetElementsInOrder L} [I]} {GetElementsInOrder R}}
   else
      [error]
   end
end

{Browse {GetElementsInOrder Tree}}


% Exercise 5

% (a)
declare
fun {NaiveFib N}
   if N<2 then 1
   else
      {NaiveFib N-1}+{NaiveFib N-2}
   end
end

% {Browse {NaiveFib 35}} % this is slow (nss)


% (b)
declare
fun {Fib N}
   fun {SubFib N A B}
      if N==0 then A else
	 {SubFib N-1 A+B A}
      end
   end
in
   {SubFib N 1 1}
end

for I in 1..10 do
   {Browse {Fib I}}
end



% Exercise 6
declare
fun {Add B1 B2}
   fun {AddDigit D1 D2 CI}
      local S in
	 S=D1+D2+CI
	 output(
	        sum:(S mod 2)
	        carry:(S div 2)
	    )
      end
   end

   fun {SubAdd B1 B2 Carry}
      case B1 of nil then [Carry]
      [] H1|T1 then
	 case {AddDigit H1 B2.1 Carry} of
	    output(sum:S carry:C) then
	    S|{SubAdd T1 B2.2 C}
	 end
      end
   end
   
in
   {Reverse {SubAdd {Reverse B1} {Reverse B2} 0}}
end

{Browse {Add [1 1 0 1 1 0] [0 1 0 1 1 1]}}



% Exercise 7
declare
fun {Filter L F}
   case L of nil then nil
   [] H|T then
      if {F H} then H|{Filter T F} else {Filter T F}
      end
   end
end

% Exercise 8
declare
fun {EvenFilter L}
   {Filter L fun {$ X} (X mod 2)==0 end}
end

{Browse {EvenFilter [0 2 1 3 0 4]}}

% Exercise 9: yep!


%%% ADDITIONAL EXERCISES

% 10
declare
fun {Flatten L}
   
end

% 11
declare
proc {Fact2 N R}
   if N==1 then R=[N]
   else
      Out in
      {Fact2 N-1 Out}
      R = N*Out.1|Out
   end
end
{Browse {Fact2 4}}

% 12
declare
fun {DicoFilter D F}
   case D of leaf then nil
   [] dict(key:K info:I left:L right:R) then
      local D1 D2 in
	 D1 = {DicoFilter L F}
	 D2 = {DicoFilter R F}
	 if {F I} then {Append {Append D1 [K#I]} D2} else {Append D1 D2} end
      end
   end
end

declare
Class=dict(key:10
	   info:
	      person('Christian' 19)
	   left:
	      dict(key:7
		   info:
		      person('Denys' 25)
		   left:leaf
		   right:dict(
			    key:9
			    info:
			       person('David' 7)
			    left:leaf
			    right:leaf
			    )
		  )
	   right:dict(
		    key:18
		    info:person('Rose' 12)
		    left:dict(
			    key:14
			    info:person('Ann' 27)
			    left:leaf
			    right:leaf)
		    right:leaf)
	  )


declare
fun {Old Info}
   Info.2 > 20
end

{Browse {DicoFilter Class Old}}


% 13
declare
fun {Matcher Pattern Value}
   case Value of nil then true
   [] H|T then
      if {Matcher Pattern.1 H} then
	 {Matcher Pattern.2 T} 
      else false
      end
   [] X then
      if X==Pattern then true else Pattern==x end
   end
end

{Browse {Matcher [a x [a x]] [a b [c c]]}}