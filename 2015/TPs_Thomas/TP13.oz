% Lab 13: shared state concurrency and locks

% Exercice 1
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

declare
S P
{NewPort S P}
{Send P 5}
{Send P 10}
{Browse S}

% je ne sais pas...


% Exercice 2
declare
C X
{NewCell 0 C}
{Browse '1'}
X = C := X+1 % signifie % C := X+1
                        % X = @C
                        % attention, l'ordre est important
% ici on voit que X n'est pas lié donc ça bloque à C := X+1
{Browse '2'}

% on aurait envie d'inverser l'ordre des 2 opérations:
% X = @C
% C := X+1
% mais dans ce cas, on n'est pas à l'abris de race conditions

% on peut fixer le problème de la manière suivante:
declare
C X L
C = {NewCell 0}
L = {NewLock} % theorie pp 583 et 598
lock L then
   X = {Access C}
   {Assign C X+1}
end
{Browse X}
{Browse {Access C}}


% Exercice 3
% Yes we need locks because we could unfortunately read X = @cash
% then another thread changes cash
% and then come back to the 1st thread and do cash := X + Amount
% In that case, the new value of cash won't be taken into account!
% -> illustrated by the method depositWrong
% Locks avoid this problem
% -> illustrated by the methode depositGood
declare
class BankAccount
   attr cash l
   meth init()
      cash := 0
      lock := {NewLock}
   end
   meth depositWrong(Amount)
      cash := @cash + Amount
   end
   meth depositGood(Amount)
      local X in
	 lock @l then
	    X = @cash
	    cash := X + Amount
	 end
      end
   end
   meth withdrawWrong(Amount)
      cash := @cash - Amount
   end
   meth withdrawGood(Amount)
      lock @l then
	 cash := @cash - Amount
      end
   end
   meth getBalance($)
      @cash
   end
end

declare
BA
BA = {New BankAccount init()}
{BA depositGood(500)}
{Browse {BA getBalance($)}}


% Exercice 4
declare
proc {Transfer Amount BA1 BA2}
   thread
      {BA1 withdrawGood(Amount)}
      {BA2 depositGood(Amount)}
   end
end

declare
BA1 BA2
BA1 = {New BankAccount init()}
{BA1 depositGood(100000)}
BA2 = {New BankAccount init()}
{BA2 depositGood(100000)}
{Browse {BA1 getBalance($)}#{BA2 getBalance($)}}
for I in 1..10 do
   {Transfer 500 BA1 BA2}
end
{Delay 100}
{Browse {BA1 getBalance($)}#{BA2 getBalance($)}}


% Exercice 5
