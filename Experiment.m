function EegMatrix = Experiment(ExperimentTime,TrialTime,DatasetName,TrainedChannels,Colors)
    %colors=randi([0 1],20,1);
    %Init variables

    %%%the experiment time is not strictly related to the trial time, e.g. 
    %%%ExperimentTime=35 and TrialTime=5, does not mean necessarily that there
    %%%will be seven trials, as there is overhead in the prossessing between the trials.
    
    colors=randi([0 1],20,1); %then subtrack with 0.5
    
%    some default values
    

    SampFreq=128; %sampling 
    rectime = 1;%buffer data size (in sec)
    TrainLabels=[];
    ChannelNo=length(TrainedChannels);
    %%
    % data structures, copied and pasted from epocmfile.m
    structs.InputSensorDescriptor_struct.members=struct('channelId', 'EE_InputChannels_enum', 'fExists', 'int32', 'pszLabel', 'cstring', 'xLoc', 'double', 'yLoc', 'double', 'zLoc', 'double');
    enuminfo.EE_DataChannels_enum=struct('ED_COUNTER',0,'ED_INTERPOLATED',1,'ED_RAW_CQ',2,'ED_AF3',3,'ED_F7',4,'ED_F3',5,'ED_FC5',6,'ED_T7',7,'ED_P7',8,'ED_O1',9,'ED_O2',10,'ED_P8',11,'ED_T8',12,'ED_FC6',13,'ED_F4',14,'ED_F8',15,'ED_AF4',16,'ED_GYROX',17,'ED_GYROY',18,'ED_TIMESTAMP',19,'ED_ES_TIMESTAMP',20,'ED_FUNC_ID',21,'ED_FUNC_VALUE',22,'ED_MARKER',23,'ED_SYNC_SIGNAL',24);
    enuminfo.EE_CognitivTrainingControl_enum=struct('COG_NONE',0,'COG_START',1,'COG_ACCEPT',2,'COG_REJECT',3,'COG_ERASE',4,'COG_RESET',5);
    enuminfo.EE_ExpressivAlgo_enum=struct('EXP_NEUTRAL',1,'EXP_BLINK',2,'EXP_WINK_LEFT',4,'EXP_WINK_RIGHT',8,'EXP_HORIEYE',16,'EXP_EYEBROW',32,'EXP_FURROW',64,'EXP_SMILE',128,'EXP_CLENCH',256,'EXP_LAUGH',512,'EXP_SMIRK_LEFT',1024,'EXP_SMIRK_RIGHT',2048);
    enuminfo.EE_ExpressivTrainingControl_enum=struct('EXP_NONE',0,'EXP_START',1,'EXP_ACCEPT',2,'EXP_REJECT',3,'EXP_ERASE',4,'EXP_RESET',5);
    enuminfo.EE_ExpressivThreshold_enum=struct('EXP_SENSITIVITY',0);
    enuminfo.EE_CognitivEvent_enum=struct('EE_CognitivNoEvent',0,'EE_CognitivTrainingStarted',1,'EE_CognitivTrainingSucceeded',2,'EE_CognitivTrainingFailed',3,'EE_CognitivTrainingCompleted',4,'EE_CognitivTrainingDataErased',5,'EE_CognitivTrainingRejected',6,'EE_CognitivTrainingReset',7,'EE_CognitivAutoSamplingNeutralCompleted',8,'EE_CognitivSignatureUpdated',9);
    enuminfo.EE_EmotivSuite_enum=struct('EE_EXPRESSIV',0,'EE_AFFECTIV',1,'EE_COGNITIV',2);
    enuminfo.EE_ExpressivEvent_enum=struct('EE_ExpressivNoEvent',0,'EE_ExpressivTrainingStarted',1,'EE_ExpressivTrainingSucceeded',2,'EE_ExpressivTrainingFailed',3,'EE_ExpressivTrainingCompleted',4,'EE_ExpressivTrainingDataErased',5,'EE_ExpressivTrainingRejected',6,'EE_ExpressivTrainingReset',7);
    enuminfo.EE_CognitivAction_enum=struct('COG_NEUTRAL',1,'COG_PUSH',2,'COG_PULL',4,'COG_LIFT',8,'COG_DROP',16,'COG_LEFT',32,'COG_RIGHT',64,'COG_ROTATE_LEFT',128,'COG_ROTATE_RIGHT',256,'COG_ROTATE_CLOCKWISE',512,'COG_ROTATE_COUNTER_CLOCKWISE',1024,'COG_ROTATE_FORWARDS',2048,'COG_ROTATE_REVERSE',4096,'COG_DISAPPEAR',8192);
    enuminfo.EE_InputChannels_enum=struct('EE_CHAN_CMS',0,'EE_CHAN_DRL',1,'EE_CHAN_FP1',2,'EE_CHAN_AF3',3,'EE_CHAN_F7',4,'EE_CHAN_F3',5,'EE_CHAN_FC5',6,'EE_CHAN_T7',7,'EE_CHAN_P7',8,'EE_CHAN_O1',9,'EE_CHAN_O2',10,'EE_CHAN_P8',11,'EE_CHAN_T8',12,'EE_CHAN_FC6',13,'EE_CHAN_F4',14,'EE_CHAN_F8',15,'EE_CHAN_AF4',16,'EE_CHAN_FP2',17);
    enuminfo.EE_ExpressivSignature_enum=struct('EXP_SIG_UNIVERSAL',0,'EXP_SIG_TRAINED',1);
    enuminfo.EE_Event_enum=struct('EE_UnknownEvent',0,'EE_EmulatorError',1,'EE_ReservedEvent',2,'EE_UserAdded',16,'EE_UserRemoved',32,'EE_EmoStateUpdated',64,'EE_ProfileEvent',128,'EE_CognitivEvent',256,'EE_ExpressivEvent',512,'EE_InternalStateChanged',1024,'EE_AllEvent',2032);

    DataChannels = enuminfo.EE_DataChannels_enum;
    DataChannelsNames = {'ED_COUNTER','ED_INTERPOLATED','ED_RAW_CQ','ED_AF3','ED_F7','ED_F3','ED_FC5','ED_T7','ED_P7','ED_O1','ED_O2','ED_P8','ED_T8','ED_FC6','ED_F4','ED_F8','ED_AF4','ED_GYROX','ED_GYROY','ED_TIMESTAMP','ED_ES_TIMESTAMP','ED_FUNC_ID','ED_FUNC_VALUE','ED_MARKER','ED_SYNC_SIGNAL'};
    lib_flag_popup = 1;
    plot_popup = 1;

    %%
    % Check to see if library was already loaded
    if ~libisloaded('edk')    
        [nf, w] = loadlibrary('edk','edk',  'addheader', 'EmoStateDLL', 'addheader', 'edkErrorCode'); 
        disp(['EDK library loaded']);
        if( lib_flag_popup )
            libfunctionsview('edk')
            nf % these should be empty if all went well
            w
        end
    else
        disp(['EDK library already loaded']);
    end

    %%
    %Connect with emoEngine (emotiv's epoc api)
    AllOK = calllib('edk','EE_EngineConnect','Emotiv Systems-5'); % success means this value is 0

    hData = calllib('edk','EE_DataCreate');
    calllib('edk','EE_DataSetBufferSizeInSec',rectime);
    eEvent = calllib('edk','EE_EmoEngineEventCreate');
    readytocollect = false;

    EegMatrix=zeros(0,length(TrainedChannels));

    %%
    %run the experiment
    index=1;
    Exper = tic; 
    while(toc(Exper) < ExperimentTime)
        %initialize trial values
        color=colors(index)-0.5;%randi([-0.5 0.5]);%-0.5 is black, 0.5 is white
        index=index+1;
        ShowImage(color);%show an image randomly (black or white)

        cnt=0;
        trial_matrix = zeros(TrialTime*SampFreq,length(TrainedChannels));

        Trial = tic; 
        while(toc(Trial) < TrialTime)
            %check if you can collect efficiently
            state = calllib('edk','EE_EngineGetNextEvent',eEvent); % state = 0 if everything's OK
            eventType = calllib('edk','EE_EmoEngineEventGetType',eEvent);
            userID=libpointer('uint32Ptr',0);
            calllib('edk','EE_EmoEngineEventGetUserId',eEvent, userID);
            if strcmp(eventType,'EE_UserAdded') == true
                userID_value = get(userID,'value');
                calllib('edk','EE_DataAcquisitionEnable',userID_value,true);
                readytocollect = true;
            end

            %collect the data from dongle
            if (readytocollect) 
                calllib('edk','EE_DataUpdateHandle', 0, hData);
                nSamples = libpointer('uint32Ptr',0);
                calllib('edk','EE_DataGetNumberOfSample',hData,nSamples);
                nSamplesTaken = get(nSamples,'value') ;

                if (nSamplesTaken ~= 0)
                    data = libpointer('doublePtr',zeros(1,nSamplesTaken));
                         %take the specified channels used for training
                        for i = 1:ChannelNo
                            calllib('edk','EE_DataGet',hData, DataChannels.([DataChannelsNames{i}]), data, uint32(nSamplesTaken));
                            data_value = get(data,'value');                                    
                            trial_matrix(cnt+1:cnt+length(data_value),i) = data_value;                    
                        end	                
                        %nS(cnt+1) = nSamplesTaken;
                        cnt = cnt + length(data_value);
                end
            end
        end
        TrainLabels=[TrainLabels,color];
        EegMatrix=vertcat(trial_matrix,EegMatrix);
        close(gcf) %close the image
    end
    
    data=matfile(strcat(DatasetName,'.mat'),'Writable',true);
    data.eeg=EegMatrix;
    data.labels=TrainLabels;
end