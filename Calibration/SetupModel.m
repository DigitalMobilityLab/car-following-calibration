%% Function "SetupModel"
%
%%

function [Parm]=SetupModel(Parm,x)
    
    if Parm.model_id==1
        Parm.control_type = 'acc_idm';  
        Parm.delta = x(1);
        Parm.t_h = x(2);
        Parm.v_set = x(3);
        Parm.acc_a_max = x(4);
        Parm.acc_a_min = -x(5);
        Parm.d_0 = x(6);
        Parm.perception_delay=0;
    elseif Parm.model_id==2
        Parm.control_type = 'acc_gipps';  
        Parm.t_h = x(1);
        Parm.teta = x(2);
        Parm.acc_a_max = x(3);
        Parm.v_set = x(4);
        Parm.acc_a_min = -x(5);
        Parm.est_a_min_p = -x(6);
        Parm.d_0 = x(7);
        Parm.perception_delay=0;
    elseif Parm.model_id==3
        Parm.control_type = 'acc_cth';  
        Parm.k_v = x(1);
        Parm.k_dv = x(2);
        Parm.d_0 = x(3);
        Parm.t_h = x(4);
        Parm.v_set = x(5);
        Parm.perception_delay=0;
    elseif Parm.model_id==4
        Parm.control_type = 'acc_sigmoid';  
        Parm.k_v = x(1);
        Parm.k_dv = x(2);
        Parm.d_0 = x(3);
        Parm.t_h = x(4);
        Parm.v_set = x(5);
        Parm.perception_delay=0;
    elseif Parm.model_id==5
        Parm.control_type = 'acc_ovm';  
        Parm.k_v = x(1);
        Parm.v1 = x(2);
        Parm.v2 = x(3);
        Parm.c1 = x(4);
        Parm.c2 = x(5);
        Parm.perception_delay=0;
    elseif Parm.model_id==6
        Parm.control_type = 'acc_fvdm';  
        Parm.k_v = x(1);
        Parm.k_dv = x(2);
        Parm.v1 = x(3);
        Parm.v2 = x(4);
        Parm.c1 = x(5);
        Parm.c2 = x(6);
        Parm.perception_delay=0;   
    elseif Parm.model_id==999
        Parm.control_type = 'acc_custom';
        for i = 1 : length(x)-1
            Parm.(['x',num2str(i)]) = x(i);
        end
        Parm.perception_delay=x(end);
    end
    
end