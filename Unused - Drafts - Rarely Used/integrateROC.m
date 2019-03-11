function areaUnder = integrateROC(curve)

% areaUnder = integrateROC(curve)
% 
% Summary: 
%
% Inputs:
%
% 'curve' - 
%
% Outputs:
%
% 'areaUnder' - 
%
% Author: Jeffrey March, 2018

areaUnder = 0;
for i = 1:size(curve,1) - 1
    run = curve(i+1,1) - curve(i,1);
    if run == 0
        continue
    else
        tempArea = run*(curve(i,2) + curve(i+1,2))/2;
        areaUnder = areaUnder + tempArea;
    end
end
areaUnder = areaUnder - .5;

end



