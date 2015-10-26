
ExperimentTime=100; %over one minute
TrialTime = 5;%time of the trial
DatasetName='test';
TrainedChannels=4:17;%the channels used for training
Colors=randi([0 1],20,1);
EegMatrix = Experiment(ExperimentTime,TrialTime,DatasetName,TrainedChannels,Colors)
FeatsPerChannel=10;
TrainData = Preprocess(DatasetName,TrialTime,FeatsPerChannel,TrainedChannels)
ModelName='test';
lambda = 0.1;
sigma=1;
model = TrainLDA(DatasetName,ModelName,lambda,sigma)
BCI(ModelName,TrialTime,TrainedChannels,FeatsPerChannel)

