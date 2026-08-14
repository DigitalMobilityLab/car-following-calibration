%% MAIN

clc
clear all
close all


%% Setup

Project='NGSIM';
Database='Exp';
Folder='Stored/Results 1';
ModelIDs=[1,2,3,4];
% TotExperiments={...
%     'ASta_040719_platoon5',...
%     'ASta_040719_platoon6',...
%     'ASta_040719_platoon9',...
%     'ASta_050719_platoon1',...
%     'ASta_040719_platoon7',...
%     'ASta_040719_platoon8',...
%     'ASta_050719_platoon2'...
% };
% TotExperiments={...
%     'Napoli_30_10_02_PrA_UrbanaCorta',...
%     'Napoli_30_10_02_PrB_Extraurbana',...
%     'Napoli_30_10_02_PrC_UrbanaLunga'...
% };
TotExperiments={'default'};
VehicleIDs=[607,705,770,797,978,1506,1593,1597,1649,1700,1754,3222]; % NAPOLI: [1:9], NGSIM: [607,705,770,797,978,1506,1593,1597,1649,1700,1754,3222], JIANG: [101,102,103,104,105,171,263,305,341,416], ASTAZERO: [1:8]
textGOFs={...
    'RMSE(S)',...           % 1
    'RMSE(V)',...           % 2
    'RMSE(A)',...           % 3
    'RMSE(stdV)',...        % 4
    'RMSPE(S)',...          % 5
    'RMSPE(V)',...          % 6
    'RMSPE(A)',...          % 7
    'RMSPE(stdV)',...       % 8
    'MAE(S)',...            % 9
    'MAE(V)',...            % 10
    'MAE(A)',...            % 11
    'MAPE(S)',...           % 12
    'MAPE(V)',...           % 13
    'MAPE(A)',...           % 14
    'U(S)',...              % 15
    'U(V)',...              % 16
    'U(A)',...              % 17
    'RMSPEt(S)',...         % 18
    'RMSPEt(V)',...         % 19
    'RMSPE(stdV+S)',...     % 20
    'NRMSE(V+S)',...        % 21
    'RMSPE(V+S)',...        % 22
    'MAPE(V+S)',...         % 23
    'RMSPEt(V+S)',...       % 24
    'U(V+S)',...            % 25
    'NRMSE(V+S+A)',...      % 26
    'RMSPE(V+S+A)',...      % 27
    'MAPE(V+S+A)',...       % 28
    'U(V+S+A)',...          % 29
};
legendTextGOFs=cell(length(textGOFs),1);
for i = 1 : length(textGOFs)
    legendTextGOFs{i}=[num2str(i),': ',textGOFs{i}];
end
clear i
SortedCalGOFIDs=[1:length(textGOFs)];
ValGOFIDs=[1,2,3];


%% Processing

SameExpResults=cell(length(TotExperiments),length(ModelIDs));
SameExpRatioResults=cell(length(TotExperiments),length(ModelIDs));
for i = 1 : length(ModelIDs)
    for n = 1 : length(TotExperiments)
        SameExpObjFuncValues=cell(length(VehicleIDs),1);
        for k = 1 : length(SortedCalGOFIDs)
            for j = 1 : length(VehicleIDs)
                data=importdata(sprintf('Results/%s/%s/%s/Model %li/VehicleID %li/Validation_Report_CalExp_%li_%s.txt',Project,Database,Folder,ModelIDs(i),VehicleIDs(j),n,textGOFs{SortedCalGOFIDs(k)}));
                data=data.data;
                SameExpObjFuncValues{j,1}=[SameExpObjFuncValues{j,1};data(n,ValGOFIDs)];
                clear data
            end
            clear j
        end
        clear k
        SameExpResults{n,i}=SameExpObjFuncValues;
        clear SameExpObjFuncValues
        for j = 1 : length(VehicleIDs)
            for m = 1 : length(ValGOFIDs)
                SameExpRatioResults{n,i}{j,1}(:,m)=(SameExpResults{n,i}{j,1}(:,m)-SameExpResults{n,i}{j,1}(ValGOFIDs(m),m))/SameExpResults{n,i}{j,1}(ValGOFIDs(m),m);
            end
            clear m
        end
        clear j
    end
    clear n
end
clear i

StatsValues=cell(1,length(ModelIDs));
StatsRatioValues=cell(1,length(ModelIDs));
for i = 1 : length(ModelIDs)
    StatsValues{i}=cell(length(SortedCalGOFIDs),length(ValGOFIDs));
    StatsRatioValues{i}=cell(length(SortedCalGOFIDs),length(ValGOFIDs));
    for n = 1 : length(TotExperiments)
        for j = 1 : length(VehicleIDs)
            for k = 1 : length(SortedCalGOFIDs)
                for m = 1 : length(ValGOFIDs)
                    StatsValues{i}{k,m}=[StatsValues{i}{k,m};SameExpResults{n,i}{j,1}(k,m)];
                    StatsRatioValues{i}{k,m}=[StatsRatioValues{i}{k,m};SameExpRatioResults{n,i}{j,1}(k,m)];
                end
                clear m
            end
            clear k
        end
        clear j
    end
    clear n
end
clear i

Stats.Mean=cell(1,length(ModelIDs));
Stats.Std=cell(1,length(ModelIDs));
Stats.Median=cell(1,length(ModelIDs));
StatsRatio.Mean=cell(1,length(ModelIDs));
StatsRatio.Std=cell(1,length(ModelIDs));
StatsRatio.Median=cell(1,length(ModelIDs));
for i = 1 : length(ModelIDs)
    Stats.Mean{i}=ones(length(SortedCalGOFIDs),length(ValGOFIDs))*NaN;
    Stats.Std{i}=ones(length(SortedCalGOFIDs),length(ValGOFIDs))*NaN;
    Stats.Median{i}=ones(length(SortedCalGOFIDs),length(ValGOFIDs))*NaN;
    StatsRatio.Mean{i}=ones(length(SortedCalGOFIDs),length(ValGOFIDs))*NaN;
    StatsRatio.Std{i}=ones(length(SortedCalGOFIDs),length(ValGOFIDs))*NaN;
    StatsRatio.Median{i}=ones(length(SortedCalGOFIDs),length(ValGOFIDs))*NaN;
    for k = 1 : length(SortedCalGOFIDs)
        for m = 1 : length(ValGOFIDs)
            Stats.Mean{i}(k,m)=mean(StatsValues{i}{k,m});
            Stats.Std{i}(k,m)=std(StatsValues{i}{k,m});
            Stats.Median{i}(k,m)=median(StatsValues{i}{k,m});
            StatsRatio.Mean{i}(k,m)=mean(StatsRatioValues{i}{k,m});
            StatsRatio.Std{i}(k,m)=std(StatsRatioValues{i}{k,m});
            StatsRatio.Median{i}(k,m)=median(StatsRatioValues{i}{k,m});
        end
        clear m
    end
    clear k
end
clear i


%% Box plots

% Sorting
% sortedIndex=cell(1,length(ModelIDs));
% for i = 1 : length(ModelIDs)
%     sortedIndexLocal=zeros(length(SortedCalGOFIDs),length(ValGOFIDs));
%     for m = 1 : length(ValGOFIDs)
%         index=[[1:length(SortedCalGOFIDs)]',StatsRatio.Median{i}(:,m)];
%         index=sortrows(index,2);
%         sortedIndexLocal(:,m)=index(:,1);
%         clear index
%     end
%     clear m
%     sortedIndex{i}=sortedIndexLocal;
%     clear sortedIndexLocal
% end
% clear i
% sortedIndex=[...
%     {...
%     [26,29,20,23,24,28,25,27,1,17,11,21,15,9,14,6,5,10,22,12,2,18,3,19,13,4,8,16,7]'
%     }...
%     ,...
%     {...
%     [26,29,23,20,24,1,17,28,25,11,21,27,5,15,9,14,10,22,6,12,18,2,3,13,19,8,4,16,7]'
%     }...
%     ,...
%     {...
%     [29,26,25,21,1,15,24,9,18,22,23,13,6,19,12,5,20,10,16,2,28,27,4,8,17,3,7,14,11]'
%     }...
%     ,...
%     {...
%     [26,29,21,24,25,1,18,9,15,23,22,10,6,16,12,5,2,19,20,13,28,27,4,8,7,14,17,3,11]'
%     }...
% ];
% sortedIndex=[...
%     {...
%     [29,26,25,21,1,15,24,9,18,22,23,13,6,19,12,5,20,10,16,2,28,27,4,8,17,3,7,14,11]'
%     }...
%     ,...
%     {...
%     [26,29,21,24,25,1,18,9,15,23,22,10,6,16,12,5,2,19,20,13,28,27,4,8,7,14,17,3,11]'
%     }...
% ];
sortedIndex=[...
    {...
    [1,21,26,15,9,25,18,29,22,24,5,23,12,20,2,19,16,10,13,6,4,27,8,28,17,11,3,7,14]'
    }...
    ,...
    {...
    [1,21,26,15,9,25,18,29,22,24,5,23,12,20,2,19,16,10,13,6,4,27,8,28,17,11,3,7,14]'
    }...
];

%Plotting
Figure=figure();
count=0;
for m = 1 : length(ValGOFIDs)
    for i = 1 : length(ModelIDs)
        data=zeros(length(TotExperiments)*length(VehicleIDs),length(SortedCalGOFIDs));
        textLabel=cell(length(SortedCalGOFIDs),1);
        for k = 1 : length(SortedCalGOFIDs)
%             textLabel{k}=num2str(sortedIndex{i}(k));
            textLabel{k}=textGOFs{sortedIndex{i}(k)};
            data(:,k)=StatsRatioValues{i}{sortedIndex{i}(k),m}*100;
            index=find(data(:,k)<0);
            if isempty(index)==0
                data(index,k)=0;
            end
            clear index
        end
        clear k
        count=count+1;
        subplot(length(ValGOFIDs),length(ModelIDs),count);
        boxplot(data);
        if m<3
            set(gca,'XTickLabels','');
        else
            set(gca,'XTickLabels',textLabel);
            set(gca,'FontSize',10,'XTickLabelRotation',90);
        end
        clear data textLabel
        ylim([0 100]);
        yticks([0 20 40 60 80 100]);
        yticklabels({'0%','20%','40%','60%','80%','>=100%'});
        if m==1
            if i==1
                title('CTH','FontSize',20,'FontWeight','bold');
%                 legend(findall(gca,'Tag','Box'),legendTextGOFs);
%                 clc
            else
                title('SIGMOID','FontSize',20,'FontWeight','bold');
            end
            ylabel('Spacing','FontSize',14,'FontWeight','bold');
        elseif m==2
            ylabel('Speed','FontSize',14,'FontWeight','bold');
        elseif m==3
            xlabel('GOFs','FontSize',14,'FontWeight','bold');
            ylabel('Acceleration','FontSize',14,'FontWeight','bold');
        end
    end
    clear m
end
clear i
saveas(Figure,sprintf('Results/%s/%s/%s/Boxplot.fig',Project,Database,Folder));