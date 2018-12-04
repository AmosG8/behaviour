%load 14-Nov-2018AG_Mice_Weight.mat;
FileName = uigetfile('select the last Mouse weight database file');
load (FileName);

L1_mice=string('905');
A=AG_IndicesMatching(miceWeightDataset,L1_mice)
%test