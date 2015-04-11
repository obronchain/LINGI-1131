%exo 1
declare ReadList
proc{ReadList L}
   case L of nil then skip
   [] H|T then {Browse H} {ReadList T}
   end
end
{ReadList 1|3|14|23|nil}

%exo 2
declare P S
{NewPort S P}

{Send P foo}
{Send P bar}
{Browse S}
{Browse P}

%exo 3
declare P S
{NewPort S P}
{ReadList S}
{Send P foo}
{Send P bar}
{Send P 'jaime la soeur de nico'}

%exo 4-5 
declare RandomSenderManiac N P S
proc {RandomSenderManiac N P}
   local
      proc{OneThread I}
	 if I==N+1 then skip
	 else
	    {Delay (({OS.rand} mod 3) +1)*1000}
	    {Send P I}
	    {OneThread I+1}
	 end
      end
      proc{Run I}
	 if I==0 then skip
	 else thread {OneThread 1} end {Run I-1}
	 end
      end
   in
      {Run N}
   end   
end

{NewPort S P}
{Browse P}
{RandomSenderManiac 10 P}
{ReadList S}

%exo 6
declare WaitTwo X Y
fun{WaitTwo X Y}
   local S P in
      {NewPort S P}
      thread {Wait X} {Send P 1} end
      thread {Wait Y} {Send P 2} end
      case S of H|T then H end 
   end
end
{Browse {WaitTwo X Y }}
X = 42

%exo 7
declare Server 
proc{Server S}
   case S of Msg#Ack|T then
      {Delay (({OS.rand} mod 1000)+500)}
      Ack=unit
   end
end

%exo 8
declare SafeSend S P Result
fun{SafeSend P M T}
   local X Ack Val in
      {Send P M#Ack}
      thread Val = {WaitTwo X Ack} end
      {Delay T}
      X = unit
      if Val == 2 then true
      else false
      end
   end
end

{NewPort S P }
thread {Server S} end
thread Result = {SafeSend P tamere 1000} end 
{Browse Result}

%exo 9
declare WriteOnPipe Counter Result X1 X2 X3 X4 X5 Y1 Y2 Y3 Y4 Y5 Z1 Z2 Z3 Z4 Z5 P S
proc{WriteOnPipe L P}
   case L of H|T then {Send P H} {WriteOnPipe T P} end
end

declare
fun{Counter Ins}
   local AddL Run in
      fun{AddL L E}
	 case L of nil then E#1|nil
	 [] C#N|Next then
	    if C==E then C#(N+1)|Next
	    else C#N|{AddL Next E}
	    end
	 end
      end

     fun{Run In Actual}
	 case In of nil then nil
	 [] H|T then local Acc in
			Acc = {AddL Actual H}
			Acc|{Run T Acc}
		     end
	 end
      end
      
      {Run Ins nil}
   end
   
end
      
{NewPort S P}
thread {WriteOnPipe X1 P} end
thread {WriteOnPipe Y1 P} end
thread {WriteOnPipe Z1 P} end
thread Result={Counter S} end
{Browse Result}
X1 = e|X2
Y1 = e|Y2
Z1 = g|Z2

%exo 10
declare 
fun{MergeTwoStream X Y}
   local S P in
      {NewPort S P}
      thread {WriteOnPipe X P} end
      thread {WriteOnPipe Y P} end
      S
   end
end

