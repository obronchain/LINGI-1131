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
