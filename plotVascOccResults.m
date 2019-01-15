
% the source database is already pre-made
% using the command window and commands such as
% Occ170_Jan9th_19.after(5,:)=DataCopy(19,:)

%plot mean and sem for lick per sec for the 3 conditions

%% for a clear code
% beforeData=Occ170_Jan9th_19.before.licksPerSec;
% duringData=Occ170_Jan9th_19.during.licksPerSec;
% afterData=Occ170_Jan9th_19.after.licksPerSec;

beforeData=Occ170_Jan9th_19.before.Trial_nogoAtAllPERC;
duringData=Occ170_Jan9th_19.during.Trial_nogoAtAllPERC;
afterData=Occ170_Jan9th_19.after.Trial_nogoAtAllPERC;


%% computation
meanBefore=mean(beforeData);
semBefore= nanstd(beforeData) / sqrt( length(beforeData));

meanDuring=mean(duringData);
semDuring= nanstd(duringData) / sqrt( length(duringData));

meanAfter=mean(afterData);
semAfter= nanstd(afterData) / sqrt( length(afterData));

allMeans=[meanBefore, meanDuring, meanAfter];
allSEM=[semBefore,semDuring,semAfter];

figure();
errorbar(allMeans, allSEM);
title({'Trial_nogoAtAllPERC'});
axis([0 4 0 80]);
% %% plots
% figure();
% x=1:3; %for before during and after
% data=[meanBefore, meanDuring, meanAfter];
% bar(x,data);
% hold on
% 
% errorbar(meanBefore, semBefore);