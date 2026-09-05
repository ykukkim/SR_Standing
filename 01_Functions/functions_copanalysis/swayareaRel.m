function area = swayareaRel(x,y,period)

piece = abs(x(1:end-1) .* y(2:end) - x(2:end) .* y(1:end-1))/2;
area = sum(piece)/period;