-----------------------------------Color Identification Brain Computer Interface--------------------------------------
An experiment to classify whether a subject sees a black or a white image, given his brain activity on Emotiv Epoc+ BCI.

Experiment.m
1.	Connect to emotiv epoc+ thourgh EmoEngine. 
2.	Initialize raw eeg matrix with size=0 X No.Channel and labels vector with size=0 X 1.
3.	Run trials until the experiment time runs out. 
4.	For each trial, choose color at random and show respective picture.
5.	Record eeg activity to matrix with size=TrialTime*SampleFrequency X No. Channel .
6.	Append the matrix to the raw eeg matrix.
7.	Add to the label vector the color from 4.
8.	Close the picture opened in 3.
9.	Proceed to next trial (step 3).
10.	Save the raw eeg and labels.

Preprocess.m
1.	Load the raw eeg dataset from the experiment.
2.	Break the dataset into epochs (subsets corresponding to the experiment trials).
3.	Signal processing (filter,ICA etc..) on each epoch.
4.	Extract statistical properties of the processed epochs to derive a vector of features.
5.	Build a dataset from these vectors and save it (it must have the same row size as the length of the label vector from the same experiment).

Train.m
1.	Create novel or define existing machine learning algorithms.
2.	Load the preprocessed dataset and the labels.
3.	Train the algorithm on this dataset.
4.	Save the model parameters.
5.	(Optional) Run K fold cross validation to estimate error.

BCI.m
1.	Connect to emotiv epoc+ through EmoEngine.
2.	Load the model parameters from train segment.
3.	Start a recording for time equal to the trial time of the experiment.
4.	Choose a random color and show respective picture.
5.	Record eeg activity to matrix with size=TrialTime*SampleFrequency X No. Channel.
6.	Run signal processing and feature extraction to derive the vector of features.
7.	Classify that vector using the model from 2.
8.	Show the classification outcome with a pretty message.

**Libraries to connect with Epoc+ are not included.