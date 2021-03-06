%% Arduino Matlab tutorial 3
%link: http://bit.ly/1nTiMDi

%% 1. Specifies the COM Port that the arduino is connected to
comPort = 'COM7';

%% 2. Initialize the Serial Port
if (~exist('serialFlag','var'))
    [s,flag] = setupSerial(comPort);
    out.s = s;
end

%% 3. Run a calibration routine

%calibrate the sensor if it is not calibrated
if (~exist('calCo','var'))
    calCo= calibrate(s);
     %Prepair for the readAcc input argument (it was designed to
    %take 's' as a variable of a struct 
end


%% 5.Initializing the Rolling Plot
 
buf_len = 100;
index = 1:buf_len;
% create variables for the X axis
gxdata = zeros(buf_len,1);
% create filter variable for the X axis
gxdataFilt = zeros(buf_len,1);
 
%% 6.Data Collection and Plotting
 
%initialize filter coefficient
taps = 3;

%initialize filter coefficient
thresholdValue =0.8;
stepCount = 0;
isHighFlag = 0;

%while the figure window is open
%%
while(1) %get(button, 'UserData'))
 
        %Get the new values from teh accelerometer
        [gx,gy,gz] =  readAcc(out,calCo); 
        
        %Update teh rolling plot. Apppend the new reading to the end of the
        %rolling plot data. Drop the first value
        gxdata = [gxdata(2:end); gx];
        
        %Filter the data and update the rolling plot
        gxdataFilt = [gxdataFilt(2:end);...
            mean(gxdata(buf_len : -1 : buf_len-taps +1))];
        % Threshold Case 1:Signal rose above the threshold value for the
        % 1st time
        if gx > thresholdValue && isHighFlag ==0
        stepCount = stepCount+1;
        isHighFlag =1;
        end    
        if gx < thresholdValue && isHighFlag ==1
        isHighFlag=0;
        end
        %subplot for raw X magnitude
            
        plot(index, gxdataFilt,'b',index,thresholdValue*ones(buf_len,1), 'r--');
        axis([1 buf_len -1.5 1.5]);
        str = sprintf('stepcount %d',stepCount);
        title(str);
        button = uicontrol('Style','text','String',str,...
                        'pos',[0 0 300 20]);
        xlabel('time');
        ylabel('Magnitude of X axis acceleration (filtered)');
        drawnow;
end

%%
clear all
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
close all
clc
disp('Serial Port Closed')
        
