function area = swayarea(x,y)

piece = abs(x(1:end-1) .* y(2:end) - x(2:end) .* y(1:end-1));
area = sum(piece)/2;