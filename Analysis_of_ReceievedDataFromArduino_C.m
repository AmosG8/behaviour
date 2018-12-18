%% the user selects files that were received from arduino to open 
%and place all summary data into an output structure called day_summary
clear all;

day_summary={};
[file,path] = uigetfile('Select at least 2 Files', 'MultiSelect', 'on');
[m n]=size(file); %n is the number of files choosen
%inspect files that are up to:

 Flag_short_ex=0;
 ContinueFlag_ExTimeLength=0; 
prompt = 'show plot? 1 for yes \n 5 for only if shorter than 12min \n 0 for no \n';
show_plot= input(prompt) 
skipped=0; ex_stage=0;
%% define parameters
%possibly define here the dates for changing stage for each mouse
minExTime=6.5;%6.5;%in minutes

for selected_file=1:n
    time=[0]; Licks=[0]; total_Licks=0;
    Flag_short_ex=0;
    PlotContinue=1;
    data=open (char( fullfile(path, file(1,selected_file))) );
    
 %% check if the current file is a valid file (aka begins with 'Received_' 'digit digit digit')
 if length(file{1,selected_file})>7
     if sum(file{1,selected_file}(1:8)=='Received')==8 && ...
         sum(isstrprop(file{1,selected_file}(10:12),'digit'))==3
         ContinueFlag_ValidFile=1;
     else
         ContinueFlag_ValidFile=0;
         skipped=skipped+1;%to mach with indexing of the selected file
     end
 else
         ContinueFlag_ValidFile=0;
         skipped=skipped+1;%to mach with indexing of the selected file
 end
 %% skip a file if experiment time < = minExTime. go to the next file and don't write anything 
 % total time of the session in mili-seconds
if ContinueFlag_ValidFile 
    time = extractfield(data.ReceivedData,'experimentElapsedTime');        
    if double(max(time))/1000 > minExTime*60 %max(time)/1000 = length of the experiment in seconds
        ContinueFlag_ExTimeLength=1;
        day_summary.ExLength_min(selected_file-skipped,1)=double(max(time))/60000;
        day_summary.filename(selected_file-skipped,1)=file(1,selected_file);
        file(1,selected_file)
        if  show_plot==5 && double(max(time)/1000) <(12*60) 
              Flag_short_ex=1;%will become relevant only for plots
                          %else day_summary.suspecious(selected_file-skipped,1)=0;                          
        end
    else
         skipped=skipped+1;
         ContinueFlag_ExTimeLength=0;
    end
end        
    %%    determine the experiment stage
   if ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile
       Temp=file{1,selected_file}(end-21:end);
       ExDayMatFormat=strcat(Temp(1:2),'-',Temp(3:5),'-',Temp(6:9));
       ExDayMatFormat=datetime(ExDayMatFormat);
       switch file{1,selected_file}(10:12)
           case '170'             
               if(datetime('09-Oct-2018')-ExDayMatFormat)>0%this won't include 09-Oct-2018 and following dates
                   ex_stage=1; %could use:  isbetween(A,tlower,tupper)
               elseif(datetime('01-Nov-2018')-ExDayMatFormat)>0%this won't include 01-Nov-2018 and the following
                   ex_stage=2;
               else 
                   ex_stage=3;
               end
               day_summary.ExStage(selected_file-skipped,1)=ex_stage;
           case '905'
               if(datetime('09-Oct-2018')-ExDayMatFormat)>0
                   ex_stage=1;
               else
                   ex_stage=2;
               end
               day_summary.ExStage(selected_file-skipped,1)=ex_stage;
           case '660'
               if(datetime('11-Oct-2018')-ExDayMatFormat)>0
                   ex_stage=1;
               else
                   ex_stage=2;
               end
               day_summary.ExStage(selected_file-skipped,1)=ex_stage;
           case '612'
               if(datetime('23-Oct-2018')-ExDayMatFormat)>0
                   ex_stage=1;
               else
                   ex_stage=2;
               end
               day_summary.ExStage(selected_file-skipped,1)=ex_stage;
           case '614'
               if(datetime('14-Nov-2018')-ExDayMatFormat)>0
                   ex_stage=1;
               else
                   ex_stage=2;
               end
              day_summary.ExStage(selected_file-skipped,1)=ex_stage;
           otherwise
             disp('Unknown mouse name')
             ContinueFlag_ValidFile=0;
             skipped=skipped+1;
             day_summary.ExLength_min=day_summary.ExLength_min(1:selected_file-skipped,1);
             day_summary.filename=day_summary.filename(1:selected_file-skipped,1);
       end
   end
    %% test if the presentation was random. Relevant for training-stages 3,4,5
    if ex_stage>2 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile
        BeginningEvent = extractfield(data.ReceivedData,'trialBeginningEvent');
        Indexes_of_trialBeginningEvent=find(BeginningEvent);
        Texture = extractfield(data.ReceivedData,'thisTrialTexture');
        %day_summary.MeanTexture(selected_file-skipped,1)=mean(Texture(Indexes_of_trialBeginningEvent));
    end
    %% total number of licks based on the correct port column in the received data 
    if ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile
        if ex_stage==1  %in stage 1 there is nothing in correct port column 
            %   in stage 2 there was a bug in correct timing column
            Licks = extractfield(data.ReceivedData,'lickEventCorrectTiming');
            total_Licks=length(find(Licks));
            day_summary.Percent_One_licks(selected_file-skipped,1)=(length(find(Licks==1))/total_Licks) *100;
        elseif ex_stage>1
            Licks = extractfield(data.ReceivedData,'lickEventCorrectPort');
            total_Licks=length(find(Licks));
            %now calculate percent licks at port number #1
            Texture = extractfield(data.ReceivedData,'thisTrialTexture');
            day_summary.Percent_One_licks(selected_file-skipped,1)=...
                length(find( (Licks==1 & Texture==1) | (Licks==2 & Texture==2) ))...% number of licks at port 1
                /total_Licks*100;
        end
        day_summary.total_Licks(selected_file-skipped,1)= total_Licks;    
        day_summary.licksPerSec(selected_file-skipped,1) = total_Licks/(double( max(time)/1000) ); 
    end
    %% plots  and allow the user to skip or mark the current file based on it's plot 
    if ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && ( show_plot==1 || Flag_short_ex )
        figure(1);
        Lick_One=[];
        Lick_Two=[];
        %LickAtOne=[];LickAtTwo=[];
        
        %prepare the data
        if ex_stage==1  %in stage 1 there is nothing in correct port column 
            Licks = extractfield(data.ReceivedData,'lickEventCorrectTiming');
        %   in stage 2 there was a bug in correct timing column
        %correct port doesn't say the identity
        %correct p  ort is 1 for correct 2 for not correct 0 for not a lick
        elseif (ex_stage==2 || ex_stage==3)
            Licks = extractfield(data.ReceivedData,'lickEventCorrectPort');
            Texture = extractfield(data.ReceivedData,'thisTrialTexture');
        end

        if ex_stage==1 
            Lick_One(1,:)=double(time(find(Licks==1))); %index for the message vector
            Lick_One(1,:)=Lick_One(1,:)/(1000*60);   
            %licks are based on 'correct time' columnX
            Lick_One(2,:)=1;
            Lick_Two(1,:)=double(time(find(Licks==2)));
            Lick_Two(1,:)=Lick_Two(1,:)/(1000*60);
            Lick_Two(2,:)=1.05;
        elseif (ex_stage==2 || ex_stage==3)
            Lick_One = find( ((Licks==1) & (Texture==1)) | ((Licks==2) & (Texture==2)) );
            Lick_Two = find( ((Licks==1) & (Texture==2)) | ((Licks==2) & (Texture==1)) );
            %time = extractfield(data.ReceivedData,'experimentElapsedTime');
            Lick_One(1,:)=double( time(Lick_One) );
            Lick_One(1,:)=Lick_One(1,:)/(60*1000);
            Lick_One(2,:)=1;
            Lick_Two(1,:)=double( time(Lick_Two) );
            Lick_Two(1,:)=Lick_Two(1,:)/(60*1000);
            Lick_Two(2,:)=1.05;
        end
        plot(Lick_One(1,:),Lick_One(2,:), 'K.', Lick_Two(1,:),Lick_Two(2,:), 'R.')
        ylim([0.5 1.5]);
        title(file{1,selected_file}(10:end-4),'FontWeight','normal','FontName','FixedWidth' );
    % allow the user to skip the current file based on it's plot 
        prompt = 'For continuing with this file press 1 \n for suspecious flag press 5 \n to skip this file press 0 \n ';
        PlotContinue= input(prompt)
        if PlotContinue==0
            skipped=skipped+1;
            day_summary.suspecious=day_summary.suspecious(1:selected_file-skipped,1);
            day_summary.filename= day_summary.filename(1:selected_file-skipped,1);
            day_summary.ExLength_min=day_summary.ExLength_min(1:selected_file-skipped,1);
            day_summary.ExStage=day_summary.ExStage(1:selected_file-skipped,1);
            day_summary.Percent_One_licks=day_summary.Percent_One_licks(1:selected_file-skipped,1);
            day_summary.total_Licks=day_summary.total_Licks(1:selected_file-skipped,1);           
            day_summary.licksPerSec=day_summary.licksPerSec(1:selected_file-skipped,1);
            
         elseif PlotContinue==5
            day_summary.suspecious(selected_file-skipped,1)=1;
          else 
            day_summary.suspecious(selected_file-skipped,1)=0;
        end
        close(figure(1));
    elseif (ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && (show_plot==0 || Flag_short_ex==0))
        %if this file is included and I didn't inspect its plot
        day_summary.suspecious(selected_file-skipped,1)=0;
    end
    

    %% percent of licks at the right time stages 2 3 4
    if ex_stage==1 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
         %day_summary.total_Licks(selected_file-skipped,1)=total_Licks;
         day_summary.Percent_Time_Licks(selected_file-skipped,1)=NaN;
          day_summary.Total_Time_Licks(selected_file-skipped,1)=NaN;
    elseif ex_stage==2 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0      
    %there were 2 bugs in Aruduino fixed (14-10-18) 
    %1. the bug caused the column of lick timing to be irrelevant.
    %that forced me to:
    %extract if the lick was at the corrct timing by the trial-stage column
    %and to extract the location based on the 'correct port' column
    %2. there were also Rr trials that practially were Sa
        SaOrITI = extractfield(data.ReceivedData,'trailStage');
        %I'm now changing Sa and Rr to 1 and It to 0
        for index=1:length(SaOrITI)  
            if strfind(SaOrITI{index},'It')
                SaOrITI{index}=0;
            end
            if strfind(SaOrITI{index},'Rr')
                SaOrITI{index}=1;
            end
            if strfind(SaOrITI{index},'Sa')
                SaOrITI{index}=1;
            end
            if strfind(SaOrITI{index},'Ur')
                SaOrITI{index}=-5;
            end
        end
        SaOrITI = cell2mat(SaOrITI);
        IndexesSa=find(SaOrITI==1);
        IndexITI=find(SaOrITI==0);

        %now find licks that were at Sa/Rr => Licks_on_time
        %other licks are Licks_NOT_on_time
        Licks = extractfield(data.ReceivedData,'lickEventCorrectPort');
        Total_correct_Time_Licks=sum((Licks(IndexesSa))>0);% Licks(IndexesSa)) contains 0 1 2 
        Total_ITI_Licks=sum((Licks(IndexITI))==0);
        total_Licks=length(find(Licks));%this appears already above but is more readable that way
        day_summary.Total_Time_Licks(selected_file-skipped,1)=Total_correct_Time_Licks;
        day_summary.Percent_Time_Licks(selected_file-skipped,1)=double(Total_correct_Time_Licks/total_Licks) *100;
        day_summary.total_Licks(selected_file-skipped,1)=total_Licks;%sum((Licks(:))>0);
       
    elseif ex_stage==3 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
     AllLicks = extractfield(data.ReceivedData,'lickEventCorrectTiming');
     CorrectLicks=length(find(AllLicks==1));
     total_Licks=length(find(AllLicks>0));
     day_summary.Total_Time_Licks(selected_file-skipped,1)=CorrectLicks;
     day_summary.Percent_Time_Licks(selected_file-skipped,1)=double(CorrectLicks/total_Licks)*100;
    end
    
    %% percent of licks at the right location stage 2 3 4
    if ex_stage==1 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
        day_summary.Percent_CorrectLocation_Licks(selected_file-skipped,1)=NaN;
        day_summary.Total_CorrectLocation_Licks(selected_file-skipped,1)=NaN;
    elseif ex_stage>1 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
        CorrectPort = extractfield(data.ReceivedData,'lickEventCorrectPort');%1 correct 2 incorrect 0 no lick
        day_summary.Total_CorrectLocation_Licks(selected_file-skipped,1)=length(find(CorrectPort==1));
        day_summary.Percent_CorrectLocation_Licks(selected_file-skipped,1)=(length(find(CorrectPort==1))/total_Licks) *100;
    end
    %% percent of licks at the right location and at the right time
    if  ex_stage==1 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
        day_summary.Total_correct_time_N_port(selected_file-skipped,1)=NaN;
        day_summary.Percent_correct_location_time(selected_file-skipped,1)=NaN;        
    elseif ex_stage==2 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
        Indexes_of_Correct_Port_and_Time=find(CorrectPort(IndexesSa)==1);
        day_summary.Total_correct_time_N_port(selected_file-skipped,1)=...
            length(Indexes_of_Correct_Port_and_Time);        
        day_summary.Percent_correct_location_time(selected_file-skipped,1)=...
            length(Indexes_of_Correct_Port_and_Time)/total_Licks*100;%sum((Licks(:))>0) *100;
    elseif ex_stage==3 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0   
        CorrectTimeIndexes= find(extractfield(data.ReceivedData,'lickEventCorrectTiming')==1);
        CorrectPortVector=extractfield(data.ReceivedData,'lickEventCorrectPort');
        TimeLocationHits=find( CorrectPortVector(CorrectTimeIndexes)==1);
        day_summary.Total_correct_time_N_port(selected_file-skipped,1)=...
            length(TimeLocationHits);
         day_summary.Percent_correct_location_time(selected_file-skipped,1)=...
             double(length(TimeLocationHits)/total_Licks)*100;
    end
    
    
    
    %% A single trial analysis (hit miss no-go-on-time or no-go-at-all)
    if ex_stage==1 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0 
        day_summary.TrialhitsPERC(selected_file-skipped,1)=NaN;
        day_summary.TrialmissPERC(selected_file-skipped,1)=NaN;
        day_summary.Trial_nogoOnTimePERC(selected_file-skipped,1)=NaN;
        day_summary.Trial_nogoAtAllPERC(selected_file-skipped,1)=NaN;      
        day_summary.Trialhits_ofGO_PERC(selected_file-skipped,1)=NaN;     
        day_summary.TrialhitsTotal(selected_file-skipped,1)=NaN;
        day_summary.TrialmissTotal(selected_file-skipped,1)=NaN;
        day_summary.Trial_nogoOnTimeTotal(selected_file-skipped,1)=NaN;
        day_summary.Trial_nogoAtAllTotal(selected_file-skipped,1)=NaN; 
        day_summary.NumTrials(selected_file-skipped,1)=NaN;
    elseif (ex_stage==2||ex_stage==3) && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
        % find indexes of trial beginings
        trialBeginningEventIndexes = find(extractfield(data.ReceivedData,'trialBeginningEvent')>0);
        day_summary.NumTrials(selected_file-skipped,1)=length(trialBeginningEventIndexes);
        trailStage = extractfield(data.ReceivedData,'trailStage');
            %I'm now slicing each single trial within correctport into a vector
            %(over-writting) called vector_of_single_trial_correctPort
        hit=0;miss=0;nogoAtAll=0;nogoOnTime=0;
        
        for number_of_trials=1:(length(trialBeginningEventIndexes)-1)
    %       first=trialBeginningEventIndexes(number_of_trials);
    %       second=trialBeginningEventIndexes(number_of_trials+1);
            vector_of_single_trial_correctPort = CorrectPort(trialBeginningEventIndexes(number_of_trials):trialBeginningEventIndexes(number_of_trials+1));

        % go along the vector of correct port between the trial beining events indexes
        % and if there's no item above 0 it's miss, else find the 1st>0 if it's 1 it's hit if it's 2 it's miss 
        %vector_of_single_trial_correctPort looks like [ 0 0 0 1 1 1 2 0 0 ]
            if any(vector_of_single_trial_correctPort)>0
                %there was a lick in the trial
                %test if the lick was inside Sa (stage 2) or Rr (stage 3)
                counter=1;%goes along the items of a trial within vector_of_single_trial_correctPortt
                flagGo=0;
                while counter < length(vector_of_single_trial_correctPort)
                    if ex_stage==2
                        if (vector_of_single_trial_correctPort(counter)==1 & strfind(trailStage{counter},'Sa'))%hit 
                            hit=hit+1;
                            flagGo=1;
                            counter=length(vector_of_single_trial_correctPort);%decided, so break for this trial, continue to decide on the next trial
                        elseif (vector_of_single_trial_correctPort(counter)==2 & strfind(trailStage{counter},'Sa')) %miss
                            miss=miss+1;
                            flagGo=1;
                            counter=length(vector_of_single_trial_correctPort);%decided, so break for this trial, continue to decide on the next trial
                        end%if there was a lick in Sa it was either hit or miss and in anycase go on time
                        counter=counter+1;%would continue as long as encountering 0s
                    elseif ex_stage==3  
%         the analysis for stage 2 doesn't fit b/e it uses the first lick
%         after begining a trial instead of first in response time.
%I only need to add a condition of trial stage == Rr
                        if (vector_of_single_trial_correctPort(counter)==1 & strfind(trailStage{counter},'Rr')) % hit 
                            hit=hit+1;
                            flagGo=1;
                            counter=length(vector_of_single_trial_correctPort);%break for this trial, continue to decide on the next trial
                        elseif (vector_of_single_trial_correctPort(counter)==2  & strfind(trailStage{counter},'Rr')) %miss
                            miss=miss+1;
                            flagGo=1;
                            counter=length(vector_of_single_trial_correctPort);% break for this trial, continue to decide on the next trial
                        end
                        counter=counter+1;%would continue as long as encountering 0s                      
                    end %ex_stage ==2 or 3               
                end %of while going along a trial with a lick somewhere inside
                if flagGo==0 %I reach here when finishing going along a single trial with a lick inside
                  nogoOnTime=nogoOnTime+1;
                end
            else% I reach here when there was no lick all along the trial. it's no go trial
                nogoAtAll=nogoAtAll+1;
            end
        end%of for loop along all single trials
        % write the results into the summary table
        day_summary.TrialhitsPERC(selected_file-skipped,1)=double(hit/length(trialBeginningEventIndexes)) *100;
        day_summary.TrialmissPERC(selected_file-skipped,1)=double(miss/length(trialBeginningEventIndexes)) *100;
        day_summary.Trial_nogoOnTimePERC(selected_file-skipped,1)=double(nogoOnTime/length(trialBeginningEventIndexes)) *100;
        day_summary.Trial_nogoAtAllPERC(selected_file-skipped,1)=double(nogoAtAll/length(trialBeginningEventIndexes)) *100;       
        day_summary.Trialhits_ofGO_PERC(selected_file-skipped,1)=double(hit/(hit+miss)) *100;
        
        day_summary.TrialhitsTotal(selected_file-skipped,1)=hit;
        day_summary.TrialmissTotal(selected_file-skipped,1)=miss;
        day_summary.Trial_nogoOnTimeTotal(selected_file-skipped,1)=nogoOnTime;
        day_summary.Trial_nogoAtAllTotal(selected_file-skipped,1)=nogoAtAll;       
        
%     alternatively -- elseif ex_stage==3 && ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
% 
% %         i'll use the column of 'first in response time' but need to include
% %         only '1's that were indeed in response time b/e first Pu also
% %         gives 1 in the column of 'first in response time'.
% %         then, I have the indexes of first lick in response time and need
% %         to test within 'corrctPort' column if it's hit ot miss trial
%           hit=0;miss=0;nogo=0;
%           FirstInResponseTime=extractfield(data.ReceivedData,'lickEventIsFirstInResponseTime');
      
    end
    %% extract the mouse name  
    if ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
     day_summary.MouseName{selected_file-skipped,1} = file{1,selected_file}(10:12);
    end
    %% extract the date of when the experiemnt run
    if ContinueFlag_ExTimeLength==1 && ContinueFlag_ValidFile && PlotContinue>0
       Temp=file{1,selected_file}(end-21:end);
       ExDayMatFormat=datetime(strcat(Temp(1:2),'-',Temp(3:5),'-',Temp(6:9)));
       day_summary.ExDate(selected_file-skipped,1) = ExDayMatFormat;%string(ExDayMatFormat); AG { -( 18/12/18
       %% merge current row with former row of the same mouse at the same day 
       rows_counter=1;
       while rows_counter<(selected_file-skipped)
             % i'm going to chek the date and then to check name
           if ((day_summary.ExDate(rows_counter,1)==ExDayMatFormat )& strcmp( ...
                   day_summary.MouseName{selected_file-skipped,1},...
                   day_summary.MouseName{rows_counter,1}))
               
               % if yes combine the data into 1 row
               
               day_summary.ExLength_min(rows_counter,1)=...
                   day_summary.ExLength_min(rows_counter,1)+...
                   day_summary.ExLength_min((selected_file-skipped),1);
               
               
               NewName=strcat('M_',day_summary.filename(rows_counter,1));
               day_summary.filename(rows_counter,1)=NewName;
               day_summary.Percent_One_licks((selected_file-skipped))= [];
               
               day_summary.total_Licks(rows_counter,1)=...
                   day_summary.total_Licks(rows_counter,1)+...
                   day_summary.total_Licks((selected_file-skipped),1);
               
               
               day_summary.licksPerSec(rows_counter,1)=...
                   double( day_summary.total_Licks(rows_counter,1)/...
                   ( day_summary.ExLength_min(rows_counter,1)*60 )) ;             
                  
               day_summary.Total_correct_time_N_port(rows_counter,1)=...
                   day_summary.Total_correct_time_N_port(rows_counter,1)+...
                   day_summary.Total_correct_time_N_port((selected_file-skipped),1);

               day_summary.Percent_correct_location_time(rows_counter,1)=...
                   double(day_summary.Total_correct_time_N_port(rows_counter,1)/...
                   day_summary.total_Licks(rows_counter,1) *100);
               day_summary.Percent_correct_location_time((selected_file-skipped))=[];
               
              day_summary.Total_CorrectLocation_Licks(rows_counter,1)= ...
              day_summary.Total_CorrectLocation_Licks(rows_counter,1)+...
                  day_summary.Total_CorrectLocation_Licks(selected_file-skipped,1);
             

              day_summary.Total_Time_Licks(rows_counter,1)=...
              day_summary.Total_Time_Licks(selected_file-skipped,1)+...
              day_summary.Total_Time_Licks(rows_counter,1);

              day_summary.Percent_CorrectLocation_Licks(rows_counter,1)=...
                  double(day_summary.Total_CorrectLocation_Licks(rows_counter,1)/...
                  day_summary.total_Licks(rows_counter,1))*100; 
      
               day_summary.Percent_Time_Licks(rows_counter,1)=...
                   double(day_summary.Total_Time_Licks(rows_counter,1)/...
                   day_summary.total_Licks(rows_counter,1))*100;               
               
               day_summary.TrialhitsTotal(rows_counter,1)=...
                   day_summary.TrialhitsTotal(rows_counter,1)+...
                   day_summary.TrialhitsTotal((selected_file-skipped),1); 
              
                         
               day_summary.TrialmissTotal(rows_counter,1)=...
                   day_summary.TrialmissTotal(rows_counter,1)+...
                   day_summary.TrialmissTotal((selected_file-skipped),1);

               day_summary.Trial_nogoOnTimeTotal(rows_counter,1)=...
                   day_summary.Trial_nogoOnTimeTotal(rows_counter,1)+...
                   day_summary.Trial_nogoOnTimeTotal((selected_file-skipped),1); 
               
               day_summary.Trial_nogoAtAllTotal(rows_counter,1)=...
                   day_summary.Trial_nogoAtAllTotal(rows_counter,1)+...
               day_summary.Trial_nogoAtAllTotal((selected_file-skipped),1);              
                
               day_summary.NumTrials(rows_counter,1)=...
                   day_summary.NumTrials(rows_counter,1)+...
                   day_summary.NumTrials((selected_file-skipped),1);
        
               day_summary.TrialhitsPERC(rows_counter,1)=100*double(day_summary.TrialhitsTotal(rows_counter,1)/day_summary.NumTrials(rows_counter,1));

                
               day_summary.TrialmissPERC(rows_counter,1)= 100*double(day_summary.TrialmissTotal(rows_counter,1)/day_summary.NumTrials(rows_counter,1));

               
               day_summary.Trial_nogoOnTimePERC(rows_counter,1)=...
                   100*double(day_summary.Trial_nogoOnTimeTotal(rows_counter,1)/...
                    day_summary.NumTrials(rows_counter,1));
                
                
               day_summary.Trial_nogoAtAllPERC(rows_counter,1)=100*double(...
                   day_summary.Trial_nogoAtAllTotal(rows_counter,1)/...
                    day_summary.NumTrials(rows_counter,1) );           

                
                day_summary.Trialhits_ofGO_PERC(rows_counter,1)=...
                   100*day_summary.TrialhitsTotal(rows_counter,1)/...
                   double ( day_summary.TrialhitsTotal(rows_counter,1)+day_summary.TrialmissTotal(rows_counter,1) );
  
                day_summary.Trial_nogoAtAllPERC((selected_file-skipped))=[];
               day_summary.Trialhits_ofGO_PERC((selected_file-skipped))=[];   
                day_summary.Percent_Time_Licks((selected_file-skipped))=[];
               day_summary.Percent_CorrectLocation_Licks((selected_file-skipped))=[];
                day_summary.Total_Time_Licks((selected_file-skipped))=[];
              day_summary.ExLength_min((selected_file-skipped))=[];    
            day_summary.Total_CorrectLocation_Licks((selected_file-skipped))=[];             
               day_summary.ExStage(selected_file-skipped)=[];
               day_summary.suspecious(selected_file-skipped)=[];
               day_summary.filename(selected_file-skipped)=[];
               day_summary.MouseName(selected_file-skipped)=[];
               day_summary.ExDate(selected_file-skipped)=[];
               day_summary.Total_correct_time_N_port((selected_file-skipped))=[];
              day_summary.licksPerSec((selected_file-skipped))=[];
               day_summary.total_Licks((selected_file-skipped))=[];
               day_summary.NumTrials((selected_file-skipped))=[];
               day_summary.Trial_nogoAtAllTotal((selected_file-skipped))=[];        
               day_summary.Trial_nogoOnTimeTotal((selected_file-skipped))=[];
               day_summary.TrialmissTotal((selected_file-skipped))=[];
                 day_summary.TrialhitsTotal((selected_file-skipped))=[]; 
                day_summary.TrialhitsPERC((selected_file-skipped))=[];  
                day_summary.TrialmissPERC((selected_file-skipped))=[]; 
               day_summary.Trial_nogoOnTimePERC((selected_file-skipped))=[];
               
               
               skipped=skipped+1;%to overwrite the current empty row, 
               rows_counter=(selected_file-skipped); %so don't continue to check
           else
               rows_counter=rows_counter+1;
               %needed to empty in case there won't be data to overwrite
               
               %             fields = fieldnames(day_summary);
               %             for field=1:length(fields)
               %              day_summary(:).(fields{field,1}){rows_counter,1}==ExDayMatFormat
        
               
           end
      end
         
   end
      
end %next file

%% mid-output

Table_day_summary = struct2table(day_summary);
save('Table_day_summary','Table_day_summary');
save('Struct_day_summary','day_summary');

%% create the dataset
% create a structure 'mice' 
%with 2 fields: mouse name, results which is a structure 
mice_names={'660','905','170','612','614'};
for mouse_num=1:length(mice_names)
    mice(mouse_num).name=string(mice_names(mouse_num));
    %mice(mouse_num).results=struct;

end

%% extract single mouse data from the table "Table_day_summary"
%load Table_day_summary;
Table_day_summary.StringMouseName = string(Table_day_summary.MouseName);
Table_day_summary.StringExDate = string(Table_day_summary.ExDate);

%rows = Table_day_summary.StringMouseName == "660";
for mouse_num=1:length(mice_names)
    rows = Table_day_summary.StringMouseName == mice_names(mouse_num);
    %rows gets all the rows in the table in which the field StringMouseName
    %equal to the string mouse name indicated by mice_names(mouse_num)
%     mice(mouse_num).results=flipud(Table_day_summary(rows, :));%flip the table up side down
    TbyMouse=Table_day_summary(rows, :);
    %now I'm doing the same for ex.stage and fliping the tables up side down
    %I'll get for each mouse an output table for each stage
    rows = TbyMouse.ExStage == 1;
    mice(mouse_num).resultsStone= TbyMouse(rows, :); 
    mice(mouse_num).resultsStone=sortrows(mice(mouse_num).resultsStone, 'ExDate' );
    
   % mice(mouse_num).resultsStone=flipud(TbyMouse(rows, :));
    
    rows = TbyMouse.ExStage == 2;
    mice(mouse_num).resultsStageTwo=TbyMouse(rows, :); 
    mice(mouse_num).resultsStageTwo=sortrows(mice(mouse_num).resultsStageTwo, 'ExDate' );
    
    rows = TbyMouse.ExStage == 3;
    mice(mouse_num).resultsStageThree=TbyMouse(rows, :); 
    mice(mouse_num).resultsStageThree=sortrows(mice(mouse_num).resultsStageThree, 'ExDate' );
    %mice(mouse_num).resultsStageThree=flipud(TbyMouse(rows, :)); 
end
%% save ouput
prompt = 'If you''re going to add this data to a an existing dataset press 1 else press 0\n';
addData= input(prompt);
%Today= string(datetime('today'));% 13-Nov-2018,datetime->str  now
Today= char(datetime('now'));% 13-Nov-2018,datetime->str
Today= strcat(Today(1:11),'_',Today(13:14),'_',Today(16:17),'_',Today(19:20));

if addData
    FileNameToSaveTodaysOutput=strcat('ADD_',Today,'_to_AG_Mice_Dataset');
else
    FileNameToSaveTodaysOutput=strcat(Today,'_AG_Mice_Dataset');
end
save(FileNameToSaveTodaysOutput,'mice');