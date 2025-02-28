#===============================================================================================================
# 
# Coarse-Grained QCT for Atmospheric Mixtures (CoarseAIR) 
# 
# Copyright (C) 2018 Simone Venturi and Bruno Lopez (University of Illinois at Urbana-Champaign). 
#
# Based on "VVTC" (Vectorized Variable stepsize Trajectory Code) by David Schwenke (NASA Ames Research Center). 
# 
# This program is free software; you can redistribute it and/or modify it under the terms of the 
# Version 2.1 GNU Lesser General Public License as published by the Free Software Foundation. 
# 
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
# See the GNU Lesser General Public License for more details. 
# 
# You should have received a copy of the GNU Lesser General Public License along with this library; 
# if not, write to the Free Software Foundation, Inc. 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA 
# 
#---------------------------------------------------------------------------------------------------------------
#===============================================================================================================


# ------------------------------------------------------------------------------------------------------------ MergeTrajectories #
function MergeTrajectories {
  # Ex: MergeTrajectories 1 10000.0 10000.0 1 0 1 9390 9390 0 0 0 1 ${COARSEAIR_SOURCE_DIR} 200000
  # Ex: MergeTrajectories 1 20000.0 20000.0 2 1 1 54 54 1 54 54 1 ${COARSEAIR_SOURCE_DIR} 200000


  export COARSEAIR_OUTPUT_DIR=$(pwd)/Test
  export TranFlg=${1}
  export Tran=${2}
  export Tint=${3}
  export NMolecules=${4}
  export SymmFlg=${5}
  export MinLevel1=${6}
  export MaxLevel1=${7}
  export NLevels1=${8}
  export MinLevel2=${9}
  export MaxLevel2=${10}
  export NLevels2=${11}
  export RmTrajFlg=${12}
  export COARSEAIR_SOURCE_DIR=${13}
  export MinNTraj=${14}
  export COARSEAIR_SH_DIR=${COARSEAIR_SOURCE_DIR}"/scripts/executing"

  echo "[MergeTrajectories]: COARSEAIR_OUTPUT_DIR  = "${COARSEAIR_OUTPUT_DIR}
  echo "[MergeTrajectories]: TranFlg               = "${TranFlg}
  echo "[MergeTrajectories]: Tran                  = "${Tran}
  echo "[MergeTrajectories]: Tint                  = "${Tint}
  echo "[MergeTrajectories]: NMolecules            = "${NMolecules}
  echo "[MergeTrajectories]: SymmFlg               = "${SymmFlg}
  echo "[MergeTrajectories]: MinLevel1             = "${MinLevel1}
  echo "[MergeTrajectories]: MaxLevel1             = "${MaxLevel1}
  echo "[MergeTrajectories]: NLevels1              = "${NLevels1}
  echo "[MergeTrajectories]: MinLevel2             = "${MinLevel2}
  echo "[MergeTrajectories]: MaxLevel2             = "${MaxLevel2}
  echo "[MergeTrajectories]: NLevels2              = "${NLevels2}
  echo "[MergeTrajectories]: RmTrajFlg             = "${RmTrajFlg}
  echo "[MergeTrajectories]: COARSEAIR_SH_DIR      = "${COARSEAIR_SH_DIR}
  echo "[MergeTrajectories]: MinNTraj              = "${MinNTraj}


  iProcessesTot=0
  for (( iLevel1=1; iLevel1<=${NLevels1}; iLevel1++ )); do
    iLevel2Start=0
    MinLevel2Temp=0
    if [ ${NMolecules} -eq 2 ]; then 
      iLevel2Start=1
      MinLevel2Temp=1
    fi
    if [ ${SymmFlg} -eq 1 ]; then
      iLevel2Start=${iLevel1}
      MinLevel2Temp=${MinLevel1}
    fi
    for (( iLevel2=${iLevel2Start}; iLevel2<=${NLevels2}; iLevel2++ )); do
      iProcessesTot=$(( ${iProcessesTot} + 1 ))
      if [ ${iLevel1} -eq ${MinLevel1} ] && [ ${iLevel2} -eq ${MinLevel2Temp} ]; then
        MinProcessInNode=${iProcessesTot}
      fi
      if [ ${iLevel1} -eq ${MaxLevel1} ] && [ ${iLevel2} -eq ${MaxLevel2} ]; then
        MaxProcessInNode=${iProcessesTot}
      fi
    done
  done
  iProcessesTot=0
  for (( iLevel1=1; iLevel1<=${NLevels1}; iLevel1++ )); do
    iLevel2Start=0
    if [ ${NMolecules} -eq 2 ]; then 
      iLevel2Start=1
    fi
    if [ ${SymmFlg} -eq 1 ]; then
      iLevel2Start=${iLevel1}
    fi
    for (( iLevel2=${iLevel2Start}; iLevel2<=${NLevels2}; iLevel2++ )); do
      iProcessesTot=$((iProcessesTot+1))
      if [ ${iProcessesTot} -ge ${MinProcessInNode} ] && [ ${iProcessesTot} -le ${MaxProcessInNode} ]; then

        echo "[MergeTrajectories]: ----- Molecule 1, Level/Bin = " ${iLevel1} " --------------------- "
        echo "[MergeTrajectories]: ------- Molecule 2, Level/Bin = " ${iLevel2} " ------------------- "

    
        if [ ${TranFlg} -eq 0 ]; then 
          export COARSEAIR_BIN_OUTPUT_DIR=${COARSEAIR_OUTPUT_DIR}/"E_"${Tran%.*}"_T_"${Tint%.*}/"Bins_"${iLevel1}"_"${iLevel2}
        else
          export COARSEAIR_BIN_OUTPUT_DIR=${COARSEAIR_OUTPUT_DIR}/"T_"${Tran%.*}"_"${Tint%.*}/"Bins_"${iLevel1}"_"${iLevel2}
        fi


        NTraj=0
        if [ -f ${COARSEAIR_BIN_OUTPUT_DIR}/trajectories.csv ]; then

          echo "[MergeTrajectories]: -----> Trajectories from different Processors already merged."
          NTraj=$(wc -l < ${COARSEAIR_BIN_OUTPUT_DIR}/trajectories.csv)
          NTraj=$((NTraj-1))
          echo ${NTraj} > ${COARSEAIR_BIN_OUTPUT_DIR}/'NConvTraj.dat'
          echo "[MergeTrajectories]: -----> Tot Nb of Converged Trajectories: "${NTraj}

        elif [ -f ${COARSEAIR_BIN_OUTPUT_DIR}/Node_1/Proc_1/trajectories.csv ]; then

          #iNode=1
          #while [ ${iNode} -le ${NNode} ]; do
          #  echo "    [MergeTrajectories]: Merging for iNode = "${iNode}

            iProc=1
            while [ $iProc -le ${NProc} ]; do  
              echo "[MergeTrajectories]: -----> Merging for iProc = "${iProc}
                          
              if [ -f ${COARSEAIR_BIN_OUTPUT_DIR}/trajectories.csv ]; then
            
                tail -n+2 ${COARSEAIR_BIN_OUTPUT_DIR}/Node_$iNode/Proc_$iProc/trajectories.csv >> ${COARSEAIR_BIN_OUTPUT_DIR}/trajectories.csv
                if [ -f ${COARSEAIR_BIN_OUTPUT_DIR}/Node_$iNode/Proc_$iProc/PaQSOl.out ]; then
                  tail -n+2 ${COARSEAIR_BIN_OUTPUT_DIR}/Node_$iNode/Proc_$iProc/PaQSOl.out >> ${COARSEAIR_BIN_OUTPUT_DIR}/PaQSOl.out
                  rm -rf ${COARSEAIR_BIN_OUTPUT_DIR}/Node_$iNode/Proc_$iProc/PaQSOl.out
                fi
                
              else
              
                cat ${COARSEAIR_BIN_OUTPUT_DIR}/Node_${iNode}/Proc_${iProc}/trajectories.csv > ${COARSEAIR_BIN_OUTPUT_DIR}/trajectories.csv
                if [ -f ${COARSEAIR_BIN_OUTPUT_DIR}/Node_$iNode/Proc_$iProc/PaQSOl.out ]; then
                  cat ${COARSEAIR_BIN_OUTPUT_DIR}/Node_$iNode/Proc_$iProc/PaQSOl.out > ${COARSEAIR_BIN_OUTPUT_DIR}/PaQSOl.out
                  rm -rf ${COARSEAIR_BIN_OUTPUT_DIR}/Node_$iNode/Proc_$iProc/PaQSOl.out
                fi
                
              fi
              
              #rm -rf ${COARSEAIR_BIN_OUTPUT_DIR}Node_$iNode/Proc_$iProc/trajectories.csv
              
              iProc=$((iProc+1))
            done

            if [ ${RmTrajFlg} -eq 1 ]; then
              rm -rf ${COARSEAIR_BIN_OUTPUT_DIR}/Node_$iNode
              echo "[MergeTrajectories]: -----> Done with merging Trajectories. Now I will remove the Node Folder"
            fi
            
          #iNode=$((iNode+1))
          #done
              
          if [ -f ${COARSEAIR_BIN_OUTPUT_DIR}/trajectories.csv ]; then
            NTraj=$(wc -l < ${COARSEAIR_BIN_OUTPUT_DIR}/trajectories.csv)
            NTraj=$((NTraj-1))
          else 
            NTraj=0
          fi
          echo ${NTraj} > ${COARSEAIR_BIN_OUTPUT_DIR}/'NConvTraj.dat'
          echo "[MergeTrajectories]: -----> Tot Nb of Converged Trajectories: "${NTraj}

        else

          echo "[MergeTrajectories]: -----> No Trajectories Found. Nb of Trajectories = "${NTraj}

        fi


        echo "[MergeTrajectories]: ---------------------------------------------------------- "
        echo "[MergeTrajectories]: ------------------------------------------------------------ "
        echo " "
      fi


    done
  done

  cd  ${COARSEAIR_OUTPUT_DIR}/../

}
#================================================================================================================================#
#================================================================================================================================#


# ------------------------------------------------------------------------------------------------------------ MergeTrajectories #
function CheckTrajectories {
  # Ex: CheckTrajectories 1 10000.0 10000.0 1 0 1 9390 9390 0 0 0 1 ${COARSEAIR_SOURCE_DIR} 200000
  # Ex: CheckTrajectories 1 20000.0 20000.0 2 1 1 61 61 1 61 61 1 ${COARSEAIR_SOURCE_DIR} 200000


  export COARSEAIR_OUTPUT_DIR=$(pwd)/Test
  export TranFlg=${1}
  export Tran=${2}
  export Tint=${3}
  export NMolecules=${4}
  export SymmFlg=${5}
  export MinLevel1=${6}
  export MaxLevel1=${7}
  export NLevels1=${8}
  export MinLevel2=${9}
  export MaxLevel2=${10}
  export NLevels2=${11}
  export RmTrajFlg=${12}
  export COARSEAIR_SOURCE_DIR=${13}
  export MinNTraj=${14}
  export COARSEAIR_SH_DIR=${COARSEAIR_SOURCE_DIR}"/scripts/executing"

  echo "[CheckTrajectories]: COARSEAIR_OUTPUT_DIR  = "${COARSEAIR_OUTPUT_DIR}
  echo "[CheckTrajectories]: TranFlg               = "${TranFlg}
  echo "[CheckTrajectories]: Tran                  = "${Tran}
  echo "[CheckTrajectories]: Tint                  = "${Tint}
  echo "[CheckTrajectories]: NMolecules            = "${NMolecules}
  echo "[CheckTrajectories]: SymmFlg               = "${SymmFlg}
  echo "[CheckTrajectories]: MinLevel1             = "${MinLevel1}
  echo "[CheckTrajectories]: MaxLevel1             = "${MaxLevel1}
  echo "[CheckTrajectories]: NLevels1              = "${NLevels1}
  echo "[CheckTrajectories]: MinLevel2             = "${MinLevel2}
  echo "[CheckTrajectories]: MaxLevel2             = "${MaxLevel2}
  echo "[CheckTrajectories]: NLevels2              = "${NLevels2}
  echo "[CheckTrajectories]: RmTrajFlg             = "${RmTrajFlg}
  echo "[CheckTrajectories]: COARSEAIR_SH_DIR      = "${COARSEAIR_SH_DIR}
  echo "[CheckTrajectories]: MinNTraj              = "${MinNTraj}


  iProcessesTot=0
  for (( iLevel1=1; iLevel1<=${NLevels1}; iLevel1++ )); do
    iLevel2Start=0
    MinLevel2Temp=0
    if [ ${NMolecules} -eq 2 ]; then 
      iLevel2Start=1
      MinLevel2Temp=1
    fi
    if [ ${SymmFlg} -eq 1 ]; then
      iLevel2Start=${iLevel1}
      MinLevel2Temp=${MinLevel1}
    fi
    for (( iLevel2=${iLevel2Start}; iLevel2<=${NLevels2}; iLevel2++ )); do
      iProcessesTot=$(( ${iProcessesTot} + 1 ))
      if [ ${iLevel1} -eq ${MinLevel1} ] && [ ${iLevel2} -eq ${MinLevel2Temp} ]; then
        MinProcessInNode=${iProcessesTot}
      fi
      if [ ${iLevel1} -eq ${MaxLevel1} ] && [ ${iLevel2} -eq ${MaxLevel2} ]; then
        MaxProcessInNode=${iProcessesTot}
      fi
    done
  done
  iProcessesTot=0
  for (( iLevel1=1; iLevel1<=${NLevels1}; iLevel1++ )); do
    iLevel2Start=0
    if [ ${NMolecules} -eq 2 ]; then 
      iLevel2Start=1
    fi
    if [ ${SymmFlg} -eq 1 ]; then
      iLevel2Start=${iLevel1}
    fi
    for (( iLevel2=${iLevel2Start}; iLevel2<=${NLevels2}; iLevel2++ )); do
      iProcessesTot=$((iProcessesTot+1))
      if [ ${iProcessesTot} -ge ${MinProcessInNode} ] && [ ${iProcessesTot} -le ${MaxProcessInNode} ]; then

        echo "[CheckTrajectories]: ----- Molecule 1, Level/Bin = " ${iLevel1} " --------------------- "
        echo "[CheckTrajectories]: ------- Molecule 2, Level/Bin = " ${iLevel2} " ------------------- "

    
        if [ ${TranFlg} -eq 0 ]; then 
          export COARSEAIR_BIN_OUTPUT_DIR=${COARSEAIR_OUTPUT_DIR}/"E_"${Tran%.*}"_T_"${Tint%.*}/"Bins_"${iLevel1}"_"${iLevel2}
        else
          export COARSEAIR_BIN_OUTPUT_DIR=${COARSEAIR_OUTPUT_DIR}/"T_"${Tran%.*}"_"${Tint%.*}/"Bins_"${iLevel1}"_"${iLevel2}
        fi


        NTraj=0
        if [ -f ${COARSEAIR_BIN_OUTPUT_DIR}/trajectories.csv ]; then

          echo "[CheckTrajectories]: -----> Trajectories from different Processors already merged."
          NTraj=$(wc -l < ${COARSEAIR_BIN_OUTPUT_DIR}/trajectories.csv)
          NTraj=$((NTraj-1))
          echo ${NTraj} > ${COARSEAIR_BIN_OUTPUT_DIR}/'NConvTraj.dat'
          echo "[CheckTrajectories]: -----> Tot Nb of Converged Trajectories: "${NTraj}

        else

          echo "[CheckTrajectories]: -----> No Trajectories Found. Nb of Trajectories = "${NTraj}

        fi


        if [ ${iLevel1} -eq ${MinLevel1} ] && [ ${iLevel2} -eq ${MinLevel2} ]; then
          echo "#iLevel,jLevel,NTraj" > ${COARSEAIR_OUTPUT_DIR}/'Overall_NConvTraj.csv'
        fi
        echo ${iLevel1}","${iLevel2}","${NTraj} >> ${COARSEAIR_OUTPUT_DIR}/'Overall_NConvTraj.csv'
        

        echo "[CheckTrajectories]: ---------------------------------------------------------- "
        echo "[CheckTrajectories]: ------------------------------------------------------------ "
        echo " "
      fi
 
    done
  done

  cd  ${COARSEAIR_OUTPUT_DIR}/../

  echo "[CheckTrajectories]: Launching Python File "${COARSEAIR_SH_DIR}/../preprocessing/SelectLevelsToRun.py" with Min Number of Computed Trajectories MinNTraj = "${MinNTraj}
  python3 ${COARSEAIR_SH_DIR}/../preprocessing/SelectLevelsToRun.py ${COARSEAIR_OUTPUT_DIR} ${MinNTraj} 1
  echo "[CheckTrajectories]: The List of the Levels to Re-Run is "${COARSEAIR_OUTPUT_DIR}"/ProcessesToRunList.inp"

}
#================================================================================================================================#
#================================================================================================================================#


# ------------------------------------------------------------------------------------------------------------ MergeTrajectories #
function CkeckRates {
  # Ex: CkeckRates 'N3' 1 10000.0 10000.0 1 0 1 9390 9390 0 0 0 ${COARSEAIR_SOURCE_DIR} 
  # Ex: CkeckRates 'N4' 1 20000.0 20000.0 2 1 1 61 61 1 61 61 ${COARSEAIR_SOURCE_DIR}
  # Ex: CkeckRates 'CO2' 1 20000.0 20000.0 1 0 1 13521 13521 0 0 0 ${COARSEAIR_SOURCE_DIR}

  export System=${1}
  export TranFlg=${2}
  export Tran=${3}
  export Tint=${4}
  export NMolecules=${5}
  export SymmFlg=${6}
  export MinLevel1=${7}
  export MaxLevel1=${8}
  export NLevels1=${9}
  export MinLevel2=${10}
  export MaxLevel2=${11}
  export NLevels2=${12}
  export COARSEAIR_SOURCE_DIR=${13}

  export COARSEAIR_OUTPUT_DIR=$(pwd)/Test
  export COARSEAIR_SH_DIR=${COARSEAIR_SOURCE_DIR}"/scripts/preprocessing/"

  echo "[CkeckRates]: System                = "${System}
  echo "[CkeckRates]: TranFlg               = "${TranFlg}
  echo "[CkeckRates]: Tran                  = "${Tran}
  echo "[CkeckRates]: Tint                  = "${Tint}
  echo "[CkeckRates]: NMolecules            = "${NMolecules}
  echo "[CkeckRates]: SymmFlg               = "${SymmFlg}
  echo "[CkeckRates]: MinLevel1             = "${MinLevel1}
  echo "[CkeckRates]: MaxLevel1             = "${MaxLevel1}
  echo "[CkeckRates]: NLevels1              = "${NLevels1}
  echo "[CkeckRates]: MinLevel2             = "${MinLevel2}
  echo "[CkeckRates]: MaxLevel2             = "${MaxLevel2}
  echo "[CkeckRates]: NLevels2              = "${NLevels2}
  echo "[CkeckRates]: COARSEAIR_SH_DIR      = "${COARSEAIR_SH_DIR}
  echo "[CkeckRates]: COARSEAIR_OUTPUT_DIR  = "${COARSEAIR_OUTPUT_DIR}


  iProcessesTot=0
  for (( iLevel1=1; iLevel1<=${NLevels1}; iLevel1++ )); do
    iLevel2Start=0
    MinLevel2Temp=0
    if [ ${NMolecules} -eq 2 ]; then 
      iLevel2Start=1
      MinLevel2Temp=1
    fi
    for (( iLevel2=${iLevel2Start}; iLevel2<=${NLevels2}; iLevel2++ )); do
      iProcessesTot=$(( ${iProcessesTot} + 1 ))
      if [ ${iLevel1} -eq ${MinLevel1} ] && [ ${iLevel2} -eq ${MinLevel2Temp} ]; then
        MinProcessInNode=${iProcessesTot}
      fi
      if [ ${iLevel1} -eq ${MaxLevel1} ] && [ ${iLevel2} -eq ${MaxLevel2} ]; then
        MaxProcessInNode=${iProcessesTot}
      fi
    done
  done

  iProcessesTot=0
  for (( iLevel1=1; iLevel1<=${NLevels1}; iLevel1++ )); do
    iLevel2Start=0
    if [ ${NMolecules} -eq 2 ]; then 
      iLevel2Start=1
    fi
    for (( iLevel2=${iLevel2Start}; iLevel2<=${NLevels2}; iLevel2++ )); do
      iProcessesTot=$((iProcessesTot+1))
      TempFlg=1
      if [ ${SymmFlg} -eq 1 ]; then
        if [ ${iLevel2} -lt ${iLevel1} ]; then
          TempFlg=0
        fi
      fi
      if [ ${iProcessesTot} -ge ${MinProcessInNode} ] && [ ${iProcessesTot} -le ${MaxProcessInNode} ] && [ ${TempFlg} -eq 1 ]; then
    
        if [ ${TranFlg} -eq 0 ]; then 
          export RATES_FILE=${COARSEAIR_OUTPUT_DIR}/${System}/"Rates/E_"${Tran%.*}"_T_"${Tint%.*}/"Proc"${iProcessesTot}".csv"
        else
          export RATES_FILE=${COARSEAIR_OUTPUT_DIR}/${System}/"Rates/T_"${Tran%.*}"_"${Tint%.*}/"Proc"${iProcessesTot}".csv"
        fi
        echo "[CkeckRates]: Molecule 1, Level/Bin = " ${iLevel1} "; Molecule 2, Level/Bin = " ${iLevel2} ";  Rates File = "${RATES_FILE}


        NRates=0
        if [ -f ${RATES_FILE} ]; then

          echo "[CkeckRates]: -----> Rates File Found."
          NLines=$(wc -l < ${RATES_FILE})
          NLines=$((NLines-1))
          NRates=$((${NLines} - 5))
          echo "[CkeckRates]: -----> Tot Nb of Rates Found: "${NRates}

        else

          echo "[CkeckRates]: -----> No Rates File Found."

        fi


        if [ ${iLevel1} -eq ${MinLevel1} ] && [ ${iLevel2} -eq ${MinLevel2} ]; then
          echo "#iLevel,jLevel,NRates" > ${COARSEAIR_OUTPUT_DIR}/'Overall_NRates.csv'
        fi
        echo ${iLevel1}","${iLevel2}","${NRates} >> ${COARSEAIR_OUTPUT_DIR}/'Overall_NRates.csv'
        

        echo " "
      fi

    done
  done

  cd  ${COARSEAIR_OUTPUT_DIR}/../

  echo "[CkeckRates]: Launching Python File "${COARSEAIR_SH_DIR}/SelectLevelsToRun.py" with Min Number of Rates MinRates = 1"
  python3 ${COARSEAIR_SH_DIR}/SelectLevelsToRun.py ${COARSEAIR_OUTPUT_DIR} 1 2
  echo "[CkeckRates]: The List of the Levels to Re-Run / Re-PostProcess is "${COARSEAIR_OUTPUT_DIR}"/ProcessesToRunList.inp"

}
#================================================================================================================================#
#================================================================================================================================#



# ------------------------------------------------------------------------------------------------------------------------ Clean #
function Clean {
  # Ex: Clean 1 10000.0 10000.0 1 0 1 9390 9390 0 0 0

  export COARSEAIR_OUTPUT_DIR=$(pwd)/Test
  export TranFlg=${1}
  export Tran=${2}
  export Tint=${3}
  export NMolecules=${4}
  export SymmFlg=${5}
  export MinLevel1=${6}
  export MaxLevel1=${7}
  export NLevels1=${8}
  export MinLevel2=${9}
  export MaxLevel2=${10}
  export NLevels2=${11}

  echo "  [Clean]: COARSEAIR_OUTPUT_DIR  = "${COARSEAIR_OUTPUT_DIR}
  echo "  [Clean]: TranFlg               = "${TranFlg}
  echo "  [Clean]: Tran                  = "${Tran}
  echo "  [Clean]: Tint                  = "${Tint}
  echo "  [Clean]: NMolecules            = "${NMolecules}
  echo "  [Clean]: SymmFlg               = "${SymmFlg}
  echo "  [Clean]: MinLevel1             = "${MinLevel1}
  echo "  [Clean]: MaxLevel1             = "${MaxLevel1}
  echo "  [Clean]: NLevels1              = "${NLevels1}
  echo "  [Clean]: MinLevel2             = "${MinLevel2}
  echo "  [Clean]: MaxLevel2             = "${MaxLevel2}
  echo "  [Clean]: NLevels2              = "${NLevels2}


  iProcessesTot=0
  ExitCond=0
  for (( iLevel1=1; iLevel1<=${NLevels1}; iLevel1++ )); do
    iLevel2Start=0
    if [ ${NMolecules} -eq 2 ]; then 
      iLevel2Start=1
    fi
    if [ ${SymmFlg} -eq 1 ]; then
      iLevel2Start=${iLevel1}
    fi
    for (( iLevel2=${iLevel2Start}; iLevel2<=${NLevels2}; iLevel2++ )); do
      if [ ${iLevel1} -eq ${MinLevel1} ] && [ ${iLevel2} -eq ${MinLevel2} ]; then
        ExitCond=1
      fi
      if [ ${ExitCond} -eq 1 ]; then
        iProcessesTot=$((iProcessesTot+1))
        echo "  [Clean]: ----- Molecule 1, Level/Bin = " ${iLevel1} " --------------------- "
        echo "  [Clean]: ------- Molecule 2, Level/Bin = " ${iLevel2} " ------------------- "
        echo "  [Clean]"

    
        if [ ${TranFlg} -eq 0 ]; then 
          export COARSEAIR_BIN_OUTPUT_DIR=${COARSEAIR_OUTPUT_DIR}/"E_"${Tran%.*}"_T_"${Tint%.*}/"Bins_"${iLevel1}"_"${iLevel2}
        else
          export COARSEAIR_BIN_OUTPUT_DIR=${COARSEAIR_OUTPUT_DIR}/"T_"${Tran%.*}"_"${Tint%.*}/"Bins_"${iLevel1}"_"${iLevel2}
        fi
        echo "  [Clean]:  Removing Files and Folders in "${COARSEAIR_BIN_OUTPUT_DIR}


        if [ -f ${COARSEAIR_BIN_OUTPUT_DIR}/NConvTraj.dat ]; then
          rm -rf ${COARSEAIR_BIN_OUTPUT_DIR}/Node*
          rm -rf ${COARSEAIR_BIN_OUTPUT_DIR}/statistics-*
        fi

        echo "  [Clean]: ---------------------------------------------------------- "
        echo "  [Clean]: ------------------------------------------------------------ "
        echo " "
      fi
      if [ ${iLevel1} -eq ${MaxLevel1} ] && [ ${iLevel2} -eq ${MaxLevel2} ]; then
        ExitCond=2
      fi
    done
  done
      
}
#================================================================================================================================#



# ------------------------------------------------------------------------------------------------------------------------ RmAll #
function RmAll {
  # Ex: RmAll 1 10000.0 10000.0 1 0 1 9390 9390 0 0 0

  export COARSEAIR_OUTPUT_DIR=$(pwd)/Test
  export TranFlg=${1}
  export Tran=${2}
  export Tint=${3}
  export NMolecules=${4}
  export SymmFlg=${5}
  export MinLevel1=${6}
  export MaxLevel1=${7}
  export NLevels1=${8}
  export MinLevel2=${9}
  export MaxLevel2=${10}
  export NLevels2=${11}

  echo "  [RmAll]: COARSEAIR_OUTPUT_DIR  = "${COARSEAIR_OUTPUT_DIR}
  echo "  [RmAll]: TranFlg               = "${TranFlg}
  echo "  [RmAll]: Tran                  = "${Tran}
  echo "  [RmAll]: Tint                  = "${Tint}
  echo "  [RmAll]: NMolecules            = "${NMolecules}
  echo "  [RmAll]: SymmFlg               = "${SymmFlg}
  echo "  [RmAll]: MinLevel1             = "${MinLevel1}
  echo "  [RmAll]: MaxLevel1             = "${MaxLevel1}
  echo "  [RmAll]: NLevels1              = "${NLevels1}
  echo "  [RmAll]: MinLevel2             = "${MinLevel2}
  echo "  [RmAll]: MaxLevel2             = "${MaxLevel2}
  echo "  [RmAll]: NLevels2              = "${NLevels2}


  iProcessesTot=0
  ExitCond=0
  for (( iLevel1=1; iLevel1<=${NLevels1}; iLevel1++ )); do
    iLevel2Start=0
    if [ ${NMolecules} -eq 2 ]; then 
      iLevel2Start=1
    fi
    if [ ${SymmFlg} -eq 1 ]; then
      iLevel2Start=${iLevel1}
    fi
    for (( iLevel2=${iLevel2Start}; iLevel2<=${NLevels2}; iLevel2++ )); do
      if [ ${iLevel1} -eq ${MinLevel1} ] && [ ${iLevel2} -eq ${MinLevel2} ]; then
        ExitCond=1
      fi
      if [ ${ExitCond} -eq 1 ]; then
        iProcessesTot=$((iProcessesTot+1))

        echo "  [RmAll]: ----- Molecule 2, Level/Bin = " ${iLevel2} " --------------------- "
        echo "  [RmAll]"

     
        if [ ${TranFlg} -eq 0 ]; then 
          export COARSEAIR_BIN_OUTPUT_DIR=${COARSEAIR_OUTPUT_DIR}/"E_"${Tran%.*}"_T_"${Tint%.*}/"Bins_"${iLevel1}"_"${iLevel2}
        else
          export COARSEAIR_BIN_OUTPUT_DIR=${COARSEAIR_OUTPUT_DIR}/"T_"${Tran%.*}"_"${Tint%.*}/"Bins_"${iLevel1}"_"${iLevel2}
        fi


        #if [ -f ${COARSEAIR_BIN_OUTPUT_DIR} ]; then
        #  echo ${COARSEAIR_BIN_OUTPUT_DIR}
        rm -rf ${COARSEAIR_BIN_OUTPUT_DIR}
        #fi

        echo "  [RmAll]: ---------------------------------------------------------- "
        echo "  [RmAll]: ------------------------------------------------------------ "
        echo " "
      fi
      if [ ${iLevel1} -eq ${MaxLevel1} ] && [ ${iLevel2} -eq ${MaxLevel2} ]; then
        ExitCond=2
      fi
    done
  done
   
}
#================================================================================================================================#