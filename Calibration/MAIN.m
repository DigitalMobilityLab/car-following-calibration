%% MAIN

clc
clear all
close all
delete(gcp('nocreate'));


%% Setup

% Configuration
Project='NAPOLI'; % NAPOLI, JIANG, NGSIM, ASTAZERO
Database='Exp';
Setup='setup.txt';
Config='config.txt';
Precision=1e4;
AllVehicleIDs=[1:9]; % NAPOLI: [1:9], JIANG: [101,102,103,104,105,171,263,305,341,416], NGSIM: [607,705,770,797,978,1506,1593,1597,1649,1700,1754,3222], ASTAZERO: [1:8]

% Data
% NAPOLI, JIANG, NGSIM, ASTAZERO
Experiments={'default'};

% Model Configurations
% ModelID 1: IDM
% ModelID 2: Gipps
% ModelID 3: CTH
% ModelID 4: SIGMOID
% ModelID 5: OVM
% ModelID 6: FVDM

% Optimization
textGOFs={...
    'RMSE(S)',...
    'RMSE(V)',...
    'RMSE(A)',...
    'RMSE(stdV)',...
    'RMSPE(S)',...
    'RMSPE(V)',...
    'RMSPE(A)',...
    'RMSPE(stdV)',...
    'MAE(S)',...
    'MAE(V)',...
    'MAE(A)',...
    'MAPE(S)',...
    'MAPE(V)',...
    'MAPE(A)',...
    'U(S)',...
    'U(V)',...
    'U(A)',...
    'RMSPEt(S)',...
    'RMSPEt(V)',...
    'RMSPE(stdV+S)',...
    'NRMSE(V+S)',...
    'RMSPE(V+S)',...
    'MAPE(V+S)',...
    'RMSPEt(V+S)',...
    'U(V+S)',...
    'NRMSE(V+S+A)',...
    'RMSPE(V+S+A)',...
    'MAPE(V+S+A)',...
    'U(V+S+A)',...
};
SpeedCutValue=1;
AccCutValue=0.1;

% Validation
maxSpeedFigure=30;
maxSpacingFigure=40;
maxAccFigure=10;


%% Initialization

fprintf('Initialization...\n');

% Load setup
if exist('Data/setup.txt','file')>0
    fid=fopen('Data/setup.txt');
    setup=textscan(fid,'%s\t%s');
    setup=setup{2};
    fclose(fid);
    clear fid
    clear ans
    Project=setup{1};
    Database=setup{2};
    clear setup
end 
    
% Load config
fid=fopen(sprintf('Data/%s/%s/%s',Project,Database,Config));
config=textscan(fid,'%s\t%s');
config=config{2};
fclose(fid);
clear fid
clear ans

% Parameters
ModelID=str2num(config{1});
VehicleParameter=config{2};
GOFParameter=config{3};
Algo.PopulationSize=str2num(config{4});
Algo.UseParallel=str2num(config{5});
Algo.NumCPUs=str2num(config{6});

fprintf('Initialization done.\n');


%% Analysis

if contains(VehicleParameter,',')==0
    if str2num(VehicleParameter)==0
        VehicleIDs=AllVehicleIDs;
    else
        VehicleIDs=[str2num(VehicleParameter)];
    end
else
    VehicleIDs=str2num(strrep(VehicleParameter,',',' '));
end

if contains(GOFParameter,',')==0
    if str2num(GOFParameter)==0
        GOF_IDs=[1:length(textGOFs)];
    else
        GOF_IDs=[str2num(GOFParameter)];
    end
else
    GOF_IDs=str2num(strrep(GOFParameter,',',' '));
end

for i = 1 : length(VehicleIDs)

    % Assignment
    Parm.precision=Precision;
    Parm.model_id=ModelID;
    Parm.vehicle_id=VehicleIDs(i);
    Parm.speed_cut_value=SpeedCutValue;
    Parm.acc_cut_value=AccCutValue;
    
    % Create Main Folders to store Results
    [~, ~]=mkdir(sprintf('Results/%s/%s/Model %li/VehicleID %li/Figures',Project,Database,Parm.model_id,Parm.vehicle_id));

    % Processing
    for j = 1 : length(GOF_IDs)
        
        ID_GOF=GOF_IDs(j);
    
        % Optimization
        for s = 1 : length(Experiments)
            [x,obj]=Optimization(Project,Database,{Experiments{s}},s,ID_GOF,Algo,Parm);
            Name=sprintf('Results/%s/%s/Model %li/VehicleID %li/Calibration_Report_Exp_%li_%s.txt',Project,Database,Parm.model_id,Parm.vehicle_id,s,char(textGOFs(ID_GOF)));
            fid=fopen(Name,'w');
            fprintf(fid,'%10.5f\t',x);
            fprintf(fid,'%10.10f\t',obj);
            fprintf(fid,'\n');
            fclose(fid);
            clear fid
            clear Name
            clear x obj
        end
        clear s

        % Simulation
        fprintf('Simulations: Started...\n');
        for s = 1 : length(Experiments)

            % Parameters
            x=load(sprintf('Results/%s/%s/Model %li/VehicleID %li/Calibration_Report_Exp_%li_%s.txt',Project,Database,Parm.model_id,Parm.vehicle_id,s,char(textGOFs(ID_GOF))));
            x=x(1:end-1);
            Parm=SetupModel(Parm,x);
            clear x

            % Simulations
            Name=sprintf('Results/%s/%s/Model %li/VehicleID %li/Validation_Report_CalExp_%li_%s.txt',Project,Database,Parm.model_id,Parm.vehicle_id,s,char(textGOFs(ID_GOF)));
            fid=fopen(Name,'w');
            for v = 1 : length(Experiments)
                fprintf('ModelID: %li\t',Parm.model_id);
                fprintf('VehicleID: %li\t',Parm.vehicle_id);
                fprintf('GOFID: %li\t',ID_GOF);
                fprintf('CalExpID: %li\t',s);
                fprintf('ValExpID: %li\t',v);
                fprintf('\n');
                [x_real_set,v_real_set,length_lead_set,t_step_data_set]=SetupData(Project,Database,Parm.vehicle_id,{Experiments{v}});
                Parm.l_i_1=length_lead_set{1,1}(1,1);
                Parm.dt=t_step_data_set{1,1}(1,1);
                [x_foll_sim,v_foll_sim,GOFs]=Simulation(...
                    Parm,...
                    struct(...
                        'time',[0:0.1:(length(x_real_set{1,1}(:,1))-1)*0.1]',...
                        'p_p',x_real_set{1,1}(:,1),...
                        'p_f',x_real_set{1,1}(:,2),...
                        'v_p',v_real_set{1,1}(:,1),...
                        'v_f',v_real_set{1,1}(:,2)...
                    )...
                );
                if length(v_foll_sim)==length(v_real_set{1,1}(:,2))
                    Figure=figure('visible','off');
                    subplot(3,1,1);
                    hold all
                    plot([0:0.1:(length(x_real_set{1,1}(:,1))-1)*0.1]',v_real_set{1,1}(:,1),'k');
                    plot([0:0.1:(length(x_real_set{1,1}(:,1))-1)*0.1]',v_real_set{1,1}(:,2),'b');
                    plot([0:0.1:(length(x_real_set{1,1}(:,1))-1)*0.1]',v_foll_sim,'r');
                    hold off
                    xlim([0 (length(x_real_set{1,1}(:,1))-1)*0.1]);
                    ylim([0 maxSpeedFigure]);
                    xlabel('Time [s]');
                    ylabel('Speed [m/s]');
                    subplot(3,1,2);
                    hold all
                    plot([0:0.1:(length(x_real_set{1,1}(:,1))-1)*0.1]',x_real_set{1,1}(:,1)-x_real_set{1,1}(:,2)-Parm.l_i_1,'b');
                    plot([0:0.1:(length(x_real_set{1,1}(:,1))-1)*0.1]',x_real_set{1,1}(:,1)-x_foll_sim-Parm.l_i_1,'r');
                    hold off
                    xlim([0 (length(x_real_set{1,1}(:,1))-1)*0.1]);
                    ylim([0 maxSpacingFigure]);
                    xlabel('Time [s]');
                    ylabel('Net spacing [m]');
                    subplot(3,1,3);
                    hold all
                    plot([0:0.1:(length(x_real_set{1,1}(:,1))-1)*0.1]',[diff(v_real_set{1,1}(:,2))/0.1;0],'b');
                    plot([0:0.1:(length(x_real_set{1,1}(:,1))-1)*0.1]',[diff(v_foll_sim/0.1);0],'r');
                    hold off
                    xlim([0 (length(x_real_set{1,1}(:,1))-1)*0.1]);
                    ylim([-maxAccFigure maxAccFigure]);
                    xlabel('Time [s]');
                    ylabel('Acceleration [m/s^2]');
                    saveas(...
                        Figure,...
                        sprintf('Results/%s/%s/Model %li/VehicleID %li/Figures/Simulation_CalExp_%li_ValExp_%li_%s.jpg',Project,Database,Parm.model_id,Parm.vehicle_id,s,v,char(textGOFs(ID_GOF)))...
                    );
                    saveas(...
                        Figure,...
                        sprintf('Results/%s/%s/Model %li/VehicleID %li/Figures/Simulation_CalExp_%li_ValExp_%li_%s.fig',Project,Database,Parm.model_id,Parm.vehicle_id,s,v,char(textGOFs(ID_GOF)))...
                    );
                    close(Figure);
                end
                fprintf(fid,'%s\t%',Experiments{v});
                for k = 1 : length(GOFs)
                    fprintf(fid,'%10.10f\t',GOFs(k));
                end
                clear k
                if v<length(Experiments)
                    fprintf(fid,'\n');
                end
                clear x_foll_sim v_foll_sim GOFs
                clear x_real_set v_real_set length_lead_set t_step_data_set
            end
            clear v
            fclose(fid);
            clear fid
            clear ans
            clear Name

        end
        clear s
        fprintf('Simulations: Completed.\n');
        
    end
    clear j

    % Clear Variables
    clear Parm

end
clear i


%% Zip Results

% system('zip -r Results Results');