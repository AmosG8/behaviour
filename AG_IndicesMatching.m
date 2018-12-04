function [indexAt_Target_Dataset]=AG_IndicesMatching(TargetDataBase,L1_mice)
%match indices function
% receives:
%1. a structure that contains a field 'name;     (AG_Mice_Dataset.name)
%2. a vector of mouse names L1_mice {'660' '905'...}

% returns indexes for the mice names within the structure: indexAtAG_Mice_Dataset
%so that mouse L1_mice(1) {aka 660} corresponds to mouse  AG_Mice_Dataset( indexAtAG_Mice_Dataset ).name
[m,mice_in_AG_Mice_Dataset]=size(TargetDataBase);
for iii=1:length(L1_mice)
 for k=1:mice_in_AG_Mice_Dataset
    if strfind(TargetDataBase(k).name,string(L1_mice(iii)))
        indexAt_Target_Dataset(iii)=k;
    end
 end
end