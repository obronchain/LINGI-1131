%exo 1
declare
A B N S
Res1 Res2 Res3 Res4 Res5 Res6 LaunchServer

fun{LaunchServer}
   local S P Action in
      proc{Action S}
	 case S of
	    'div'( X Y R)|T then thread if Y==0 then R=notNumber else R = X div Y end end {Action T}
	 [] add( X Y R)|T then thread R = X + Y end  {Action T}
	 [] pow( X Y R)|T then thread R = {Number.pow X Y} end  {Action T}
	 [] H|T then {Browse 'not known expression'} {Action T}
	 end
      end
      {NewPort S P}
      thread {Action S} end 
      P
   end
end

S = {LaunchServer}
{Send S add(321 345 Res1)}
{Wait Res1}
{Show Res1}
{Send S pow(2 N Res2)}
N =8
{Wait Res2}
{Show Res2}
{Send S add(A B Res3)}
{Send S add(10 20 Res4)}
{Send S foo}
{Wait Res4}
{Show Res4}
A =3
B = 0 - A
{Send S 'div'(90 Res3 Res5)}
{Send S 'div'(90 Res4 Res6)}
{Wait Res3}
{Show Res3}
{Wait Res5}
{Show Res5}
{Wait Res6}
{Show Res6}

%exo 2
declare StudentRMI CreateUniversity Charlotte L 
fun {StudentRMI}
   S
in
   thread
      for ask(howmany:Beers) in S do
	 Beers = {OS.rand} mod 24
      end
   end
   {NewPort S}
end

fun {CreateUniversity Size}
   fun {CreateLoop I}
      if I =< Size then
	 {StudentRMI}|{CreateLoop I+1}
      else
	 nil
      end
   end
in
   %% Kraft dinner is full of love and butter
   {CreateLoop 1}
end

fun{Charlotte L Size}
   local
      fun{Run L Max Min Mean Tot N}
	 NewMax NewMin Beers in 
	 case L of P|T then
	    {Send P ask(howmany:Beers)}
	    if Beers > Max then NewMax = Beers else NewMax = Max end
	    if Beers < Min then NewMin = Beers else NewMin = Min end  
	    {Run T NewMax NewMin (((Mean*(N-1)) + Beers) div N) Tot+Beers N+1}           [] nil then result(max:Max min:Min mean:Mean tot:Tot n:N)
	 end
      end
   in
      thread {Run L 0 25 0 0 1} end
   end
end

L = {CreateUniversity 10}
{Browse {Charlotte L 10}}

%exo 3 

