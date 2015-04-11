% Lab 8: message passing

% ----
% Ex 1
% ----

declare
proc {ReadList L}
   case L of H|T then
      {Browse H}
      {ReadList T}
   end
end

declare
L = [1 2 3 4 5]
{ReadList L}


% ----
% Ex 2
% ----

declare
P S
{Browse S}
{Delay 1000}

{NewPort S P}
{Delay 1000}

{Send P foo}
{Delay 1000}

{Send P bar}



% ----
% Ex 3
% ----

declare
P S
{Browse '-'}

{NewPort S P}

{Send P foo}
thread {ReadList S} end

{Send P bar}
thread {ReadList S} end 


{Browse {OS.rand} mod 2000 + 1000}


% ----
% Ex 4
% ----

declare
proc {RandomSenderManiac N P}
   if N==0 then
      skip
   else
      thread
	 local Time in
	    Time = {OS.rand} mod 2000 + 1000
	    {Delay Time}
	 end
	 {Send P N}
      end
      {RandomSenderManiac N-1 P}
   end
end


% ----
% Ex 5
% ----
{Browse '-'}
declare
P S
{NewPort S P}
thread {ReadList S} end
{RandomSenderManiac 4 P}

% On observe que d'une execution a l'autre, on obtient un stream S different.
% En fait c'est l'ordre des elements qui est different.
% => non-determinisme
% mais les variables restent inchangees donc pas besoin de mutex etc etc :)



% ----
% Ex 6
% ----

declare
fun {WaitTwo X Y}
   local P S in
      {NewPort S P}
      thread {Wait X} {Send P 1} end
      thread {Wait Y} {Send P 2} end
      case S of H|T then H end
   end
end

declare
X Y
X=45
Y=99
{Browse {WaitTwo X Y}}



% ----
% Ex 7
% ----

declare
fun {Server}  % returns the port to use with this server
              % this is a more generic implementation
   {NewPort S P} % P = {Port.new S}
in
   fun {Helper S}
      case S of (Msg#Ack)|T then
	 {Browse Msg}
	 {Delay {OS.rand} mod 1000 + 500}
	 Ack = unit
      end
   end
in
   thread {Helper S}
      P
   end
end


declare
Port = {Server}
{Send Port hello|_}
{Send Port world|_}
