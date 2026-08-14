%% Function "ObjFuncValue"
%
% The function evaluates the Objective Function.
%
%%

function [ObjFuncValue]=ObjFuncValue(x_real_set,v_real_set,length_lead_set,t_step_data_set,ID_Exp,ID_GOF,Parm,x)
    
%     startClock=tic;
    
    % Parameters setup
    for i = 1 : length(x)
        x(i)=round(x(i)*Parm.precision)/Parm.precision;
    end
    clear i
    Parm=SetupModel(Parm,x);
    
    % Simulation
    ObjFuncValue=0;
    for s = 1 : length(x_real_set)
        Parm.l_i_1=length_lead_set{s,1}(1,1);
        Parm.dt=t_step_data_set{s,1}(1,1);
        [x_foll_sim,v_foll_sim,GOFs,CheckOutValue,Errors]=Simulation(...
            Parm,...
            struct(...
                'time',[0:0.1:(length(x_real_set{s,1}(:,1))-1)*0.1]',...
                'p_p',x_real_set{s,1}(:,1),...
                'p_f',x_real_set{s,1}(:,2),...
                'v_p',v_real_set{s,1}(:,1),...
                'v_f',v_real_set{s,1}(:,2)...
            )...
        );
        if CheckOutValue==0
            ObjFuncValue=100000;
            break;
        end
%         Figure=figure();
%         subplot(2,1,1);
%         hold all
%         plot([0:0.1:(length(x_real_set{s,1}(:,1))-1)*0.1]',v_real_set{s,1}(:,1),'k');
%         plot([0:0.1:(length(x_real_set{s,1}(:,1))-1)*0.1]',v_real_set{s,1}(:,2),'b');
%         plot([0:0.1:(length(x_real_set{s,1}(:,1))-1)*0.1]',v_foll_sim,'r');
%         hold off
%         subplot(2,1,2);
%         hold all
%         plot([0:0.1:(length(x_real_set{s,1}(:,1))-1)*0.1]',x_real_set{s,1}(:,1)-x_real_set{s,1}(:,2),'b');
%         plot([0:0.1:(length(x_real_set{s,1}(:,1))-1)*0.1]',x_real_set{s,1}(:,1)-x_foll_sim,'r');
%         hold off
%         close(Figure);
    end
    clear s
    
    if ObjFuncValue==0
        ObjFuncValue=GOFs(ID_GOF);
    end
    
%     endClock=toc(startClock);
    
    fprintf('ModelID: %li\t',Parm.model_id);
    fprintf('VehicleID: %li\t',Parm.vehicle_id);
    fprintf('GOFID: %li\t',ID_GOF);
    fprintf('ExpID: %li\t',ID_Exp);
    fprintf('ObjFuncValue: %.5f\t',ObjFuncValue);
%     fprintf('(%.5f,%.5f,%.5f)\t',GOFs(1:3));
%     fprintf('time: %.2f s\t',endClock);
%     fprintf('x: ')
%     fprintf('%.5f\t',x);
    fprintf('\n');
    
end