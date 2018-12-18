clear all

L1_mice=[660,905,170,612,614];
L2_mice=[660,905,170, 612, 614];
L3_mice=[170];

FileName = uigetfile('select the last AG_Mice_Dataset file');
load (FileName);

%AG_Mice_Dataset=open('21-Nov-2018AG_Mice_Dataset.mat');
%AllMice1=[];

%% match the indices of mice with their indices at AG_Dataset
indexAtAG_Mice_DatasetStage1=AG_IndicesMatching(mice,L1_mice);
indexAtAG_Mice_DatasetStage2=AG_IndicesMatching(mice,L2_mice);
indexAtAG_Mice_DatasetStage3=AG_IndicesMatching(mice,L3_mice);

%% get the data for the plots and make them
%% Level 1
[all1,MeanMice,SEMmice,max_rows]=AG_GatherGroupData...
    (L1_mice,mice, indexAtAG_Mice_DatasetStage1,'licksPerSec',1);
  %figure(100);
  subplot(3,4,1);
  errorbar( MeanMice,SEMmice); 
  title({'stage 1 5 mice','licksPerSec  trained 4-17 days'});
  axis([0 max_rows+2 0 2.5]);
%% level 2
[all2,MeanMice,SEMmice,max_rows]=AG_GatherGroupData...
    (L2_mice,mice, indexAtAG_Mice_DatasetStage2,'Percent_correct_location_time',2);
  %figure(200);
  subplot(3,4,5);
  errorbar( MeanMice,SEMmice); 
  title({'Level 2 4 mice',' correct_location and time '});
  axis([0 max_rows+2 30 100]);
%% level 3
subplot(3,4,9);
  [all3,MeanMice,SEMmice,max_rows]=AG_GatherGroupData...
      (L3_mice,mice, indexAtAG_Mice_DatasetStage3,'Percent_correct_location_time',3);
  %figure(300);
  errorbar( MeanMice,SEMmice); 
  title({'level 3 1 mouse' , 'correct_location and time'});
  axis([0 max_rows+2 0 60]);
  [all,MeanMice,SEMmice,max_rows]=AG_GatherGroupData...
      (L3_mice,mice, indexAtAG_Mice_DatasetStage3,'Percent_correct_location_time',3);
 
  subplot(3,4,10);
  %figure(301);
  [all,MeanMice,SEMmice,max_rows]=AG_GatherGroupData...
      (L3_mice,mice, indexAtAG_Mice_DatasetStage3,'Percent_Time_Licks',3);
  errorbar( MeanMice,SEMmice); 
  title({'Correct Time', 'Licks'});
  axis([0 max_rows+2 0 60])

  subplot(3,4,11);
   % figure(302);
  [all,MeanMice,SEMmice,max_rows]=AG_GatherGroupData...
      (L3_mice,mice, indexAtAG_Mice_DatasetStage3,'Percent_CorrectLocation_Licks',3);
  errorbar( MeanMice,SEMmice); 
  title({'Correct Location','Licks'});
  axis([0 max_rows+2 50 100])

   subplot(3,4,12);
   % figure(302);
  [all,MeanMice,SEMmice,max_rows]=AG_GatherGroupData...
      (L3_mice,mice, indexAtAG_Mice_DatasetStage3,'TrialhitsPERC',3);
  errorbar( MeanMice,SEMmice); 
  title('Trialhits');
  axis([0 max_rows+2 0 70])
 
  %% single mice plots
  figure();  
  for mouse_line=1:length(L1_mice)
      plot(all1(:,mouse_line),'LineWidth',4);
      hold on
     String_L1_mice(mouse_line)=string(L1_mice( mouse_line));
  end
  title('level 1 licksPerSec');
  h1=legend(String_L1_mice);
  hold off
  
    figure();  
  for mouse_line=1:length(L2_mice)
      plot(all2(:,mouse_line),'LineWidth',4);
      hold on
     String_L2_mice(mouse_line)=string(L2_mice( mouse_line));
  end
  title('level 2 correct_location and time');
  h1=legend(String_L2_mice);
  hold off
  % %saveas(gcf,'mean all mice Percent_correct_location','png');
