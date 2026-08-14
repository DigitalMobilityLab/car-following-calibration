%% Function "ImportTrajectoryData"
%
% The script imports leader's and follower's data from .txt files. It
% performs the evaluation of leader's and follower's characteristics.
%%
       
function [x_real,v_real,length_lead,t_step_data]=ImportTrajectoryData(Project,Database,VehicleID,Experiment)
    
    if strcmp(Project,'ASTAZERO')==1
        [x_real,v_real,length_lead,t_step_data]=ImportAstazeroData(Project,Database,VehicleID,Experiment);
    elseif strcmp(Project,'NAPOLI')==1
        [x_real,v_real,length_lead,t_step_data]=ImportNapoliData(Project,Database,VehicleID,Experiment);
    elseif strcmp(Project,'JIANG')==1
        [x_real,v_real,length_lead,t_step_data]=ImportJiangData(Project,Database,VehicleID,Experiment);
    elseif strcmp(Project,'NGSIM')==1
        [x_real,v_real,length_lead,t_step_data]=ImportNgsimData(Project,Database,VehicleID,Experiment);
    end
    
end

function [x_real,v_real,length_lead,t_step_data]=ImportAstazeroData(Project,Database,VehicleID,Experiment)

%     % Import data
%     [labelsNumData,labelsTextData]=xlsread(sprintf('Data/%s/%s/Data.xlsx',Project,Database),'Labels');
%     labelsTextData=labelsTextData(2:end,1);
%     experimentData=xlsread(sprintf('Data/%s/%s/Data.xlsx',Project,Database),Experiment);
%     
%     % Sample rate
%     t_step_data=experimentData(2,1)-experimentData(1,1);
%     
%     % Leader and follower vehicle index
%     leadIndex=0;
%     follIndex=0;
%     length_lead=0;
%     for i = 1 : length(labelsTextData)
%         if strcmp(labelsTextData{i},Experiment)==1
%             follIndex=find(labelsNumData(i,1:5)==VehicleID);
%             leadIndex=follIndex-1;
%             length_lead=labelsNumData(i,15+leadIndex);
%             break;
%         end
%     end
%     clear i
%     
%     % Duration of trajectories
%     K=size(experimentData,1);
%     
%     % Pre-processing
% %     x_pre=zeros(K,2);
% %     for k = 1 : K
% %         if k==1
% %             x_pre(k,1)=experimentData(k,1+(leadIndex-1)*3+1);
% %             x_pre(k,2)=experimentData(k,1+(follIndex-1)*3+1);
% %         else
% %             distanceLead=experimentData(k,1+(leadIndex-1)*3+1)-experimentData(k-1,1+(leadIndex-1)*3+1);
% %             if distanceLead<0
% %                 distanceLead=5757.90385+distanceLead;
% %             end
% %             x_pre(k,1)=x_pre(k-1,1)+distanceLead;
% %             distanceFoll=experimentData(k,1+(follIndex-1)*3+1)-experimentData(k-1,1+(follIndex-1)*3+1);
% %             if distanceFoll<0
% %                 distanceFoll=5757.90385+distanceFoll;
% %             end
% %             x_pre(k,2)=x_pre(k-1,2)+distanceFoll;
% %         end
% %     end
% %     clear k
% %     v_real=[...
% %         [experimentData(1,1+(leadIndex-1)*3+2);diff(x_pre(:,1))/t_step_data],...
% %         [experimentData(1,1+(follIndex-1)*3+2);diff(x_pre(:,2))/t_step_data],...
% %     ];
%     v_real=[experimentData(:,1+(leadIndex-1)*3+2),experimentData(:,1+(follIndex-1)*3+2)];
% 
%     % Evaluation of leader's and follower's characteristics
%     x_real=zeros(K,2);    
%     for k = 1 : K
%         if k==1
%             x_real(k,1)=experimentData(k,1+(leadIndex-1)*3+1);
%             x_real(k,2)=experimentData(k,1+(follIndex-1)*3+1);
%         else
%             x_real(k,1)=x_real(k-1,1)+((v_real(k-1,1)+v_real(k,1))/2)*t_step_data;
%             x_real(k,2)=x_real(k-1,2)+((v_real(k-1,2)+v_real(k,2))/2)*t_step_data;
%         end
%     end
%     clear k

    % Import data
    experimentData=load(sprintf('Data/%s/%s/dataVehicles/dataVehicle%li.txt',Project,Database,VehicleID));
    
    t_step_data=0.1;
    x_real=experimentData(:,2:3);
    v_real=experimentData(:,4:5);
    length_lead=experimentData(1,6);

end

function [x_real,v_real,length_lead,t_step_data]=ImportNapoliData(Project,Database,VehicleID,Experiment)

%     Experiments={...
%         'Napoli_30_10_02_PrA_UrbanaCorta',...
%         'Napoli_30_10_02_PrB_Extraurbana',...
%         'Napoli_30_10_02_PrC_UrbanaLunga'...
%     };
%     % Import data
%     [labelsNumData,labelsTextData]=xlsread(sprintf('Data/%s/%s/Data.xlsx',Project,Database),'Labels');
%     labelsTextData=labelsTextData(2:end,1);
%     experimentData=xlsread(sprintf('Data/%s/%s/Data.xlsx',Project,Database),Experiment);
%     
%     % Sample rate
%     t_step_data=experimentData(2,1)-experimentData(1,1);
%     
%     % Leader and follower vehicle index
%     leadIndex=0;
%     follIndex=0;
%     length_lead=0;
%     for i = 1 : length(labelsTextData)
%         if strcmp(labelsTextData{i},Experiment)==1
%             follIndex=find(labelsNumData(i,1:4)==VehicleID);
%             leadIndex=follIndex-1;
%             length_lead=labelsNumData(i,12+leadIndex);
%             break;
%         end
%     end
%     clear i
%    
%     % Duration of trajectories
%     K=size(experimentData,1);
%     
%     % Pre-processing
%     v_real=[experimentData(:,1+(leadIndex-1)*2+2),experimentData(:,1+(follIndex-1)*2+2)];

%     % Evaluation of leader's and follower's characteristics
%     x_real=zeros(K,2);    
%     for k = 1 : K
%         if k==1
%             x_real(k,1)=experimentData(k,1+(leadIndex-1)*2+1);
%             x_real(k,2)=experimentData(k,1+(follIndex-1)*2+1);
%         else
%             x_real(k,1)=x_real(k-1,1)+((v_real(k-1,1)+v_real(k,1))/2)*t_step_data;
%             x_real(k,2)=x_real(k-1,2)+((v_real(k-1,2)+v_real(k,2))/2)*t_step_data;
%         end
%     end
%     clear k

    % Import data
    experimentData=load(sprintf('Data/%s/%s/dataVehicles/dataVehicle%li.txt',Project,Database,VehicleID));
    
    t_step_data=0.1;
    x_real=experimentData(:,2:3);
    v_real=experimentData(:,4:5);
    length_lead=experimentData(1,6);
    
end

function [x_real,v_real,length_lead,t_step_data]=ImportJiangData(Project,Database,VehicleID,Experiment)

    % Import data
    experimentData=load(sprintf('Data/%s/%s/dataVehicles/dataVehicle%li.txt',Project,Database,VehicleID));
    
    t_step_data=0.1;
    x_real=experimentData(:,2:3);
    v_real=experimentData(:,4:5);
    length_lead=experimentData(1,6);
    
end

function [x_real,v_real,length_lead,t_step_data]=ImportNgsimData(Project,Database,VehicleID,Experiment)

    % Import data
    experimentData=load(sprintf('Data/%s/%s/dataVehicles/Vehicle_%li.txt',Project,Database,VehicleID));
    
    t_step_data=0.1;
    x_real=experimentData(:,[3,10]);
    v_real=experimentData(:,[4,11]);
    length_lead=experimentData(1,6);
    
end