#!/bin/bash
#SBATCH --job-name=nirma-test
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=128
#SBATCH --cpus-per-task=1
#SBATCH --time=04:00:00

#SBATCH --account=e793-wbattell

#SBATCH --partition=standard
#SBATCH --qos=standard

module load gromacs/2022.4

export OMP_NUM_THREADS=1

gmx grompp -f ./mdp-files/em.mdp -c 8B2T-nirma-bigger-box.gro -p topol.top -o em.tpr -maxwarn 5
srun gmx_mpi mdrun  -s em.tpr -c nirma-em.gro

gmx grompp -f ./mdp-files/nvt.mdp -c nirma-em.gro -r nirma-em.gro -p topol.top -o nvt.tpr -maxwarn 5
srun gmx_mpi mdrun  -s nvt.tpr -c nirma-nvt.gro

