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
%AGGG

% % keep for doing an averaege latter
% Remember(:,RowInTarget)=miceWeightDataset(RowInTarget).Weight(:);
end


