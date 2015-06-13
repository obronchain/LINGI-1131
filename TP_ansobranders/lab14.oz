%lab14
%11/06/15

%ansobr

%1
%code monitor
declare
fun {NewQueue}
   X in
   q(0 X X)
end   

fun {Insert q(N S E) X}
   E1 in
   E=X|E1 q(N+1 S E1)
end

fun {Delete q(N S E) X}
   S1 in
   S=X|S1 q(N-1 S1 E)
end

fun {DeleteNonBlock q(N S E) X}
   if N>0 then H S1 in
      X=[H] S=H|S1 q(N-1 S1 E)
   else
      X=nil q(N S E)
   end
end

fun {DeleteAll q(_ S E) L}
   X in
   L=S E=nil
   q(0 X X)
end

fun {Size q(N _ _)} N end

declare
proc {NewMonitor ?LockM ?WaitM ?NotifyM ?NotifyAllM}
   Q={NewCell {NewQueue}}
   Token1={NewCell unit}
   Token2={NewCell unit}
   CurThr={NewCell unit}

   % Returns true if got the lock, false if not (already inside)
   fun {GetLock}
      if {Thread.this}\=@CurThr then Old New in
	 {Exchange Token1 Old New}
	 {Wait Old}
	 Token2:=New
	 CurThr:={Thread.this}
	 true
      else false end
   end
   
   proc {ReleaseLock}
      CurThr:=unit
      unit=@Token2
   end
in
   proc {LockM P}
      if {GetLock} then
	 try {P} finally {ReleaseLock} end
      else {P} end
   end
   
   proc {WaitM}
      X in
      Q:={Insert @Q X}
      {ReleaseLock} {Wait X}
      if {GetLock} then skip end
   end
   
   proc {NotifyM}
      X in
      Q:={DeleteNonBlock @Q X}
      case X of [U] then U=unit else skip end
   end
   
   proc {NotifyAllM}
      L in
      Q:={DeleteAll @Q L}
      {ForAll L proc {$ X} X=unit end}
   end
end

%mvar

declare
class Mvar
   attr box lockM waitM notifyM
   meth init box:=nil {NewMonitor @lockM @waitM @notifyM _} end
   meth put(X)
      {@lockM proc{$}
		 if @box == nil then box:=X {@notifyM}
		 else {@waitM} {self put(X)}
		 end
	      end
      }
   end
   meth get(X)
      {@lockM proc{$}
		 if @box == nil then {@waitM} {self get(X)}
		 else X=@box box := nil {@notifyM}
		 end
	      end
      }
   end
end

%test
declare
X Y
Box={New Mvar init}
{Box put(23)}
{Box get(X)}
{Browse X}
{Box put(42)}
{Box get(Y)}
{Browse Y}

declare
proc {MakeMvar MPut MGet}
   MV = {New Mvar init}
in
   proc {MPut X}
      {MV put(X)}
   end
   proc {MGet X}
      {MV get(X)}
   end
end

%test
MPut MGet
{MakeMvar MPut MGet}
{MPut 17}


%Example of the lesson : bounded buffer with monitors
declare
class BB
   attr buf first last n i lockm waitm notifym notifyallm
   meth init(N) buf:={NewArray 0 N-1 null}
      n:=N i:=0 first:=0 last:=0
      {NewMonitor @lockm @waitm @notifym @notifyallm}
   end
   meth put(X)
      {@lockm
       proc{$}
	  if @i>=@n then {@waitm} {self put(X)}
	  else
	     @buf.@last := X
	     @last:=(@last+1) mod @n
	     @i:=@i+1
	     {@notifyallm}
	  end
       end
       
      }
   end
   meth get(X)
      {@lockm
       proc{$}
	  if @i==0 then {@waitm} {self get(X)}
	  else
	     X=@buf.@first
	     @first:=(@first+1) mod @n
	     @i:=@i-1
	     {@notifyallm}
	  end
       end
      }
   end
end


%2
%code transaction prof
%%%%%% Active objects
declare
fun {NewActive Class Init}      
   Obj={New Class Init}    
   P
in
   thread S in
      {NewPort S P}
      {ForAll S proc {$ M} {Obj M} end}
   end
   proc {$ M} {Send P M} end
end


%%%%%% Priority queue
declare
fun {NewPrioQueue}
   Q={NewCell nil}
   proc {Enqueue X Prio}
      fun {InsertLoop L}
         case L of pair(Y P)|L2 then
            if Prio<P then pair(X Prio)|L
            else pair(Y P)|{InsertLoop L2} end
         [] nil then [pair(X Prio)] end
      end
   in Q:={InsertLoop @Q} end

   fun {Dequeue}
      pair(Y _)|L2=@Q
   in
      Q:=L2 Y
   end

   fun {Delete Prio}
      fun {DeleteLoop L}
         case L of pair(Y P)|L2 then
            if P==Prio then X=Y L2
            else pair(Y P)|{DeleteLoop L2} end
         [] nil then nil end
      end X
   in Q:={DeleteLoop @Q} X end

   fun {IsEmpty} @Q==nil end
in
   queue(enqueue:Enqueue dequeue:Dequeue
         delete:Delete isEmpty:IsEmpty)
end

%%%%%% Transaction manager
declare
class TMClass
   attr timestamp tm
   meth init(TM) timestamp:=0 tm:=TM end
    
   meth Unlockall(T RestoreFlag)
      for save(cell:C state:S) in {Dictionary.items T.save} do
         (C.owner):=unit
         if RestoreFlag then (C.state):=S end
         if {Not {C.queue.isEmpty}} then
         Sync2#T2={C.queue.dequeue} in
            (T2.state):=running
            (C.owner):=T2 Sync2=ok
         end
      end
   end
  
  meth Trans(P ?R TS)
     Halt={NewName}
     T=trans(stamp:TS save:{NewDictionary} body:P
             state:{NewCell running} result:R)
     proc {ExcT C X Y} S1 S2 in
        {@tm getlock(T C S1)}
        if S1==halt then raise Halt end end
        {@tm savestate(T C S2)} {Wait S2}
        {Exchange C.state X Y}
     end
     proc {AccT C ?X} {ExcT C X X} end
     proc {AssT C X} {ExcT C _ X} end
     proc {AboT} {@tm abort(T)} R=abort raise Halt end end
  in
     thread try Res={T.body t(access:AccT assign:AssT
                              exchange:ExcT abort:AboT)}
            in {@tm commit(T)} R=commit(Res)
            catch E then
               if E\=Halt then {@tm abort(T)} R=abort(E) end
     end end
  end
  
  meth getlock(T C ?Sync)
     if @(T.state)==probation then
        {self Unlockall(T true)}
        {self Trans(T.body T.result T.stamp)} Sync=halt
     elseif @(C.owner)==unit then 
        (C.owner):=T Sync=ok
     elseif T.stamp==@(C.owner).stamp then
        Sync=ok
     else /* T.stamp\=@(C.owner).stamp */ T2=@(C.owner) in
        {C.queue.enqueue Sync#T T.stamp}
        (T.state):=waiting_on(C)
        if T.stamp<T2.stamp then
           case @(T2.state) of waiting_on(C2) then
           Sync2#_={C2.queue.delete T2.stamp} in
              {self Unlockall(T2 true)}
              {self Trans(T2.body T2.result T2.stamp)}
              Sync2=halt
           [] running then
              (T2.state):=probation
           [] probation then skip end
        end
     end
  end 

   meth newtrans(P ?R)
      timestamp:=@timestamp+1 {self Trans(P R @timestamp)}
   end
   meth savestate(T C ?Sync)
      if {Not {Dictionary.member T.save C.name}} then
         (T.save).(C.name):=save(cell:C state:@(C.state))
      end Sync=ok
   end
   meth commit(T) {self Unlockall(T false)} end
   meth abort(T) {self Unlockall(T true)} end
end

proc {NewTrans ?Trans ?NewCellT}
TM={NewActive TMClass init(TM)} in
   fun {Trans P ?B} R in
      {TM newtrans(P R)}
      case R of abort then B=abort unit
      [] abort(Exc) then B=abort raise Exc end
      [] commit(Res) then B=commit Res end
   end
   fun {NewCellT X}
      cell(name:{NewName} owner:{NewCell unit}
           queue:{NewPrioQueue} state:{NewCell X})
   end
end


%ex2
declare
Trans NewCellT
{NewTrans Trans NewCellT}

T={MakeTuple db 1000}
for I in 1..1000 do T.I={NewCellT I} end

fun {Rand} {OS.rand} mod 1000+1 end
proc {Mix}
   {Trans
    proc {$ Acc Ass Exc Abo _}
       I={Rand} J={Rand} K={Rand}
       if I==J orelse I==K orelse J==K then {Abo} end
       A={Acc T.I} B={Acc T.J} C={Acc T.K}
    in
       {Ass T.I A+B-C}
       {Ass T.J A-B+C}
       {Ass T.K B-A+C}
    end
    _ _ }
end

S={NewCellT 0}

fun {Sum}
   {Trans
    fun{$ Acc Ass Exc Abo}
       for I in 1..1000 do
	  {Ass S {Acc S} + {Acc T.I}} end
       {Acc S}
    end
    _}
end

{Browse {Sum}} %Displays 500500
for I in 1..1000 do {Mix} end %Mixes up the elements
{Browse {Sum}} %Still displays 500500


      