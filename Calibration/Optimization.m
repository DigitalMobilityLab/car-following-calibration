%% Function "Optimization"
%
% The function performs the calibration of the car-following model using 
% the GA.
%
%%

function [val fval]=Optimization(Project,Database,Experiments,ID_Exp,ID_GOF,Algo,Parm)
    
    % Setup custom model
    fprintf('Optimization: Setup custom model implementation...');
    ModelClass=Parm.model_id;
    if isfile(sprintf('Data/%s/%s/Bounds/Model Class %li/model.txt',Project,Database,ModelClass))==1
        fid=fopen(sprintf('Data/%s/%s/Bounds/Model Class %li/model.txt',Project,Database,ModelClass));
        model=textscan(fid,'%s','Whitespace','');
        Parm.model=model{1}{1};
        fclose(fid);
        clear fid
        clear ans model ModelClass
    else
        Parm.model='';
    end
    fprintf(' done.\n');
    
    % Setup bounds
    fprintf('Optimization: Setup bounds...');
    LB=[];
    UB=[];
    ModelClass=Parm.model_id;
    fid=fopen(sprintf('Data/%s/%s/Bounds/Model Class %li/parameters.txt',Project,Database,ModelClass));
    bounds=textscan(fid,'%s\t%f\t%f');
    fclose(fid);
    clear fid
    clear ans ModelClass
    LB=[LB;bounds{2}];
    UB=[UB;bounds{3}];
    clear bounds
    fprintf(' done.\n');
    
    % Setup data
    fprintf('Optimization: Setup experiment data...');
    [x_real_set,v_real_set,length_lead_set,t_step_data_set]=SetupData(Project,Database,Parm.vehicle_id,Experiments);
    fprintf(' done.\n');
    
    % Algorithm Options
    PopulationSize=Algo.PopulationSize;
    maxIterationNumber=10000;
    StallGenLimit=100;
    UseParallel=logical(Algo.UseParallel);
    TolFun=1e-4;
    Display='off';

    options = gaoptimset('PopulationSize',PopulationSize,...
                         'Generations',maxIterationNumber,...
                         'StallGenLimit',StallGenLimit,...
                         'UseParallel',UseParallel,...
                         'TolFun',TolFun,...
                         'Display',Display);
    
    % Start clock
    startClock=tic;
    
    % Optimization
    fprintf('Optimization: Started...\n');
    f = @(x)ObjFuncValue(x_real_set,v_real_set,length_lead_set,t_step_data_set,ID_Exp,ID_GOF,Parm,x);
    if UseParallel
        parpool(Algo.NumCPUs);
    end
    [val fval]=ga(f,length(LB),[],[],[],[],LB,UB,[],options);
    for i = 1 : length(val)
        val(i)=round(val(i)*Parm.precision)/Parm.precision;
    end
    clear i
    fprintf('Optimization: Completed.\n');
    
    % End clock
    endClock=toc(startClock);

    % Save log
    fid=fopen('log.txt','a');
    fprintf(fid,'ModelID: %li\t',Parm.model_id);
    fprintf(fid,'VehicleID: %li\t',Parm.vehicle_id);
    fprintf(fid,'GOFID: %li\t',ID_GOF);
    fprintf(fid,'ExpID: %li\t',ID_Exp);
    fprintf(fid,'Time: %.0f min.\n',endClock/60);
    fclose(fid);
    clear fid
    clear ans
    clear endClock
        
end