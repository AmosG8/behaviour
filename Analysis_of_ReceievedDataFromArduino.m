
%% test if the presentation was random 
t = extractfield(ReceivedData,'trialBeginningEvent');
Indexes_of_trialBeginningEvent=find(t);
t = extractfield(ReceivedData,'thisTrialTexture');
mean(t(Indexes_of_trialBeginningEvent))

%% total number of licks
t = extractfield(ReceivedData,'lickEventCorrectTiming');
total=length(find(t))
Percent_One_licks=(length(find(t==1))/total) *100
Percent_Two_licks=(length(find(t==2))/total) *100
%% plots
Lick_One=[];
Lick_One(1,:)=find(t==1);
Lick_One(2,:)=1;
Lick_Two=[];
Lick_Two(1,:)=find(t==2);
Lick_Two(2,:)=1.05;
plot(Lick_One(1,:),Lick_One(2,:), 'K.', Lick_Two(1,:),Lick_Two(2,:), 'R.')
ylim([0.5 1.5]);

%% total time of the session in seconds 
t = extractfield(ReceivedData,'experimentElapsedTime');
time=max(t)/1000
%% percent of licks at the right time
t = extractfield(ReceivedData,'lickEventCorrectTiming');
Percent_Time_hits=(length(find(t==1))/total) *100

%% percent of licks at the right location
t = extractfield(ReceivedData,'lickEventCorrectPort');
Percent_Location_hits=length(find(t==1))/total *100

%% percent of licks at the right location and at the right time
temp_coreect_Port = extractfield(ReceivedData,'lickEventCorrectPort');
Indexes_of_Correct_Port=find(temp_coreect_Port==1);
Temp_CorrectTiming= extractfield(ReceivedData,'lickEventCorrectTiming');
ans=find(Temp_CorrectTiming(Indexes_of_Correct_Port)==1);
Percent_hits_location_time=length(ans)/total *100
