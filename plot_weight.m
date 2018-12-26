[FileName,path] = uigetfile('select the last Mouse weight database file');
selectedfile = fullfile(path,FileName);
load (selectedfile);

for RowInTarget=1:5
figure()
plot(miceWeightDataset(RowInTarget).Weight(:));
title(miceWeightDataset(RowInTarget).name);

figure()
plot(miceWeightDataset(RowInTarget).WeightChange(:));
title(miceWeightDataset(RowInTarget).name);


% % keep for doing an averaege latter
% Remember(:,RowInTarget)=miceWeightDataset(RowInTarget).Weight(:);
end
%% a plot of all weights
figure()
for index=1:5
    subplot(3,2,index);
    plot(miceWeightDataset(index).WeightChange(:));
    title(miceWeightDataset(index).name);
    days=numel(miceWeightDataset(index).WeightChange);
    axis([0 days+5 -40 10])
end
%% for 170 stage 3
figure()
plot(miceWeightDataset(3).WeightChange(end-30:end));