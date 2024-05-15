#!/bin/bash
#SBATCH --job-name=cac
#SBATCH --account=fc_control
#SBATCH --partition=savio4_htc
#SBATCH --cpus-per-task=56
#SBATCH --array=0-0
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=72:00:00

# Calculate PARAMS file index based on SLURM_ARRAY_TASK_ID
PARAM_INDEX=$(($SLURM_ARRAY_TASK_ID))
simulation_executable=build/acc_controller

PARAM_FILE="chip_params/raspberry_pi_5/l1_size/PARAMS.in_${PARAM_INDEX}"
PARAM_FILE="chip_params/cortex_m55/PARAMS.in_${PARAM_INDEX}"

# main.sh arguments: <start_idx> <time_horizon> <relative_chip_params_path> <relative_controller_params_path> <exp_name> <PARAM_INDEX> <dynamics_simulation_executable>
apptainer exec -f cac4_v1.sif Inverted-Pendulum/main.sh 0 2 ${PARAM_FILE} controller_parameters/acc/params.json acc_exp_3_cortex_m55 ${PARAM_INDEX} $simulation_executable 