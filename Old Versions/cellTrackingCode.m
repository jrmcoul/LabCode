%Categories:
%Motor vs. Nonmotor
%Prelesion => Acute Postlesion => Chronic Postlesion => L-dopa 1 day =>
%L-dopa 1 week

%Fields:
%Mouse
%Cell Type
%DF/F

%cellTracking
%First 

SW033 = struct('D1',{},'D2',{});
conditions = {'pre', 'postA', 'postC', 'levoA', 'levoC', ...
    'preSpont','postASpont','postCSpont','levoASpont','levoCSpont'};
pre = 1:3;
postA = 4:6;
postC = 7:9;
levoA = 10:12;
levoC = 13:15;
preS = pre + 15;
postAS = postA + 15;
postCS


cellTracking;
for row = 1:size(cellTracking,1)
    for column = 1:size(cellTracking,2)
        if isempty(cellTracking{row,column})
            continue
        end
        
        
    end
end



cell = {roi


cellType = floor(cellLabel/1000);
switch cellType
    case 1
        roi = data.dF1;
    case 2
        roi = data.dF2;    
end

switch cellType
    case 1
        mouse.dF1 = data.dF1;
    case 2
        mouse.dF1 = data.dF2;    
end

switch floor(column/3)
    case 1
        mouse.pre;
    case 2
        roi = data.dF2; 
    case 3
    case 4
    case 5
end


%% Creating the cell structure

condit = struct;
condit.dF = {};
condit.vel = {};
condit.accel = {};
condit.framerate = {};
condit.peakFreqRestMot = {};
condit.peakHeights = {};
condit.riseTimes = {};
condit.decayTimes = {};

motorState = struct;
motorState.pre = condit;
motorState.postA = condit;
motorState.postC = condit;
motorState.levoA = condit;
motorState.levoC = condit;

neuron = struct;
neuron.motor = motorState;
neuron.spont = motorState;

mouse = struct;
mouse.D1 = [];
mouse.D2 = [];

%% Looping
numCondits = 30;
cellTrackingMat = a;
destMat = cell(size(cellTrackingMat));
for col = 1:numCondits
    if isempty(cellTrackingMat{1,col})
        continue
    end
    load(cellTrackingMat{1,col});
    roiBase = data;   
    for row = 2:size(cellTrackingMat,1)
        if ~isempty(cellTrackingMat{row, col}) && cellTrackingMat{row, col} < 3000
            tempCondit = condit;
            cellType = floor(cellTrackingMat{row, col}/1000);
            cellNum = mod(cellTrackingMat{row, col},1000);
            switch cellType
                case 1
                    roiDF = data.dF1;
                case 2
                    roiDF = data.dF2;
            end
            tempCondit.dF{1} = roiDF.dF(cellNum,:);
            tempCondit.vel{1} = roiBase.vel;
            tempCondit.accel{1} = roiBase.accel;
            tempCondit.framerate{1} = roiBase.framerate;
            tempCondit.peakFreqRestMot{1} = roiDF.peakFreqRestMot(cellNum,:);
            tempCondit.peakHeights{1} = roiDF.peakHeights(cellNum);
            tempCondit.riseTimes{1} = roiDF.riseTimes(cellNum);
            tempCondit.decayTimes{1} = roiDF.decayTimes(cellNum);
            destMat{row,col} = tempCondit;
        end
    end
end