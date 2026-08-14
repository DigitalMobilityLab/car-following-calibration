%% Function "Simulation"
%
% The script performs the simulation of the car-following model.
%%

function [x_foll_sim,v_foll_sim,GOFs,CheckOutValue,Errors]=Simulation(Parm,exp_data)
    
    time=exp_data.time;
    xLead=exp_data.p_p;
    vLead=exp_data.v_p;
    aLead=[diff(vLead);0];
    xFollReal=exp_data.p_f;
    vFollReal=exp_data.v_f;
    aFollReal=[diff(vFollReal);0];
    
    T=length(time);
    tps=round(Parm.perception_delay/Parm.dt);
    
    xFollSim=zeros(T,1);
    vFollSim=zeros(T,1);
    aFollSim=zeros(T,1);

    success=1;
    for t = 0 : T-1
        if t<=tps
            xFollSim(t+1,1)=xFollReal(t+1,1);
            vFollSim(t+1,1)=vFollReal(t+1,1);
            aFollSim(t+1,1)=aFollReal(t+1,1);
        else
            [x,v,a,success] = simulateCF(xLead(t-tps,1),vLead(t-tps,1),aLead(t-tps,1),xFollSim(t-tps,1),vFollSim(t-tps,1),aFollSim(t-tps,1),xFollSim(t,1),vFollSim(t,1),aFollSim(t,1),Parm);
            if success==0 || xLead(t,1)-x-Parm.l_i_1<0
                success=0;
                break;
            end
            xFollSim(t+1,1)=x;
            vFollSim(t+1,1)=v;
            aFollSim(t+1,1)=a;
        end
    end
    clear i

    if success==0
        x_foll_sim=[];
        v_foll_sim=[];
        GOFs=ones(29,1)*100000;
        CheckOutValue=0;
        Errors=[];
        return;
    end
    
    xLead=xLead(tps+1:end,1);
    xFollReal=xFollReal(tps+1:end,1);
    vFollReal=vFollReal(tps+1:end,1);
    aFollReal=aFollReal(tps+1:end,1);
%     aFollRealScaled=aFollReal+9.81;
    xFollSim=xFollSim(tps+1:end,1);
    vFollSim=vFollSim(tps+1:end,1);
    aFollSim=aFollSim(tps+1:end,1);
%     aFollSimScaled=aFollSim+9.81;
    
    dReal=xLead-xFollReal-Parm.l_i_1;
    dSim=xLead-xFollSim-Parm.l_i_1;
    
    vStdReal=std(vFollReal);
    vStdSim=std(vFollSim);
    
    index_v_cut=vFollReal>=Parm.speed_cut_value;
    index_a_cut=(aFollReal>=Parm.acc_cut_value | aFollReal<=-Parm.acc_cut_value);
    
    vFollRealCut=vFollReal(index_v_cut);
    aFollRealCut=aFollReal(index_a_cut);
%     aFollRealScaledCut=aFollRealScaled(index_a_cut);
    
%     dRealMin=min(dReal);
%     dRealMax=max(dReal);
%     vRealMin=min(vFollReal);
%     vRealMax=max(vFollReal);
%     aRealMin=min(aFollReal);
%     aRealMax=max(aFollReal);
    
    errors_d = dSim-dReal;
    errors_v = vFollSim-vFollReal;
    errors_a = aFollSim-aFollReal;
%     errors_a_scaled = aFollSimScaled-aFollRealScaled;
%     errors_d_norm = (dSim-dRealMin)/(dRealMax-dRealMin)-(dReal-dRealMin)/(dRealMax-dRealMin);
%     errors_v_norm = (vFollSim-vRealMin)/(vRealMax-vRealMin)-(vFollReal-vRealMin)/(vRealMax-vRealMin);
%     errors_a_norm = (aFollSim-aRealMin)/(aRealMax-aRealMin)-(aFollReal-aRealMin)/(aRealMax-aRealMin);
    errors_std_v = vStdSim-vStdReal;
    errors_v_cut = errors_v(index_v_cut,1);
    errors_a_cut = errors_a(index_a_cut,1);
%     errors_a_cut_scaled = errors_a_scaled(index_a_cut,1);
    errors_percentage_d = errors_d./dReal;
    errors_percentage_v = errors_v_cut./vFollRealCut;
    errors_percentage_a = errors_a_cut./aFollRealCut;
%     errors_percentage_a_scaled = errors_a_cut_scaled./aFollRealScaledCut;
    errors_percentage_std_v = errors_std_v./vStdReal;
    errors_percentage_d_tilde = errors_d./sqrt(dReal);
    errors_percentage_v_tilde = errors_v_cut./sqrt(vFollRealCut);

    rmse_d = sqrt(mean(errors_d.^2));
    rmse_v = sqrt(mean(errors_v.^2));
    rmse_a = sqrt(mean(errors_a.^2));
%     rmse_a_scaled = sqrt(mean(errors_a_scaled.^2));
%     rmse_d_norm = sqrt(mean(errors_d_norm.^2));
%     rmse_v_norm = sqrt(mean(errors_v_norm.^2));
%     rmse_a_norm = sqrt(mean(errors_a_norm.^2));
    rmse_std_v = sqrt(mean(errors_std_v.^2));
    rmspe_d = sqrt(mean(errors_percentage_d.^2));
    rmspe_v = sqrt(mean(errors_percentage_v.^2));
    rmspe_a = sqrt(mean(errors_percentage_a.^2));
%     rmspe_a_scaled = sqrt(mean(errors_percentage_a_scaled.^2));
    rmspe_std_v = sqrt(mean(errors_percentage_std_v.^2));
    mae_d = mean(abs(errors_d));
    mae_v = mean(abs(errors_v));
    mae_a = mean(abs(errors_a));
    mape_d = mean(abs(errors_percentage_d));
    mape_v = mean(abs(errors_percentage_v));
    mape_a = mean(abs(errors_percentage_a));
%     mape_a_scaled = mean(abs(errors_percentage_a_scaled));
    u_d = rmse_d/(sqrt(mean(dReal.^2))+sqrt(mean(dSim.^2)));
    u_v = rmse_v/(sqrt(mean(vFollReal.^2))+sqrt(mean(vFollSim.^2)));
    u_a = rmse_a/(sqrt(mean(aFollReal.^2))+sqrt(mean(aFollSim.^2)));
%     u_a_scaled = rmse_a_scaled/(sqrt(mean(aFollRealScaled.^2))+sqrt(mean(aFollSimScaled.^2)));
    rmspe_d_tilde = sqrt(mean(errors_percentage_d_tilde.^2)/mean(dReal));
    rmspe_v_tilde = sqrt(mean(errors_percentage_v_tilde.^2)/mean(vFollRealCut));

    nrmse_d = rmse_d/sqrt(mean(dReal.^2));
    nrmse_v = rmse_v/sqrt(mean(vFollReal.^2));
    nrmse_a = rmse_a/sqrt(mean((aFollReal+9.81).^2));
%     nrmse_a_scaled = rmse_a_scaled/sqrt(mean((aFollRealScaled).^2));
    
    nrmse_d_v = nrmse_d + nrmse_v;
    rmspe_d_v = rmspe_d + rmspe_v;
    rmspe_std_v_d = rmspe_std_v + rmspe_d;
    mape_d_v = mape_d + mape_v;
    rmspe_d_v_tilde = rmspe_d_tilde + rmspe_v_tilde;
    u_d_v = u_d + u_v;
%     rmse_d_v_norm = rmse_d_norm + rmse_v_norm;
    
    nrmse_d_v_a = nrmse_d + nrmse_v + nrmse_a;
    rmspe_d_v_a = rmspe_d + rmspe_v + rmspe_a;
    mape_d_v_a = mape_d + mape_v + mape_a;
    u_d_v_a = u_d + u_v + u_a;
%     rmse_d_v_a_norm = rmse_d_norm + rmse_v_norm + rmse_a_norm;
    
%     nrmse_d_v_a_scaled = nrmse_d + nrmse_v + nrmse_a_scaled;
%     rmspe_d_v_a_scaled = rmspe_d + rmspe_v + rmspe_a_scaled;
%     mape_d_v_a_scaled = mape_d + mape_v + mape_a_scaled;
%     u_d_v_a_scaled = u_d + u_v + u_a_scaled;
    
    GOFs = [
        rmse_d,...
        rmse_v,...
        rmse_a,...
        rmse_std_v,...
        rmspe_d,...
        rmspe_v,...
        rmspe_a,...
        rmspe_std_v,...
        mae_d,...
        mae_v,...
        mae_a,...
        mape_d,...
        mape_v,...
        mape_a,...
        u_d,...
        u_v,...
        u_a,...
        rmspe_d_tilde,...
        rmspe_v_tilde,...
        rmspe_std_v_d,...
        nrmse_d_v,...
        rmspe_d_v,...
        mape_d_v,...
        rmspe_d_v_tilde,...
        u_d_v,...
        nrmse_d_v_a,...
        rmspe_d_v_a,...
        mape_d_v_a,...
        u_d_v_a,...
    ]';
    
    x_foll_sim=xFollSim;
    v_foll_sim=vFollSim;
    
    Errors=[errors_v',errors_d'];
    
    CheckOutValue=success;
    
end

function [x,v,a,success] = simulateCF(xLeadDelay,vLeadDelay,aLeadDelay,xFollDelay,vFollDelay,aFollDelay,xFoll,vFoll,aFoll,Parm)

    if strcmp(Parm.control_type,'acc_idm')==1
        [a,success]=idm(xLeadDelay,vLeadDelay,aLeadDelay,xFollDelay,vFollDelay,aFollDelay,xFoll,vFoll,aFoll,Parm);
    elseif strcmp(Parm.control_type,'acc_gipps')==1
        [a,success]=gipps(xLeadDelay,vLeadDelay,aLeadDelay,xFollDelay,vFollDelay,aFollDelay,xFoll,vFoll,aFoll,Parm);
    elseif strcmp(Parm.control_type,'acc_cth')==1
        [a,success]=cth(xLeadDelay,vLeadDelay,aLeadDelay,xFollDelay,vFollDelay,aFollDelay,xFoll,vFoll,aFoll,Parm);
    elseif strcmp(Parm.control_type,'acc_sigmoid')==1
        [a,success]=sigmoid(xLeadDelay,vLeadDelay,aLeadDelay,xFollDelay,vFollDelay,aFollDelay,xFoll,vFoll,aFoll,Parm);
    elseif strcmp(Parm.control_type,'acc_ovm')==1
        [a,success]=ovm(xLeadDelay,vLeadDelay,aLeadDelay,xFollDelay,vFollDelay,aFollDelay,xFoll,vFoll,aFoll,Parm);
    elseif strcmp(Parm.control_type,'acc_fvdm')==1
        [a,success]=fvdm(xLeadDelay,vLeadDelay,aLeadDelay,xFollDelay,vFollDelay,aFollDelay,xFoll,vFoll,aFoll,Parm);
    elseif strcmp(Parm.control_type,'acc_custom')==1
        [a,success]=custom(xLeadDelay,vLeadDelay,aLeadDelay,xFollDelay,vFollDelay,aFollDelay,xFoll,vFoll,aFoll,Parm);
    end

    if success==0
        x=0;
        v=0;
        return;
    end
    
    if vFoll==0
        a=max(0,a);
    end
    
    v=max(0,vFoll+a*Parm.dt);
    a=(v-vFoll)/Parm.dt;
    x=xFoll+(vFoll+v)*Parm.dt/2;
    
end

function [a,success] = idm(xLeadDelay,vLeadDelay,aLeadDelay,xFollDelay,vFollDelay,aFollDelay,xFoll,vFoll,aFoll,Parm)
    
    success=1;

    desiredSpacing=Parm.d_0+max(...
        Parm.t_h*vFollDelay+vFollDelay*(vFollDelay-vLeadDelay)/(2*sqrt(-Parm.acc_a_max*Parm.acc_a_min)),...
        0);
    actualSpacing=xLeadDelay-xFollDelay-Parm.l_i_1;

    a=Parm.acc_a_max*(1-(vFollDelay/Parm.v_set)^Parm.delta-(desiredSpacing/actualSpacing)^2);

end

function [a,success] = gipps(xLeadDelay,vLeadDelay,aLeadDelay,xFollDelay,vFollDelay,aFollDelay,xFoll,vFoll,aFoll,Parm)
    
    success=1;

    safeSpacing=xLeadDelay-xFollDelay-Parm.l_i_1-Parm.d_0;

    arg=Parm.acc_a_min^2*(0.5*Parm.t_h+Parm.teta)^2-Parm.acc_a_min*(2*safeSpacing-vFollDelay*Parm.t_h-vLeadDelay^2/Parm.est_a_min_p);
    if arg <= 0
        a=-Inf;
        success=0;
        return;
    end

    vNext=min(...
        vFollDelay+2.5*Parm.acc_a_max*Parm.t_h*(1-vFollDelay/Parm.v_set)*(0.025+vFollDelay/Parm.v_set)^0.5,...
        Parm.acc_a_min*(0.5*Parm.t_h+Parm.teta)+sqrt(arg)...
    );

    vNext=max(0,vNext);

    a=(vNext-vFoll)/Parm.t_h;
    
end

function [a,success] = cth(xLeadDelay,vLeadDelay,aLeadDelay,xFollDelay,vFollDelay,aFollDelay,xFoll,vFoll,aFoll,Parm)
    
    success=1;
    
    d_1=Parm.d_0+Parm.t_h*Parm.v_set;
    
    actualSpacing=xLeadDelay-xFollDelay-Parm.l_i_1;

    if actualSpacing<Parm.d_0
        vStar=0;
    elseif actualSpacing<=d_1
        vStar=(actualSpacing-Parm.d_0)/Parm.t_h;
    else
        vStar=Parm.v_set;
    end
    
    errorSpeed=vStar-vFollDelay;
    errorDeltaSpeed=vLeadDelay-vFollDelay;
    
    a=...
        +Parm.k_v*errorSpeed+...   
        +Parm.k_dv*errorDeltaSpeed;
    
end

function [a,success] = sigmoid(xLeadDelay,vLeadDelay,aLeadDelay,xFollDelay,vFollDelay,aFollDelay,xFoll,vFoll,aFoll,Parm)
    
    success=1;
    
    d_1=Parm.t_h*Parm.v_set+Parm.d_0;
    
    actualSpacing=xLeadDelay-xFollDelay-Parm.l_i_1;
    if actualSpacing<Parm.d_0
        vStar=0;
    elseif actualSpacing<=d_1
        vStar=(Parm.v_set/2)*(1-cos(pi*(actualSpacing-Parm.d_0)/(d_1-Parm.d_0)));
    else
        vStar=Parm.v_set;
    end
    
    errorSpeed=vStar-vFollDelay;
    errorDeltaSpeed=vLeadDelay-vFollDelay;
    
    a=...
        +Parm.k_v*errorSpeed+...   
        +Parm.k_dv*errorDeltaSpeed;
    
end

function [a,success] = ovm(xLeadDelay,vLeadDelay,aLeadDelay,xFollDelay,vFollDelay,aFollDelay,xFoll,vFoll,aFoll,Parm)
    
    success=1;
    
    actualSpacing=xLeadDelay-xFollDelay-Parm.l_i_1;
    
    vStar=max(0,Parm.v1+Parm.v2*tanh(Parm.c1*actualSpacing-Parm.c2));
    
    errorSpeed=vStar-vFollDelay;
    
    a=Parm.k_v*errorSpeed;
    
end

function [a,success] = fvdm(xLeadDelay,vLeadDelay,aLeadDelay,xFollDelay,vFollDelay,aFollDelay,xFoll,vFoll,aFoll,Parm)
    
    success=1;
    
    actualSpacing=xLeadDelay-xFollDelay-Parm.l_i_1;
    
    vStar=max(0,Parm.v1+Parm.v2*tanh(Parm.c1*actualSpacing-Parm.c2));
    
    errorSpeed=vStar-vFollDelay;
    errorDeltaSpeed=vLeadDelay-vFollDelay;
    
    a=...
        +Parm.k_v*errorSpeed+...   
        +Parm.k_dv*errorDeltaSpeed;
    
end

function [a,success] = custom(xLeadDelay,vLeadDelay,aLeadDelay,xFollDelay,vFollDelay,aFollDelay,xFoll,vFoll,aFoll,Parm)
    
%     eval(Parm.model);
    
end