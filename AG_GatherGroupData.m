function [AllMiceFieldData,meanMice,semMice,max_rows]=AG_GatherGroupData(L_mice,mice,indexAtAG_Mice_Dataset,Field_Name, ExStage )
 %% gather data from all mice for field X of struct aligned to the end
max_rows=1;
 switch ExStage
    case 1   
    %1.find the longest column (aka training days) in L1 mice 
        for mouseNum=1:length(L_mice) %indexAtAG_Mice_Dataset holds the index for that mouse in AG dataset
            MouseRows(mouseNum)=numel(mice(indexAtAG_Mice_Dataset(mouseNum)).resultsStone{:,Field_Name});
            if max_rows<MouseRows(mouseNum)
                max_rows=MouseRows(mouseNum);
            end
        end
      %2.make a matrix of the data from all mice that is alinged to the last
        %training day
        for mouseNum=1:length(L_mice)
            if max_rows-MouseRows(mouseNum)>0
               AllMice(1:max_rows-MouseRows(mouseNum),mouseNum)=NaN;
            end
            AllMice((max_rows-MouseRows(mouseNum)+1:max_rows),mouseNum)=...
               mice(indexAtAG_Mice_Dataset(mouseNum)).resultsStone{:,Field_Name};
        end         

    case 2
       for mouseNum=1:length(L_mice) %indexAtAG_Mice_Dataset holds the index for that mouse in AG dataset
            MouseRows(mouseNum)=numel(mice(indexAtAG_Mice_Dataset(mouseNum)).resultsStageTwo{:,Field_Name});
            if max_rows<MouseRows(mouseNum)
                max_rows=MouseRows(mouseNum);
            end
       end
      %2.make a matrix of the data from all mice that is alinged to the last
        %training day
        for mouseNum=1:length(L_mice)
            if max_rows-MouseRows(mouseNum)>0
               AllMice(1:max_rows-MouseRows(mouseNum),mouseNum)=NaN;
            end
            AllMice((max_rows-MouseRows(mouseNum)+1:max_rows),mouseNum)=...
              mice(indexAtAG_Mice_Dataset(mouseNum)).resultsStageTwo{:,Field_Name};
        end         

     case 3
       for mouseNum=1:length(L_mice) %indexAtAG_Mice_Dataset holds the index for that mouse in AG dataset
            MouseRows(mouseNum)=numel(mice(indexAtAG_Mice_Dataset(mouseNum)).resultsStageThree{:,Field_Name});
            if max_rows<MouseRows(mouseNum)
                max_rows=MouseRows(mouseNum);
            end
       end
      %2.make a matrix of the data from all mice that is alinged to the last
        %training day
        for mouseNum=1:length(L_mice)
            if max_rows-MouseRows(mouseNum)>0
               AllMice(1:max_rows-MouseRows(mouseNum),mouseNum)=NaN;
            end
            AllMice((max_rows-MouseRows(mouseNum)+1:max_rows),mouseNum)=...
               mice(indexAtAG_Mice_Dataset(mouseNum)).resultsStageThree{:,Field_Name};
          
        end
 end
%3. compute and plot
meanMice=nanmean(AllMice,2);%2 for avereaging across rows
semMice= nanstd( AllMice,0,2 ) / sqrt( length(L_mice));
AllMiceFieldData=AllMice;