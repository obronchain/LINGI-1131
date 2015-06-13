%%%%%%%%% This is a review of lab 13. 12 juin 2015 %%%%%%%%%
%Lab 13 Shared State Concurreency and Locks

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Exo1                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% is this implementation correct ? free of race ?

declare
proc{NewPort S P }
   P = {NewCell S }
end

proc{Send P Msg}
   NewTail
in
   @P = Msg|NewTail
   P:=NewTail
end

%This implemenation is not correct. In fact, if the thread
%interupt between the two opperations, it can fucked up.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Exo2                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Why does local X in X = C := X+1 end not work ?
% How to fix it ?

local X C in
   C = {NewCell 4}
   X = C := X+1 % est equivalent a C:=X+1 X = @C 
   {Browse X}
end

%This is the same as C := X+1 X = @C. It doesn't
% work because X is unbound
%We could fix it using X=@C  C := X+1 but this is
% not free of race. The final solution is then

local C L in
   L = {NewLock}
   C = {NewCell 0}
   for I in 1..1000 do
      thread
	 lock L then
	    X in
	    X = @C
	    C := X+1
	 end
      end   
   end
   {Delay 5000}
   {Browse @C}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Exo3                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implement BankAcount with init , depost, withdraw
% getbalance($)

declare
class BankAccount
   attr l count
   meth init(N)
      count:= N l:={NewLock}
   end
   meth deposit(Amount)
      lock @l then
	 count:=@count+Amount
      end
   end
   meth withdraw(Amount)
      lock @l then
	 count:= @count-Amount
      end
   end
   meth getBalance($)
      lock @l then
	 @count
      end
   end
end

local Bank X in
   Bank = {New BankAccount init(1000)}
   {Bank deposit(10)}
   {Bank getBalance(X)}
   {Browse X}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Exo4                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implement a procedure to transfer money from
% one account to an other one
declare 
proc{Transfer Account1 Account2 Amount}
   {Account1 withdraw(Amount)}
   {Account2 deposit(Amount)}
end

%%%%%% Test Exo4 %%%%%%%
% this will be correct because each count is sure

local Ending Account N C2 C1 in
   N = 3000
   C1 = {NewCell 0}
   C2 = {NewCell 0}
   {MakeTuple 'accounts' N Account}
   {MakeTuple 'ending' N Ending}
   for I in 1..N do
      X in
      X = {OS.rand} mod N
      C1 := @C1 + X
      Account.I = {New BankAccount init(X)}
   end

   for I in 1..N do
      X1 X2 V in
      V = {OS.rand} mod N
      X1 = ({OS.rand} mod N)+1
      X2 = ((X1+100) mod N)+1
      thread {Transfer Account.X1 Account.X2 V} Ending.I=ok end 
   end

   for I in 1..N do
      {Wait Ending.I}
   end

   for I in 1..N  do
      X in
      {Account.I getBalance(X)}
      C2 := @C2 + X
   end

   {Browse @C1==@C2}
end   
