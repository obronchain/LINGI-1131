functor
import 
	System
	Application
define
local
	F1 = fun {$ X} X*X end
	F2 = fun {$ X} X+X end
in
	{System.show {F1 3} - {F2 3} + 4}
	{Application.exit 0}
end

end
