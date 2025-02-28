function [PopVec, PopOverQ, Pop, NSteps] = ReadPop(iT, QBins)     

    %% (METHOD DEPENDENT)

    global T0_Vec BinnedMolName NBinnedMol NBins DatabasePath OutputPath SystemPath KinMthd

    for iBinnedMol=1:NBinnedMol
        
      % Reading Binned Molecules' Bins Populations
      filename = strcat(OutputPath,'/pop_',BinnedMolName(iBinnedMol,:),'.dat')
      delimiter = ' ';
      startRow = 3;
      formatSpec = '%*s%f%*s%*s%[^\n\r]';
      fileID = fopen(filename,'r');
      dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
      fclose(fileID);
      temp=length(dataArray{:, 1});
      PopVec(1:temp,iBinnedMol) = dataArray{:, 1};
      clearvars delimiter startRow formatSpec fileID dataArray ans;


      iStep = 1;
      iBin  = 1;
      for iVec=1:temp
        if PopVec(iVec,iBinnedMol) ~= iStep
          PopOverQ(iStep,iBin,iBinnedMol) = PopVec(iVec,iBinnedMol);
          Pop(iStep,iBin,iBinnedMol)      = PopVec(iVec,iBinnedMol) .* QBins(iBin,iBinnedMol);
          iBin      = iBin + 1;
        else
          iStep = iStep + 1;
          NBins(iBinnedMol) = iBin-1;
          iBin  = 1;
        end
      end
      NSteps = iStep;
        
    end
    
end