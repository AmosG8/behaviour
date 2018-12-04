


%% the user selects what files that were received from arduino to open 
%and place all summary data into an output structure called day_summary
day_summary={};
[file,path] = uigetfile('Select at least 2 Files', 'MultiSelect', 'on');
[m n]=size(file); %n is the number of files
prompt = 'What is the stage of the experiment? \n 1 for A (licking) \n 2 for B (s-r association)\n 3 for C (random presentation) \n 4 for D (delay) \n';
ex_stage = input(prompt)

for selected_file=1:n
    
    data=open (char( fullfile(path, file(1,selected_file))) );
    day_summary.filename(selected_file,1)=file(1,selected_file);
    
    %file(1,selected_file)
    %% test if the presentation was random 
    if ex_stage>2
        BeginningEvent = extractfield(data.ReceivedData,'trialBeginningEvent');
        Indexes_of_trialBeginningEvent=find(BeginningEvent);
        Texture = extractfield(data.ReceivedData,'thisTrialTexture');
        mean(Texture(Indexes_of_trialBeginningEvent))
    end
    %% total number of licks based on the lick timing column in the received data 
    licks = extractfield(data.ReceivedData,'lickEventCorrectTiming');
    total_Licks=length(find(licks));
%     total_Licks
%     selected_file
    day_summary.total_Licks(selected_file,1)=total_Licks;%easier to read
    day_summary.Percent_One_licks(selected_file,1)=(length(find(licks==1))/total_Licks) *100;
    %Percent_Two_licks=(length(find(t==2))/total) *100
    
    %% plots
    figure();
    Lick_One=[];
    time = extractfield(data.ReceivedData,'experimentElapsedTime');
    Lick_One(1,:)=time(find(licks==1)); %index for the message vector 
%licks are based on 'correct time' column
    Lick_One(2,:)=1;
    Lick_Two=[];
    Lick_Two(1,:)=time(find(licks==2));
    Lick_Two(2,:)=1.05;
    plot(Lick_One(1,:),Lick_One(2,:), 'K.', Lick_Two(1,:),Lick_Two(2,:), 'R.')
    ylim([0.5 1.5]);

    %% total time of the session in seconds 
    %t = extractfield(data.ReceivedData,'experimentElapsedTime');
    day_summary.time(selected_file,1)=max(time)/1000;
    
    %% stage 2 
    %% percent of licks at the right time
    %there were 2 bugs in Aruduino fixed (14-10-18) 
    %1. the bug caused the column of lick timing to be irrelevant.
    %that forces me to
    %calculate the lick timing based on the trial stage column
    %and the location based on the 'correct port' column
    %2. there were also Rr trials that practially were Sa
    
    if ex_stage==2
        
   SaOrITI = extractfield(data.ReceivedData,'trailStage');     
   Licks = extractfield(data.ReceivedData,'lickEventCorrectPort');
   SaOrITI(find(Licks==1));   %all the rows with licks inside 'trial stage'
   %%%  calculate correct timing by lick within Sa
   
  CorrectTiming= 
   
   
   
   
    day_summary.Percent_Time_hits(selected_file,1)=(length(find(Licks==1))/total_Licks) *100;
    end
    %% stage 2
    %% percent of licks at the right location
    %if ex_stage==1
    CorrectPort = extractfield(data.ReceivedData,'lickEventCorrectPort');
    day_summary.Percent_Location_hits(selected_file,1)=length(find(CorrectPort==1))/total_Licks *100;
    %end
    %% percent of licks at the right location and at the right time
    %if ex_stage>1
    %temp_coreect_Port = extractfield(data.ReceivedData,'lickEventCorrectPort');
    Indexes_of_Correct_Port=find(CorrectPort==1);
   % Temp_CorrectTiming= extractfield(data.ReceivedData,'lickEventCorrectTiming');
   
    ans=find(CorrectTiming(Indexes_of_Correct_Port)==1);
    day_summary.Percent_Location_nTime_hits(selected_file,1)=length(ans)/total_Licks *100
    %end
    
    %% percent of hit trials 
    
    % find indexes of trial beginings
    trialBeginningEventIndexes = extractfield(data.ReceivedData,'trialBeginningEvent');
        %I'm now slicing each single trial within correctport into a vector
        %(over-writting) called vector_of_single_trial_correctPort
        hit=0;miss=0;nogo=0;
    for number_of_trials=1:(length(trialBeginningEventIndexes)-1) 
        vector_of_single_trial_correctPort =...
            CorrectPort(trialBeginningEventIndexes(number_of_trials)):...
            CorrectPort(trialBeginningEventIndexes(number_of_trials+1));        
    % go along the vector of correct port between the trial beining events indexes
    % and if no item above 0 - missm else find the 1st>0 if it's 1 hit if it's 2 miss 
    %vector_of_single_trial_correctPort looks like [ 0 0 0 1 1 1 2 0 0 ]
        if any(vector_of_single_trial_correctPort)>0
            %it's a go trial
            counter=1;
            while counter < length(vector_of_single_trial_correctPort)
                if vector_of_single_trial_correctPort(counter)==1%hit
                    hit=hit+1;
                else %miss
                    miss=miss+1;
                end
            end
        else%no go trial
            nogo=nogo+1;
        end
    end%of for loop along each single trial
    % write the results into the summary table
    day_summary.Trialhits(selected_file,1)=hit/length(trialBeginningEventIndexes) *100;
    day_summary.Trialmiss(selected_file,1)=miss/length(trialBeginningEventIndexes) *100;
    day_summary.Trialnogo(selected_file,1)=nogo/length(trialBeginningEventIndexes) *100;
    day_summary.PercentTrialhits_ofGO(selected_file,1)=hit/(length(trialBeginningEventIndexes)-nogo) *100;
end
Table_day_summary = struct2table(day_summary);