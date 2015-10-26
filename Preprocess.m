function TrainData = Preprocess(DatasetName,TrialTime,FeatsPerChannel,TrainedChannels)
    data=load(strcat(DatasetName,'.mat'));
    EegMatrix=data.eeg';
 
    ChannelNo=length(TrainedChannels);
    
    TrainData=zeros(0,FeatsPerChannel*ChannelNo);
    Header={};
    %initialize header
    featureRange=1:FeatsPerChannel;
    for j=1:ChannelNo
        if not(j==1)
             %fix the range that the features occupy
             %eg for channel 4 with 2 feats, it is x(:,3*2+1:4*2)
             featureRange=((j-1)*FeatsPerChannel+1):j*FeatsPerChannel;
        end;
        Header{featureRange(1)}=strcat('meanCh',num2str(j));
        Header{featureRange(2)}=strcat('stdCh',num2str(j));
        Header{featureRange(3)}=strcat('maxCh',num2str(j));
        Header{featureRange(4)}=strcat('minCh',num2str(j));
        Header{featureRange(5)}=strcat('meanWelchPSDCh',num2str(j));
        Header{featureRange(6)}=strcat('powerCh',num2str(j));
        Header{featureRange(7)}=strcat('minFreqCh',num2str(j));
        Header{featureRange(8)}=strcat('maxFreqCh',num2str(j));
        Header{featureRange(9)}=strcat('stdFreqCh',num2str(j));
        Header{featureRange(10)}=strcat('meanDeltaCh',num2str(j));
    end;
    Header{featureRange(10)+1}='labels';
    SampFreq=128;
    
    TrialLength=TrialTime*SampFreq;

    %design bandpass filter and run it to each channel time series
    nyq=SampFreq/2;
    fLowNorm=4/nyq; % bandpass 4 to 40 Hz (theta, alpha, beta)
    fHighNorm=40/nyq;
    FilterOrder=5;
    [coef1 coef2]=butter(FilterOrder, [fLowNorm,fHighNorm],'bandpass');
    for i=1:size(EegMatrix,1)
        EegMatrix(i,:) = filter(coef1,coef2,EegMatrix(i,:));
    end;
    
    EegMatrix=fastica(EegMatrix);
    
    %if the components are less than the channels, fill with zeros to
    %ensure each dataset has the same size
    if size(EegMatrix,1)<ChannelNo
         EegMatrix(size(EegMatrix,1):ChannelNo,:)=0;
    end;
    
    for i=1:TrialLength:size(EegMatrix,2)
        if (size(EegMatrix,2)-i)<TrialLength
            break;
        end;
        ChannelMatrix=EegMatrix(:,i:i+TrialLength);
        
        row=zeros(1,FeatsPerChannel*ChannelNo); %one epoch==>one row to be classified
        featureRange=1:FeatsPerChannel;
        for j=1:ChannelNo
            if not(j==1)
                 featureRange=((j-1)*FeatsPerChannel+1):j*FeatsPerChannel;
            end;
            %the features extracted for each channel
            signal=ChannelMatrix(j,:);
            row(featureRange(1))=mean(signal);
            row(featureRange(2))=std(signal);
            row(featureRange(3))=max(signal);
            row(featureRange(4))=min(signal);
            row(featureRange(5))=mean(pwelch(signal));
            row(featureRange(6))=rms(signal)^2;
            row(featureRange(7))=abs(min(fft(signal)));
            row(featureRange(8))=abs(max(fft(signal)));
            row(featureRange(9))=abs(std(signal));
            row(featureRange(10))=mean(diff(signal));
        end;
        %append row to dataset
        TrainData=vertcat(TrainData,row);
    end; 
    TrainData(:,size(TrainData,2)+1)=data.labels';
    %csvwrite('train2.csv',dataset({TrainData,Header{:}}));
    export(dataset({TrainData,Header{:}}),'File',strcat(DatasetName,'.csv'))
    data.train=TrainData;
    save(strcat(DatasetName,'.mat'),'-struct','data');
end
