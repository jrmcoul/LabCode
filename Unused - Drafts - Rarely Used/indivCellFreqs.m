active = unnamed ~= 0;


type = zeros(1,size(active,1)); % 1: rest, 2: mot, 3: both, 4: none
for i = 1:size(active,1)
    if active(i,1) == 1 && active(i,2) == 0
        type(i) = 1;
    else if active(i,1) == 0 && active(i,2) == 1
            type(i) = 2;
        else if active(i,1) == 1 && active(i,2) == 1
                type(i) = 3;
            else if active(i,1) == 0 && active(i,2) == 0
                    type(i) = 4;
                end
            end
        end
    end
end

freqMat = zeros(4,3);
for state = 1:4
    freqMat(state,1) = mean(unnamed(find(type == state),1));
    freqMat(state,2) = mean(unnamed(find(type == state),2));
    freqMat(state,3) = length(find(type == state));
end