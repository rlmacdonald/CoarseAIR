%% Computing Turning Points for the Diatomic Potential's Level
%
function [rLx, rRx] = TurningPoints( ExtLx, ExtRx, EInt, jqn, iMol )

    %%==============================================================================================================
    % 
    % Coarse-Grained method for Quasi-Classical Trajectories (CG-QCT) 
    % 
    % Copyright (C) 2018 Simone Venturi and Bruno Lopez (University of Illinois at Urbana-Champaign). 
    %
    % Based on "VVTC" (Vectorized Variable stepsize Trajectory Code) by David Schwenke (NASA Ames Research Center). 
    % 
    % This program is free software; you can redistribute it and/or modify it under the terms of the 
    % Version 2.1 GNU Lesser General Public License as published by the Free Software Foundation. 
    % 
    % This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
    % without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
    % See the GNU Lesser General Public License for more details. 
    % 
    % You should have received a copy of the GNU Lesser General Public License along with this library; 
    % if not, write to the Free Software Foundation, Inc. 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA 
    % 
    %---------------------------------------------------------------------------------------------------------------
    %%==============================================================================================================

    global Syst Param

    jqnreal = jqn+0.0;
    
    rLx     = fzero(@(x) DiatPotShift(x, jqnreal, iMol, EInt), ExtLx);
    %VTest1 = DiatPot(rLx, jqn, iMol);

    rRx     = fzero(@(x) DiatPotShift(x, jqnreal, iMol, EInt), ExtRx);
    %VTest2 = DiatPot(rRx, jqn, iMol);
      
end