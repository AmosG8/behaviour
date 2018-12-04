%test    

% for ii=1:5
% miceWeightDataset(ii).WeightChange(:,1)=(miceWeightDataset(ii).Weight(:,1)-...
%     miceWeightDataset(ii).Weight(1,1))/miceWeightDataset(ii).Weight(1,1)*100;
% end

for ii=1:5
figure();
plot(miceWeightDataset(ii).WeightChange(:,1));
title(miceWeightDataset(ii).name);
end