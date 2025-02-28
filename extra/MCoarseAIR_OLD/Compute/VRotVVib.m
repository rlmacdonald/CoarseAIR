function [iFigure, RotEeV, VibEeV] = VRotVVib(iFigure, NLevels, LevelEeV, Leveljqn, Levelvqn, ri, ro, Eint, jqn, iMol, LevToBin)

  global NMolecules MoleculesName AtomMass Pair_to_Atoms SaveFigs FilePath
  
%   mass = [AtomMass(1), AtomMass(2)];
%   mu = mass(1) * mass(2) / ( mass(1) + mass(2) );
%   
%   x = [-0.99810332873704410      -0.99242050967193585      -0.98297309968390190      -0.96979693603500949      -0.95294200042715638      -0.93247222940435570      -0.90846527181952419      -0.88101219428578448      -0.85021713572961366      -0.81619691235622127      -0.77908057452567014      -0.73900891722065920      -0.69613394596292633      -0.65061830020424205      -0.60263463637925585      -0.55236497296050546      -0.49999999999999944      -0.44573835577653764      -0.38978587329267939      -0.33235479947965879      -0.27366299007208256      -0.21393308320649709      -0.15339165487868553       -9.2268359463302030E-002  -3.0795058556170516E-002   3.0795058556170023E-002   9.2268359463301683E-002  0.15339165487868511       0.21393308320649690       0.27366299007208261       0.33235479947965957       0.38978587329267894       0.44573835577653792       0.49999999999999967       0.55236497296050568       0.60263463637925674       0.65061830020424205       0.69613394596292655       0.73900891722065887       0.77908057452567059       0.81619691235622160       0.85021713572961399       0.88101219428578459       0.90846527181952386       0.93247222940435559       0.95294200042715627       0.96979693603500938       0.98297309968390145       0.99242050967193574       0.99810332873704388];    
%   w = [3.7921429501713189E-003   7.5699010032249294E-003   1.1318943828886074E-002   1.5025050023573650E-002   1.8674161057052170E-002   2.2252434601256432E-002   2.5746297038984105E-002   2.9142494953268105E-002   3.2428145402134415E-002   3.5590784788011989E-002   3.8618416136421127E-002   4.1499554604616989E-002   4.4223271047525069E-002   4.6779233475733095E-002   4.9157746248268984E-002   5.1349786851482219E-002   5.3347040124535838E-002   5.5141929801653423E-002   5.6727647251493242E-002   5.8098177304619351E-002   5.9248321071098689E-002   6.0173715661668403E-002   6.0870850737678388E-002   6.1337081826995141E-002   6.1570640355402932E-002   6.1570640355403584E-002   6.1337081826994426E-002   6.0870850737679234E-002   6.0173715661668140E-002   5.9248321071097503E-002   5.8098177304619955E-002   5.6727647251494477E-002   5.5141929801653757E-002   5.3347040124536074E-002   5.1349786851480957E-002   4.9157746248268665E-002   4.6779233475733074E-002   4.4223271047525478E-002   4.1499554604616393E-002   3.8618416136421189E-002   3.5590784788011975E-002   3.2428145402135851E-002   2.9142494953267813E-002   2.5746297038983776E-002   2.2252434601257597E-002   1.8674161057051053E-002   1.5025050023573674E-002   1.1318943828886052E-002   7.5699010032253562E-003   3.7921429501706991E-003];
%   
%   rm      = (ro-ri)*0.5d0;
%   rp      = (ro+ri)*0.5d0 + rm * x(1);
%   ActionV = 0.d0;
%   ActionJ = 0.d0;
%   
%   nu = length(x);
%   for i = 1:nu
%     
%     [VVal, VJVal] = VFun(rp, jqn, Eint, iMol);
%     dajeV  = VVal  * w(i);
%     dajeJ  = VJVal * w(i);
%     
%     ActionV = ActionV + dajeV;
%     ActionJ = ActionJ + dajeJ;
%     
%     if (i~=nu) rp = rp + rm * (x(i+1)-x(i));
%     end 
%   
%   RotEeV = ActionJ * (ro - ri); %Eint - VVib;
%     
%   VibEeV = Eint - ActionV * (ro - ri);

  for iMol = 1:NMolecules

    LevVec = [1:NLevels(iMol)];
    LevVec = [];
    for iLevels = 1:NLevels(iMol)
      if Leveljqn(iLevels,iMol) == 0
        vEeV(Levelvqn(iLevels,iMol)+1,iMol) = LevelEeV(iLevels,iMol);
      end
      RotEeV(iLevels,iMol) = LevelEeV(iLevels,iMol) - vEeV(Levelvqn(iLevels,iMol)+1,iMol);
      VibEeV(iLevels,iMol) = LevelEeV(iLevels,iMol) - RotEeV(iLevels,iMol) - min(LevelEeV(:,iMol));
      if mod(Leveljqn(iLevels,iMol),2) == 0
        LevVec = [LevVec; iLevels];
      end
    end

    figure(iFigure)
    scatter(VibEeV(LevVec(:),iMol),RotEeV(LevVec(:),iMol),20,LevToBin(LevVec(:),iMol))
    xlim([0,15]);
    ylim([0,15]);
    xlabel('Vibrational Energy [eV]')
    ylabel('Rotationa Energy [eV]')
    grid on
    set(gca,'FontSize',20, 'FontName','Palatino','TickDir','out','TickLabelInterpreter', 'latex');
    set(gcf, 'PaperPositionMode', 'auto');
    if SaveFigs == 1
        FileName = strcat(MoleculesName(1,:),'-Dissociation');
        FilePathNamePng = strcat(FilePath, FileName, '.png');
        FilePathNameFig = strcat(FilePath, FileName, '.fig');
        saveas(gcf,strcat(FilePath, FileName),'pdf')
        saveas(gcf,FilePathNamePng)
        savefig(FilePathNameFig);
    end
    iFigure = iFigure + 1;

    figure
    scatter(sqrt(VibEeV(LevVec(:),iMol)),sqrt(RotEeV(LevVec(:),iMol)),20,LevToBin(LevVec(:),iMol))
    xlim([0,4]);
    ylim([0,4]);
    xlabel('sqrt(Vibrational Energy) [eV^(1/2)]')
    ylabel('sqrt(Rotational Energy) [eV^(1/2)]')
    grid on
    set(gca,'FontSize',20, 'FontName','Palatino','TickDir','out','TickLabelInterpreter', 'latex');
    set(gcf, 'PaperPositionMode', 'auto');
    if SaveFigs == 1
        FileName = strcat(MoleculesName(1,:),'-Dissociation');
        FilePathNamePng = strcat(FilePath, FileName, '.png');
        FilePathNameFig = strcat(FilePath, FileName, '.fig');
        saveas(gcf,strcat(FilePath, FileName),'pdf')
        saveas(gcf,FilePathNamePng)
        savefig(FilePathNameFig);
    end
    iFigure = iFigure + 1;
    
  end

end