clear all
L1_names=[660,905,170, 612, 614];
AG_Mice_Dataset=open('AG_Mice_Dataset.mat');

for mouseNum=1:length(L1_names)
    MixedTable=AG_Mice_Dataset.mice(mouseNum).results;
    rows = MixedTable.ExStage == 1;
   
    NewTable.L1_names(mouseNum)=MixedTable(rows,:);
    
end