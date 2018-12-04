clear all;
%% for 1st run create the database: a structure 'mice' with 2 fields: name and weight
%with 2 fields: mouse name, results which is a structure 
mice_names={'660','905','170','612','614'};
for mouse_num=1:length(mice_names)
    miceWeightDataset(mouse_num).name=string(mice_names(mouse_num));
    miceWeightDataset(mouse_num).Weight=[];
    miceWeightDataset(mouse_num).FoodGiven=[];
    miceWeightDataset(mouse_num).Date=datetime;
    miceWeightDataset(mouse_num).WeightChange=[0];
end
%% eneter former data that were in my google spreadshit
for mouse=1:length(mice_names)
    userData = inputdlg({'Mouse name','FirstDate','Weight'}, 'Customer', [1 10; 1 20; 30 10], {'170', '13-Aug-2018','0'});
    MouseName=userData{1};
    RowInTarget=AG_IndicesMatching(miceWeightDataset,string(MouseName));
    FirstDate=datetime(string(userData{2}));
    miceWeightDataset(RowInTarget).Date(1,1)= FirstDate;
    Weight=string(userData{3});
    Weight= str2double(Weight);
    miceWeightDataset(RowInTarget).Weight=Weight;
    %set the days
    for days=2:numel(miceWeightDataset(RowInTarget).Weight)
        miceWeightDataset(RowInTarget).Date(days,1)=miceWeightDataset(RowInTarget).Date(days-1,1)+1;
    end
 %% calculate the field WeightChange 
 for mouse=1:length(mice_names)
    miceWeightDataset(RowInTarget).WeightChange(:)=[];
    miceWeightDataset(RowInTarget).WeightChange(1:numel(miceWeightDataset(RowInTarget).Weight(:)))=...
        ( miceWeightDataset(RowInTarget).Weight(:)...
        -miceWeightDataset(RowInTarget).Weight(1,1) )...
    /miceWeightDataset(RowInTarget).Weight(1,1)*100;
 end
 
%      miceWeightDataset(RowInTarget).WeightChange(1:numel(miceWeightDataset(RowInTarget).Weight(:)))=...
%         ( miceWeightDataset(1).Weight(:)...
%         -miceWeightDataset(RowInTarget).Weight(1,1) )...
%     /miceWeightDataset(RowInTarget).Weight(1,1)*100;
    %%save the data
    Today= string(datetime('today'));% 13-Nov-2018,datetime->str
    FileNameToSaveTodaysOutput=strcat(Today,'AG_Mice_Weight');
    save(FileNameToSaveTodaysOutput,'miceWeightDataset');
end


%% for following runs, access the structure and append mouse data to the end of each column (the mouse's weight field)




