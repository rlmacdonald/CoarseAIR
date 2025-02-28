clc
%close all


P0 = 9940.737d0;
X0 = [0.05d0, 0.95d0];
T0 = 300;
V0 = 1.d0;

iBinnedMol = 1;
iSteps     = 1;
R          = 8.3144598;
iFigure    = 2001


clear Rates
Rates(1:NLevels(iBinnedMol),1:NLevels(iBinnedMol)) = ( RatesMatrix(1:NLevels(iBinnedMol),1:NLevels(iBinnedMol),1) + RatesMatrix(1:NLevels(iBinnedMol),1:NLevels(iBinnedMol),2) )  .* 1.d-6;
DissRates                                          = ProcessesRates(1:NLevels(iBinnedMol),1,1)' .* 1.d-6;


LevToBinFinal = LevToBin(:,iBinnedMol,iSteps);
NbBins        = max(LevToBinFinal);

ExpVec0(1:NLevels(iBinnedMol),iBinnedMol) = exp( - LevelEeV0(1:NLevels(iBinnedMol),iBinnedMol) .* Ue ./ (300.d0 .* UKb) );
Q0(1:NLevels(iBinnedMol),iBinnedMol)      = Levelg(1:NLevels(iBinnedMol),iBinnedMol) .* ExpVec0(1:NLevels(iBinnedMol),iBinnedMol);

ExpVec(1:NLevels(iBinnedMol),iBinnedMol)  = exp( - LevelEeV0(1:NLevels(iBinnedMol),iBinnedMol) .* Ue ./ (T0_Vec(1) .* UKb) );
Q(1:NLevels(iBinnedMol),iBinnedMol)       = Levelg(1:NLevels(iBinnedMol),iBinnedMol) .* ExpVec(1:NLevels(iBinnedMol),iBinnedMol);
QMat                                      = kron(Q,1.d0./Q');  
QEn(1:NLevels(iBinnedMol),iBinnedMol)     = Q(1:NLevels(iBinnedMol),iBinnedMol) .* LevelEeV0(1:NLevels(iBinnedMol),iBinnedMol);

QBin  = zeros(NbBins,1);
QBin0 = zeros(NbBins,1);
EeVBin = zeros(NbBins,1);
for iLevels = 1:NLevels(iBinnedMol)
  QBin(LevToBinFinal(iLevels))   = QBin(LevToBinFinal(iLevels))   + Q(iLevels);
  QBin0(LevToBinFinal(iLevels))  = QBin0(LevToBinFinal(iLevels))  + Q0(iLevels);
  EeVBin(LevToBinFinal(iLevels)) = EeVBin(LevToBinFinal(iLevels)) + QEn(iLevels);
end

BinsRates = zeros(NbBins,NbBins);
for i = 1:size(Rates,1)
  for j = 1:size(Rates,2)
    if LevToBinFinal(i) ~= LevToBinFinal(j)
      if i > j
        BinsRates(LevToBinFinal(i),LevToBinFinal(j)) = BinsRates(LevToBinFinal(i),LevToBinFinal(j)) + (Q(i,iBinnedMol) ./ QBin(LevToBinFinal(i))) .* Rates(i,j);
      else
        BinsRates(LevToBinFinal(i),LevToBinFinal(j)) = BinsRates(LevToBinFinal(i),LevToBinFinal(j)) + (Q(i,iBinnedMol) ./ QBin(LevToBinFinal(i))) .* Rates(j,i) .* QMat(j,i);
      end
    end
  end
end
BinsRates = BinsRates;


n0      = (P0 * V0 / (R * T0)) * AvN;
nO0     = n0 * X0(1);
nCOTot0 = n0 * X0(2);
nCO0    = nCOTot0 .* QBin0 ./ sum(QBin0);

TempStpInstants = StpInstants;
%TempStpInstants =[2:10:2000];
for iSteps = TempStpInstants
  
  B     = BinsRates - diag(diag(BinsRates));
  A     = B' - diag(sum(B,2));
  A     = A .* nO0 .* t(iSteps);
  ExpA  = expm(A);
  nBins = ExpA * nCO0;
  for iLevels = 1:NLevels(iBinnedMol)
    n(iLevels)      = Q(iLevels) .* nBins(LevToBinFinal(iLevels)) ./ QBin(LevToBinFinal(iLevels));
    nOverG(iLevels) = n(iLevels) ./ Levelg(iLevels,iBinnedMol);
  end
  
  C  = sum(DissRates .* n);
  nO = nO0 * exp(C * t(iSteps));
  
  nStSOverG(1:NLevels(iBinnedMol),iSteps) = Pop(iSteps,1:NLevels(iBinnedMol),iBinnedMol)' ./ Levelg(1:NLevels(iBinnedMol),iBinnedMol);
  nStSTot(iSteps)                         = sum( Pop(iSteps,1:NLevels(iBinnedMol),iBinnedMol) );
  eStSTot(iSteps)                         = sum( Pop(iSteps,1:NLevels(iBinnedMol),iBinnedMol)' .* LevelEeV(1:NLevels(iBinnedMol),iBinnedMol) ) ./ nStSTot(iSteps);
  
  nCG(1:NLevels(iBinnedMol),iSteps) = n .* exp( - DissRates .* nO .* t(iSteps) );
  nCGOverG(1,1:NLevels(iBinnedMol)) = nCG(1:NLevels(iBinnedMol),iSteps) ./ Levelg(1:NLevels(iBinnedMol),iBinnedMol);
  nCGTot(iSteps)                    = sum( nCG(1:NLevels(iBinnedMol),iSteps) );
  eCGTot(iSteps)                    = sum( nCG(1:NLevels(iBinnedMol),iSteps) .* LevelEeV(1:NLevels(iBinnedMol),iBinnedMol) ) ./ nStSTot(iSteps);

  figure(iFigure)
  hold on
  scatter(LevelEeV(1:NLevels(iBinnedMol),iBinnedMol),nCGOverG(1:NLevels(iBinnedMol)),20,LevToBin(1:NLevels(iBinnedMol),iBinnedMol,1),'Filled');
  colormap(lines(max(max(max(LevToBin)))))
  cb=colorbar;
  %cb.Ticks = [1, 1.5]; %Create 8 ticks from zero to 1
  %cb.TickLabels = {'1','2'}
  ylab = ylabel(cb, '$Group$');
  ylab.Interpreter = 'latex';
  set(cb,'FontSize',LegendFontSz,'FontName',LegendFontNm,'TickLabelInterpreter','latex');
  hold on
  xt = get(gca, 'XTick');
  set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
  yt = get(gca, 'YTick');
  set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
  str_x = ['Energy [eV]'];
  xlab = xlabel(str_x,'Fontsize',AxisLabelSz,'FontName',AxisLabelNm);
  xlab.Interpreter = 'latex';
  xlim([max(min(LevelEeV(:,iBinnedMol)),MinEvPlot(iBinnedMol)), min(max(LevelEeV(:,iBinnedMol)),MaxEvPlot(iBinnedMol))]); 
  str_y = ['$N_{i} / g_{i} [m^{-3}]$'];
  ylab = ylabel(str_y,'Fontsize',AxisLabelSz,'FontName',AxisLabelNm);
  ylab.Interpreter = 'latex';
  ylim([1.d5, 1.d20]);
  set(gca, 'YScale', 'log')
  iFigure = iFigure + 1;
  
end


figure(iFigure)
hold on
plot(t(TempStpInstants(:)),nStSTot(TempStpInstants(:)),'g');
hold on
plot(t(TempStpInstants(:)),nCGTot(TempStpInstants(:)),'r');
xt = get(gca, 'XTick');
set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
yt = get(gca, 'YTick');
set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
str_x = ['time [s]'];
xlab = xlabel(str_x,'Fontsize',AxisLabelSz,'FontName',AxisLabelNm);
xlab.Interpreter = 'latex';
set(gca, 'XScale', 'log')
%xlim([max(min(LevelEeV(:,iBinnedMol)),MinEvPlot(iBinnedMol)), min(max(LevelEeV(:,iBinnedMol)),MaxEvPlot(iBinnedMol))]); 
str_y = ['$N_{CO}$'];
ylab = ylabel(str_y,'Fontsize',AxisLabelSz,'FontName',AxisLabelNm);
ylab.Interpreter = 'latex';
%ylim([1.d5, 1.d20]);
%set(gca, 'YScale', 'log')
iFigure = iFigure + 1;


figure(iFigure)
hold on
plot(t(TempStpInstants(:)),eStSTot(TempStpInstants(:)),'g');
hold on
plot(t(TempStpInstants(:)),eCGTot(TempStpInstants(:)),'r');
xt = get(gca, 'XTick');
set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
yt = get(gca, 'YTick');
set(gca,'FontSize',AxisFontSz, 'FontName',AxisFontNm,'TickDir','out','TickLabelInterpreter', 'latex');
str_x = ['time [s]'];
xlab = xlabel(str_x,'Fontsize',AxisLabelSz,'FontName',AxisLabelNm);
xlab.Interpreter = 'latex';
set(gca, 'XScale', 'log')
%xlim([max(min(LevelEeV(:,iBinnedMol)),MinEvPlot(iBinnedMol)), min(max(LevelEeV(:,iBinnedMol)),MaxEvPlot(iBinnedMol))]); 
str_y = ['$Energy [eV]$'];
ylab = ylabel(str_y,'Fontsize',AxisLabelSz,'FontName',AxisLabelNm);
ylab.Interpreter = 'latex';
%ylim([1.d5, 1.d20]);
%set(gca, 'YScale', 'log')
iFigure = iFigure + 1;


% 
% FileFormatName = strcat('/Users/sventuri/WORKSPACE/neqplasma_QCT/database_CO2Binned/thermo/CO_Format')
% FileFormatID   = fopen(FileFormatName);
% 
% FileNewName    = strcat('/Users/sventuri/WORKSPACE/neqplasma_QCT/database_CO2Binned/thermo/CO')
% fileNewID      = fopen(FileNewName,'w');
% 
% tline  = fgetl(FileFormatID);
% ttline = strcat(tline,'\n');
% while ischar(tline)
%   fprintf(fileNewID,ttline);
%   tline = fgetl(FileFormatID);
%   ttline = strcat(tline,'\n');
% end
% fclose(FileFormatID);
% 
% fprintf(fileNewID,'NB_ENERGY_LEVELS = %g\n', NbBins);
% for iBin = 1:NbBins
%   fprintf(fileNewID,'%14.8E  %14.8E\n', QBin(iBin), 0.d0);%EeVBin(iBin))
% end
% fclose(fileNewID);  