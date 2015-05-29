%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    EXO1                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

declare
proc {NewPort S P}
   P = {NewCell S}
end

proc {Send P Msg}
   NewTail
in
   @P = Msg|NewTail
   P := NewTail
end

local P S in
   {NewPort S P}
   {Browse S}
   for I in 1..10 do
      thread  {Send P I} end
   end
end

%Cette implementation fonctionne bien
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    EXO2                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


local X C in
   C = {NewCell 0}
   X = C := X+1
end

%Cela fait en gros C:=X+1 | X = @C Le probleme est que la variable X n'est pas lie dans
%On peut alors se dire qu'on fait
% X = @C
% C:=X+1
% Le probleme est que si ce thread est suspendu entre les deux opperations, cela peut donner une race condition

local X C L in
   L = {NewLock}
   C = {NewCell 0}
   for I in 1..1000 do
      thread {Delay {OS.rand} mod 25}
	 lock L then
	    X in
	    X = @C
	    C:=X+I
	 end
      end
   end
   {Delay 5000}
   {Browse @C}
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    EXO3                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Implementer un BankAccount avec init deposit(Amount) withdraw(Amount) getBalance($)
declare 
class BankAccount
   prop locking
   attr amount
   meth init
      amount:=0
   end
   meth deposit(Amount)
      lock amount:= (@amount+Amount) end
   end
   meth withdraw(Amount)
      lock amount:= (@amount-Amount) end
   end
   meth getBalance(N)
      lock N=@amount end 
   end
end

local Bank in
   Bank = {New BankAccount init}
   for I in 1..20 do
      thread {Delay {OS.rand}mod 50} {Bank deposit(I)} end
   end

   for I in 1..4 do
      thread {Delay {OS.rand} mod 50} {Bank withdraw(I)} end
   end
   {Delay 1000}
   {Browse {Bank getBalance($)}}
end

