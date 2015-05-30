{Browse 'Hello World'}
{Browse "Hello World"}

local X=x Y=y Z=z in
   {Browse [X Y Z]}
   {Browse a(X Y Z)}
end

declare
fun {Solve1 A B C}
   local Rho in
      Rho = {Sqrt B*B - 4.0*A*C}
      roots( (~B-Rho)/(2.0*A)   (Rho-B)/(2.0*A))
   end
end
{Browse {Solve1 1.0 5.0 ~150.0}}


local
   L = [[1 2 3]]
   fun {Nth L N}
      case L of nil then
	 nil
      [] H|T then
	 if N == 1 then H else
	    {Nth T N-1}
	 end
      end
   end
in
   {Browse L.1.2.1}
   {Browse {Nth {Nth L 1} 2}}
end


{Browse '#'(a:5 b:2 3 4) == '#'(1:3 b:2 a:5 2:4)}

declare
R = '#'(a [b '#'(c d) e] f)
{Browse R.2.2.1.2}

declare
X = a(1 X)
{Browse X}

% let's make a graph
local D B Graph in
   D = d(B e)
   B = b(D c)
   Graph = a( B D )
   {Browse Graph}
end

% 9
local X Y in
   X = 1|2|Y
   X = Y % l'operateur est equivalent (ceci revient a Y=X) :-)
   {Browse X.2.2.1}
end

local X Y Z in
   X = 1|X
   Y = X|Z
   Z = 2|3|4|nil
   {Browse Y.1.2.1}
end

local X Y Z in
   X = a(b X)
   Y = c(X Z)
   Z = d(e f g h)
   {Browse Y.1.2.1}
end

% petite illustration sympa du fonctionnement d'Oz
local A B C X Y in
   X = [2 A 3]
   Y = [B 4 C]
   X = Y
   {Browse X}
end




   
   
