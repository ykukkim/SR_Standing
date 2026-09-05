function [emgDatawithHeader] = providemuscleheadername(data, musc_headername)

for jj = 1:length(musc_headername)
            hdname = musc_headername{jj};
            commd  = [hdname ...
                ' = data(:,jj)'''';'];
            eval(commd);
end
        emgDatawithHeader = data;