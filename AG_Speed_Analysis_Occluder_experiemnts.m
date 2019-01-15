%analysis of speed in occluder experiemnts

%1. choose the speed files

%2. loop over the files

%2.1 determine if the file is at directory of mouse number 1 or mouse 2
% because mouse number 1 was 1000samples/sec and mouse 2 was 60samples/sec
%then slice each file to before, during and after

%2.2. place the data within a 3 col matrix matrix
%% intialization
clear all
RowsformerMouse=0;
%% loop over the two folders
for mouse=1:2
    %% 1. choose the speed files
    [fileName,path] = uigetfile('Select at least 2 Files', 'MultiSelect', 'on');
    [m, files]=size(fileName); %n is the number of files choosen
    %% loop over the files
    for selected_file=1:files
        data=load (char( fullfile(path, fileName(1,selected_file))) );%data has 2 columns 
        %the 1st is the puff the 2nd is the speed
        %2.1 
        if strcmp(path, 'Y:\Amos\David\mouse1\')
            beginOccAtFrame=ceil(17484*100/6);
            endOccAtFrame=ceil(24484*100/6);
            threshold= 0.2;
        else %this is mouse 2
            beginOccAtFrame=17484;
            endOccAtFrame=24484;
            threshold=500;
            data=data*(-1); %in this mouse the speed is in negative numbers
        end
        %2.3
        %calculate mean within each trial 
        MeanSpeed(selected_file+RowsformerMouse,1)=length(find (data(1:beginOccAtFrame-1,2) >threshold)) /beginOccAtFrame *100;
        MeanSpeed(selected_file+RowsformerMouse,2)=length(find (data(beginOccAtFrame:endOccAtFrame,2)>threshold)) /(endOccAtFrame-beginOccAtFrame)*100;
        MeanSpeed(selected_file+RowsformerMouse,3)=length(find(data(endOccAtFrame+1:end,2)>threshold)) /( length(data(:,2)) -endOccAtFrame) *100; 
    end
    MouseMean(mouse,:)=mean(MeanSpeed(RowsformerMouse+1:end,:));
    RowsformerMouse=RowsformerMouse+selected_file;   
end  
%% calculate the mean across trials of the bofore during after
MeanAcrossTrials=mean(MeanSpeed); %mean of matrix is done on the col in default
SEMS= nanstd (MeanSpeed(:,:) / sqrt( length(MeanSpeed(:,1) )));
figure(1);
errorbar(MeanAcrossTrials, SEMS);
title({'speed Mean Across Trials'});
axis([0 4 0 40]);

% mean across mice
MeanMice=mean(MouseMean); %mean of matrix is done on the col in default
SEMS= nanstd (MouseMean(:,:) / sqrt( length(MouseMean(:,1) )));
figure(2);
errorbar(MeanMice, SEMS);
title({'speed  Mean Across Mice'});
axis([0 4 0 40]);

