result = {};
for i = 1:size(unnamed, 1)
    for j = 1:size(unnamed,2)
        if isempty(unnamed{i,j}) || unnamed{i,j} == 0
            result{i,j} = nan;
        else
            result{i,j} = unnamed{i,j};
        end
    end
end


subtracted = {};
for i = 1:size(result, 1)
    subtracted{i,1} = result{i,2} - result{i,1};
end

divided = {};
for i = 1:size(result, 1)
    divided{i,1} = result{i,2}/result{i,1};
end