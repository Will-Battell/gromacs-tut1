#!/bin/bash
#SBATCH --job-name=
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --cpus-per-task=1
#SBATCH --time=04:00:00

#SBATCH --account=e793-wbattell

#SBATCH --partition=standard
#SBATCH --qos=standard

# Load the GROMACS module (meaning we can run GROMACS commands)

module load gromacs/2022.4

# Define the number of threads to use for the simulation (required for parallel simulations)

export OMP_NUM_THREADS=1

# Run our simulations

# Energy Minimisation - Make a directory for EM and run the simulation (

mkdir EM
cd ./EM

gmx grompp -f ../gromacs1/em.mdp -c ../8b2t-final.gro -p ../topol.top -o em.tpr
srun gmx_mpi mdrun -s em.tpr -c 8b2t-em.gro

cd ../

# NVT simulation - This is used to quickly equilibrate our system

mkdir NVT
cd ./NVT

gmx grompp -f ../gromacs1/nvt.mdp -c ../EM/8b2t-em.gro -r ../EM/8b2t-em.gro -p ../topol.top -o nvt.tpr
srun gmx_mpi mdrun -s nvt.tpr -c 8b2t-nvt.gro

cd ../

# NPT simulation - This is used to give us the correct box size/volume (therefore a density that matches physical reality)

mkdir NPT
cd ./NPT

gmx grompp -f ../gromacs1/npt.mdp -c ../NVT/8b2t-nvt.gro -r ../NVT/8b2t-nvt.gro -p ../topol.top -o npt.tpr
srun gmx_mpi mdrun -s npt.tpr -c 8b2t-npt.gro

cd ../

# Long NVT production simulation - Long simulation used for data collection

mkdir MD
cd ./MD

gmx grompp -f ../gromacs1/md.mdp -c ../NPT/8b2t-npt.gro -r ../NPT/8b2t-npt.gro -p ../topol.top -o md.tpr
srun gmx_mpi mdrun -s md.tpr -c 8b2t-md.gro

cd ../

