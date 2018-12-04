%fix dates
mice_names={'660','905','170','612','614'};
for mouse_num=1:length(mice_names)
miceWeightDataset(mouse_num).name
    userData = inputdlg({'FirstDate '}, 'Customer', [1 30], { '13-Aug-2018'});
    FirstDate=datetime(string(userData{2}));
    miceWeightDataset(mouse_num).Date(1,1)= FirstDate;

    for days=2:numel(miceWeightDataset(mouse_num).Weight)
        miceWeightDataset(mouse_num).Date(days,1)=miceWeightDataset(RowInTarget).Date(days-1,1)+1;
    end
    
    
end