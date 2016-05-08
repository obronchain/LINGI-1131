% declare
% [MinMax] = {Module.link ['MinMax.ozf']}
% {Browse {MinMax.max 42 7}}

% Functor mode

functor
import
   Application
   System
   MinMax at 'MinMax.ozf'
define
   {System.show {MinMax.max 42 7}}
   {Application.exit 0}
end
