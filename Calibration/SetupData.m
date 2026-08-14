%% Function "SetupData"

%%
       
function [x_real_set,v_real_set,length_lead_set,t_step_data_set]=SetupData(Project,Database,VehicleID,Experiments)
    
    % Setup data
    x_real_set=cell(length(Experiments),1);
    v_real_set=cell(length(Experiments),1);
    length_lead_set=cell(length(Experiments),1);
    t_step_data_set=cell(length(Experiments),1);
    for s = 1 : length(Experiments)
        [x_real_set{s,1},v_real_set{s,1},length_lead_set{s,1},t_step_data_set{s,1}]=ImportTrajectoryData(Project,Database,VehicleID,Experiments{s});
    end
    clear s
    
end