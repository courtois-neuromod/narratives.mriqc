#!/bin/bash
#SBATCH --account=rrg-pbellec
#SBATCH --job-name=mriqc_study-narratives_sub-06_ses-005.job
#SBATCH --output=./code/mriqc_study-narratives_sub-06_ses-005.out
#SBATCH --error=./code/mriqc_study-narratives_sub-06_ses-005.err
#SBATCH --time=2:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=basile.pinsard@gmail.com



export LOCAL_DATASET=$SLURM_TMPDIR/${SLURM_JOB_NAME//-/}/
flock --verbose /lustre03/project/rrg-pbellec/ria-beluga/alias/cneuromod.narratives.mriqc/.datalad_lock datalad clone ria+file:///lustre03/project/rrg-pbellec/ria-beluga#~cneuromod.narratives.mriqc $LOCAL_DATASET
cd $LOCAL_DATASET
git-annex enableremote ria-beluga-storage
datalad get -s ria-beluga-storage -J 4 -n -r -R1 . # get sourcedata/* containers
if [ -d sourcedata/smriprep ] ; then
    datalad get -n sourcedata/smriprep sourcedata/smriprep/sourcedata/freesurfer
fi
git submodule foreach --recursive git annex dead here
git submodule foreach git annex enableremote ria-beluga-storage
git checkout -b $SLURM_JOB_NAME

datalad containers-run -m 'mriqc_sub-06/ses-005' -n bids-mriqc --input sourcedata/narratives/sub-06/ses-005/fmap/ --input sourcedata/narratives/sub-06/ses-005/func/ --output . -- -w /tmp --participant-label 06 --session-id 005 --omp-nthreads 4 --nprocs 4 -m bold --mem_gb 16 --no-datalad-get  --no-sub sourcedata/narratives ./ participant 
mriqc_exitcode=$?

flock --verbose /lustre03/project/rrg-pbellec/ria-beluga/alias/cneuromod.narratives.mriqc/.datalad_lock datalad push -d ./ --to origin
exit $mriqc_exitcode 
