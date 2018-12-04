
mice_names={'660','905','170','612','614'};
%% open previous info
[FileName,path] = uigetfile('select the last Mouse weight database file');
selectedfile = fullfile(path,FileName);
load (selectedfile);

%% enter initial data
userData = inputdlg({'MouseName','Todaysweight','Enter 0 if this not today''s data enter 1 for today '},...
    'Customer', [1 10; 1 20; 1 10]);
MouseName=userData{1};
Todaysweight=str2double(string(userData{2}));

% prompt = 'what is the mouse name? \n';
% MouseName= input(prompt) 
% prompt = 'what is the mouse weight? \n';
% Todaysweight= input(prompt)  
% prompt = 'are you about to eneter today''s data? 0 for no 1 for yes \n';
% Today= input(prompt) 
if ~str2double(userData{3})
    prompt = 'what''s the date write in this format: ''18-Nov-2018''   \n Don''t forget the '' \n';
    Today= input(prompt)
    Today=datetime(Today);
else
    Today=datetime;
end
%% find the row in miceWeightDataset that corresponds to this mouse
RowInTarget=AG_IndicesMatching(miceWeightDataset,string(MouseName));
%% add the date 
miceWeightDataset(RowInTarget).Date(end+1,1)=Today;
%% and the weight
miceWeightDataset(RowInTarget).Weight(end+1)=Todaysweight;


%% Calculate store and plot the change from the begining
miceWeightDataset(RowInTarget).WeightChange(end+1)=...
    ( miceWeightDataset(RowInTarget).Weight(end)...
    -miceWeightDataset(RowInTarget).Weight(1,1) )...
    /miceWeightDataset(RowInTarget).Weight(1,1)*100;

%% Plots 
figure()
plot(miceWeightDataset(RowInTarget).Weight(:));
title(miceWeightDataset(RowInTarget).name);

figure()
plot(miceWeightDataset(RowInTarget).WeightChange(:));
title(miceWeightDataset(RowInTarget).name);

%% calculate weight difference and show the user the difference and the former amount of food given 
if numel(miceWeightDataset(RowInTarget).Weight)>1  
    Difference=miceWeightDataset(RowInTarget).Weight(end)-miceWeightDataset(RowInTarget).Weight(end-1);
    if numel(miceWeightDataset(RowInTarget).FoodGiven())>0
      fprintf('last time the mouse weight was %5.2f\n It received %5.2fg of food \n Since then the mouse gained %5.2f \n', miceWeightDataset(RowInTarget).Weight(end-1), ...
          miceWeightDataset(RowInTarget).FoodGiven(end), Difference); 
    end
  else
   Difference=0;
   fprintf('There is no former info\n'); 
end

%% 
prompt = 'how much food are you giving the mouse today? \n';
FoodGiven= input(prompt)
miceWeightDataset(RowInTarget).FoodGiven(end+1,1)=FoodGiven;
%% save with the new info
Today= string(date);% 13-Nov-2018,datetime->str
FileNameToSaveTodaysOutput=strcat('W_',Today,'AG_Mice_Weight');
save(FileNameToSaveTodaysOutput,'miceWeightDataset');

