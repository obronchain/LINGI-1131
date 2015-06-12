%lab13
%11/06/15

%ansobr


%1
%not correct because @P= and P:= are not atomic

declare
proc {NewPort S P}
   P = {NewCell S}
end
L={NewLock}
proc {Send P Msg}
   NewTail
in
   lock L then
      @P = Msg|NewTail
      P:=NewTail
   end
end


%2
declare
L={NewLock}
fun {ExchangeSafe C X Y}
   lock L then
      Y=@C
      C:=X
   end
end
C={NewCell 0}
Y Z
{Browse {ExchangeSafe C @C+1 Y}}
{Browse {ExchangeSafe C @C+1 Z}}


%3
declare
class BankAccount
   attr money L
   meth init money:=0 L:={NewLock} end
   meth deposit(Amount) lock @L then money:=@money+Amount end end
   meth withdraw(Amount) lock @L then money:=@money-Amount end end
   meth getBalance($) @money end
end

declare
L = {NewLock}
proc {Transfer B1 B2 Amount}
   lock L then
      {B1 withdraw(Amount)}
      {B2 deposit(Amount)}
   end
end

B1 = {New BankAccount init}
B2 = {New BankAccount init}

{B1 deposit(5000)}
{Transfer B1 B2 2300}
{Browse {B1 getBalance($)}}
{Browse {B2 getBalance($)}}


%5
%second is not correct, it's useless to use 2 defferent locks