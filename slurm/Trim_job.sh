#!/bin/bash
#SBATCH --account=def-mallev
#SBATCH --job-name=Trim_job
#SBATCH --output=data/%x_%j.out
#SBATCH --time=03:00:00
#SBATCH --ntasks=32
#SBATCH --nodes=1

IN_DIR=data/fqfiles
OUT_DIR=data
LANE=$1

module load CCEnv
module load StdEnv/2023
module load trimmomatic/0.39

cd $OUT_DIR
if [ ! -d "Trimmed" ]; then
  mkdir Trimmed/
fi
cd ..

if [ -f $OUT_DIR/SampleIDs/sample_ids_"$LANE".txt ]; then
  rm -f $OUT_DIR/SampleIDs/sample_ids_"$LANE".txt
  bash src/get_sampleID.sh $IN_DIR $OUT_DIR $LANE
fi
#remove the last two rows that correlate to the positive/negative control samples
sed -i '$d' $OUT_DIR/SampleIDs/sample_ids_"$LANE".txt
sed -i '$d' $OUT_DIR/SampleIDs/sample_ids_"$LANE".txt

cat $OUT_DIR/SampleIDs/sample_ids_$LANE.txt | \
parallel -j $SLURM_NTASKS \
java -jar $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE \
  $IN_DIR/*_"$LANE"_{}_1.fq.gz \
  $IN_DIR/*_"$LANE"_{}_2.fq.gz \
  $OUT_DIR/Trimmed/Trim_p_"$LANE"_{}_1.fq.gz \
  $OUT_DIR/Trimmed/Trim_s_"$LANE"_{}_1.fq.gz \
  $OUT_DIR/Trimmed/Trim_p_"$LANE"_{}_2.fq.gz \
  $OUT_DIR/Trimmed/Trim_s_"$LANE"_{}_2.fq.gz \
  SLIDINGWINDOW:4:20 \
  MINLEN:50
