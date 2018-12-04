%add more rows to an existing results-table
%mice_names={'660','905','170','612','614'};
clear all;

[FileName,path] = uigetfile('Select the file with the analayzed data you wanna add','Select the file');
selectedfile = fullfile(path,FileName);
New_data=open(selectedfile);

[FileName,path] = uigetfile('Select the database to which you wanna add');
selectedfile = fullfile(path,FileName);
BasicDatabase=open(selectedfile);
%%
[temp,number_of_mice_to_add]=size(New_data.mice);
for CurrentMouseAdded=1:number_of_mice_to_add
    % check if there is data to add for stage 1 and add it if there's
   if ~isempty(New_data.mice(CurrentMouseAdded).resultsStone) %true when there's content
       %where is that mouse in the basic database
       Target_line_in_basic_database=AG_IndicesMatching(BasicDatabase.mice, New_data.mice(CurrentMouseAdded).name);
       %how many lines to add within the result 
        [number_of_lines_to_add_to_Amouse,temp]=size(New_data.mice(CurrentMouseAdded).resultsStone);
        %adding the data
        BasicDatabase.mice(Target_line_in_basic_database).resultsStone(end+1:end+number_of_lines_to_add_to_Amouse, :)=...
            New_data.mice(CurrentMouseAdded).resultsStone(:,:);
   end
   % stage 2
   if ~isempty(New_data.mice(CurrentMouseAdded).resultsStageTwo) %true when there's content
       %where is that mouse in the basic database
       Target_line_in_basic_database=AG_IndicesMatching(BasicDatabase.mice, New_data.mice(CurrentMouseAdded).name);
       %how many lines to add within the result
       [number_of_lines_to_add_to_Amouse,temp]=size(New_data.mice(CurrentMouseAdded).resultsStageTwo);
       %adding the data
       BasicDatabase.mice(Target_line_in_basic_database).resultsStageTwo(end+1:end+number_of_lines_to_add_to_Amouse, :)=...
           New_data.mice(CurrentMouseAdded).resultsStageTwo(:,:);
   end
   %stage 3
   if ~isempty(New_data.mice(CurrentMouseAdded).resultsStageThree) %true when there's content
       %where is that mouse in the basic database
       Target_line_in_basic_database=AG_IndicesMatching(BasicDatabase.mice, New_data.mice(CurrentMouseAdded).name);
       %how many lines to add within the result
       [number_of_lines_to_add_to_Amouse,temp]=size(New_data.mice(CurrentMouseAdded).resultsStageThree);
       %adding the data
       BasicDatabase.mice(Target_line_in_basic_database).resultsStageThree(end+1:end+number_of_lines_to_add_to_Amouse, :)=...
           New_data.mice(CurrentMouseAdded).resultsStageThree(:,:);
   end  
end  
%% save
%Today= string(datetime('now'));% 13-Nov-2018,datetime->str
Today= char(datetime('now'));
Today= strcat(Today(1:11),'_',Today(13:14),'_',Today(16:17),'_', Today(19:end));

FileNameToSaveTodaysOutput=strcat('Updated_',Today,'_AG_Mice_Dataset');
mice=BasicDatabase.mice;
save(FileNameToSaveTodaysOutput,'mice');