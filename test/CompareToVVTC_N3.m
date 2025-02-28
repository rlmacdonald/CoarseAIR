clear all
clc
close all


% for iLevel = [1, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000]
%     
%     filename = strcat('./ResultsVVTC_N3/fort.7_',num2str(iLevel));
%     formatSpec = '%16f%15f%15f%15f%15f%15f%15f%15f%[^\n\r]';
%     fileID = fopen(filename,'r');
%     dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string',  'ReturnOnError', false);
%     fclose(fileID);
%     bMax  = dataArray{:, 1};
%     b     = dataArray{:, 2};
%     jqn_i = dataArray{:, 3};
%     vqn_i = dataArray{:, 4};
%     Arr_i = dataArray{:, 5};
%     jqn_f = dataArray{:, 6};
%     vqn_f = dataArray{:, 7};
%     Arr_f = dataArray{:, 8};
%     clearvars filename formatSpec fileID dataArray ans;
%     
%     opts = delimitedTextImportOptions("NumVariables", 10);
%     opts.DataLines = [2, Inf];
%     opts.Delimiter = ",";
%     opts.VariableNames = ["iTraj", "iPES", "bmax", "b_i", "j_i", "v_i", "arr_i", "j_f", "v_f", "arr_f"];
%     opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
%     opts.ExtraColumnsRule = "ignore";
%     opts.EmptyLineRule = "read";
%     tbl = readtable(strcat("../../N3_TEST/Test/T_10000_10000/Bins_",num2str(iLevel),"_0/trajectories.csv"), opts);
%     iTraj = tbl.iTraj;
%     [Sorted, Order] = sort(iTraj);
%     iPES  = tbl.iPES;
%     bMax_NEW  = tbl.bmax(Order);
%     b_NEW     = tbl.b_i(Order);
%     jqn_i_NEW = tbl.j_i(Order);
%     vqn_i_NEW = tbl.v_i(Order);
%     Arr_i_NEW = tbl.arr_i(Order);
%     jqn_f_NEW = tbl.j_f(Order);
%     vqn_f_NEW = tbl.v_f(Order);
%     Arr_f_NEW = tbl.arr_f(Order);
%     clear opts tbl
%     
% %     figure(iLevel)
% %     h1=plot(b, 'k-', 'LineWidth', 2)
% %     hold on
% %     h2=plot(b_NEW, 'r:', 'LineWidth', 4)
% %     legend([h1,h2],'VVTC','CoarseAIR')   
% %     title(strcat('Level', num2str(iLevel) ))
% %     xlabel('Trajectory Nb')
% %     ylabel('Impact Parameter')
% 
%     figure(iLevel+1)
% %     h1=plot(jqn_f, 'k-', 'LineWidth', 2)
% %     hold on
% %     h2=plot(jqn_f_NEW, 'r:', 'LineWidth', 4)
% %     legend([h1,h2],'VVTC','CoarseAIR')   
% %     title(strcat('Level', num2str(iLevel) ))
% %     xlabel('Trajectory Nb')
% %     ylabel('Final J')
%     plot(jqn_f-jqn_f_NEW, 'r-', 'LineWidth', 2)
%     hold on
%     title(strcat('Level', num2str(iLevel) ))
%     xlabel('Trajectory Nb')
%     ylabel('Error in Final J')
%     
%     figure(iLevel+2)
% %     h1=plot(vqn_f, 'k-', 'LineWidth', 2)
% %     hold on
% %     h2=plot(vqn_f_NEW, 'r:', 'LineWidth', 4)
% %     legend([h1,h2],'VVTC','CoarseAIR')   
% %     title(strcat('Level', num2str(iLevel) ))
% %     xlabel('Trajectory Nb')
% %     ylabel('Final v')
%     plot(vqn_f-vqn_f_NEW, 'k-', 'LineWidth', 2)
%     hold on
%     title(strcat('Level', num2str(iLevel) ))
%     xlabel('Trajectory Nb')
%     ylabel('Error in Final v')
%     
%     
%     figure(iLevel+3)
% %     h1=plot(Arr_f, 'k-', 'LineWidth', 2)
% %     hold on
% %     h2=plot(Arr_f_NEW, 'r:', 'LineWidth', 4)
% %     legend([h1,h2],'VVTC','CoarseAIR')   
% %     title(strcat('Level', num2str(iLevel) ))
% %     xlabel('Trajectory Nb')
% %     ylabel('Final Arrangement')
%     plot(Arr_f-Arr_f_NEW, 'k-', 'LineWidth', 2)
%     hold on
%     title(strcat('Level', num2str(iLevel) ))
%     xlabel('Trajectory Nb')
%     ylabel('Error in Final Arrangement')
%     
% end


opts = delimitedTextImportOptions("NumVariables", 6);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["Var1", "vqn", "jqn", "Var4", "Var5", "Var6"];
opts.SelectedVariableNames = ["vqn", "jqn"];
opts.VariableTypes = ["string", "double", "double", "string", "string", "string"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts = setvaropts(opts, ["Var1", "Var4", "Var5", "Var6"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Var1", "Var4", "Var5", "Var6"], "EmptyFieldRule", "auto");
QNsEnBin = readtable("/home/venturi/WORKSPACE/CoarseAIR/N3_TEST/Test/NaNbNc/NaNb/Bins_9390/QNsEnBin.csv", opts);
clear opts
Levelvqn   = QNsEnBin.vqn;
Leveljqn   = QNsEnBin.jqn;
NLevels    = length(Leveljqn);
QNsToLevel = zeros(max(Leveljqn)+1,max(Levelvqn)+1);
for iLevel=1:NLevels
   QNsToLevel(Leveljqn(iLevel)+1,Levelvqn(iLevel)+1) = iLevel;
end


for iLevel = [1, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000]

    opts = delimitedTextImportOptions("NumVariables", 8);
    opts.DataLines = [21, Inf];
    opts.Delimiter = " ";
    opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8"];
    opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts.ConsecutiveDelimitersRule = "join";
    opts.LeadingDelimitersRule = "ignore";
    tbl = readtable(strcat("./ResultsVVTC_N3/output_",num2str(iLevel),".dat"), opts);
    jqn_f   = tbl.VarName1;
    vqn_f   = tbl.VarName2;
    Arr_f   = tbl.VarName3;
    jqn_i   = tbl.VarName4;
    vqn_i   = tbl.VarName5;
    Arr_i   = tbl.VarName6;
    Cross   = tbl.VarName7;
    CrossSD = tbl.VarName8;
    clear opts tbl
    Diss_f  = 0.0;
    for jLevel=1:length(Cross)
        Level_f(jLevel,1) = QNsToLevel(jqn_f(jLevel)+1,vqn_f(jLevel)+1);
        if (mod(Arr_f(jLevel),16) > 1)
            Diss_f = Diss_f + Cross(jLevel); 
        end
    end
        
    filename = strcat("../../N3_TEST/Test/T_10000_10000/Bins_",num2str(iLevel),"_0/statistics.csv");
    startRow = 2;
    formatSpec = '%6f%8f%8f%8f%8f%8f%18f%f%[^\n\r]';
    fileID = fopen(filename,'r');
    dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    fclose(fileID);
    jqn_f_NEW   = dataArray{:, 1};
    vqn_f_NEW   = dataArray{:, 2};
    Arr_f_NEW   = dataArray{:, 3};
    jqn_i_NEW   = dataArray{:, 4};
    vqn_i_NEW   = dataArray{:, 5};
    Arr_i_NEW   = dataArray{:, 6};
    Cross_NEW   = dataArray{:, 7};
    CrossSD_NEW = dataArray{:, 8};
    clearvars filename startRow formatSpec fileID dataArray ans;
    Diss_f_NEW = 0.0;
    for jLevel=1:length(Cross_NEW)
        Level_f_NEW(jLevel,1) = QNsToLevel(jqn_f_NEW(jLevel)+1,vqn_f_NEW(jLevel)+1);
        if (mod(Arr_f_NEW(jLevel),16) > 1)
            Diss_f_NEW = Diss_f_NEW + Cross_NEW(jLevel); 
        end
    end
    
    figure(iLevel+1)
    h1=plot(Level_f,     Arr_f,     'ko', 'LineWidth', 0.5, 'MarkerSize', 8)
    hold on
    h2=plot(Level_f_NEW, Arr_f_NEW, 'r+', 'LineWidth', 0.5, 'MarkerSize', 8)
    legend([h1,h2],'VVTC','CoarseAIR')   
    title(strcat('Level', num2str(iLevel),'; Diss VVTC = ', num2str(Diss_f), '; Diss CoarseAIR = ', num2str(Diss_f_NEW)))
    xlabel('Final Level')
    ylabel('Final Arrangement')
    
    figure(iLevel+2)
    h1=plot(Level_f,     Cross,     'ko', 'LineWidth', 0.5, 'MarkerSize', 8)
    hold on
    h2=plot(Level_f_NEW, Cross_NEW, 'r+', 'LineWidth', 0.5, 'MarkerSize', 8)
    legend([h1,h2],'VVTC','CoarseAIR')   
    title(strcat('Level', num2str(iLevel),'; Diss VVTC = ', num2str(Diss_f), '; Diss CoarseAIR = ', num2str(Diss_f_NEW)))
    xlabel('Final Level')
    ylabel('Cross Section [cm^2]')
    
    clear Level_f Level_f_NEW
    
end