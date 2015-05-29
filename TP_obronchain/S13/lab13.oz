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
   meth init(Amount)
      amount:=Amount
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
   Bank = {New BankAccount init(1000)}
   for I in 1..20 do
      thread {Delay {OS.rand}mod 50} {Bank deposit(I)} end
   end

   for I in 1..4 do
      thread {Delay {OS.rand} mod 50} {Bank withdraw(I)} end
   end
   {Delay 1000}
   {Browse {Bank getBalance($)}}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    EXO4                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Add a procedure to transfer money from an BankAccount to an other one
%We create a meth in BankAccount
%On lock le compte 1 . On termine le lock, ainsi si l'autre compte veut aussi nous verser de la tune
%Il peut car il n'est pas bloque. Un fait alors un {Bank2  deposit(Amount)} pour que l'autre receptionne la tune
%Cette operation est egalement securisee comme mis plut haut

declare 
class BankAccount
   prop locking
   attr amount
   meth init(Amount)
      amount:=Amount
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
   meth transfer(Amount To)
      lock amount:= (@amount-Amount) end
      {To deposit(Amount)}
   end
end

fun{Count L N}
   case L of nil then N
   [] H|T then {Count T N+H}
   end
end

local 
   Bank1 = {New BankAccount init(1000)}
   Bank2 = {New BankAccount init(2000)}
   Money1To2 = 200|400|100|200|10|210|200|nil
   Money2To1 = 100|300|10|100|120|213|42|213|23|12|nil
   Total1
   Total2
in
   Total1={Count Money1To2 0}
   Total2={Count Money2To1 0}
   
   for I in Money1To2 do
      thread {Delay {OS.rand}mod 50} {Bank1 transfer(I Bank2)} end
   end

   for I in Money2To1 do
      thread {Delay {OS.rand} mod 50} {Bank2 transfer(I Bank1)} end
   end
   {Delay 1000} 
   
   {Browse [1000-Total1+Total2 {Bank1 getBalance($)}]}
   {Browse [2000-Total2+Total1 {Bank2 getBalance($)}]}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    EXO5                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Le probleme arrive dans le second cas. En effet supposons que le head et le tail soient
%Lock en meme temps. le thread du tail est suspendu alors que le head ne l'est pas est commence
%a retirer plein d'element jusqu'au moment ou le head et le tail soient les meme. Il y a donc une erreur
%a ce moement la.
%Il en est de meme si il n'y a pas d'element dans la FIFO 