#!/bin/bash -l
#$ -N map-salmon
# specify queue
#$ -q all.q
# start in the current working directory
#$ -cwd
# email notification
#$ -M rwo8@cdc.gov
# email if job aborts
#$ -m a
#$ -t 1-24
# N 5
# mem=100G


main="/scicomp/home-pure/rwo8/workdir/rna_seq_dataset2_07082022"
raw="/scicomp/home-pure/rwo8/workdir/rna_seq_dataset2_07082022/data/220705_A01000_0207_BH5YJFDRX2_MON15303"
data="$main/data"


###########################################################################
#
# trim raw reads
#
##########################################################################

# ############ quality check raw data ###########################################

# ml fastqc/0.11.5
# ml MultiQC/1.9

# mkdir -p $data/fastqc_pre

# for file in $raw/*/*;
# do
# sample=$(basename $file '_001.fastq.gz')

# mkdir -p $data/fastqc_pre/$sample
# fastqc $file -o $data/fastqc_pre/$sample -t 5
# done

# multiqc $data/fastqc_pre/* -n $data/fastqc_pre/multiqc_fastqc_pre

# ############ trim ###########################################
# # This is a parallel job, change header is needed to run "#$ -t 1-24", need to change the number of t based on sample number after A in MON15303A*

# ml fastp/0.20.1

# mkdir -p $data/trimmed/
# R1=$(ls $raw/MON15303A${SGE_TASK_ID}_*/*_R1_001.fastq.gz)
# R2=$(ls $raw/MON15303A${SGE_TASK_ID}_*/*_R2_001.fastq.gz)

# sample=$(basename $R1 '_R1_001.fastq.gz')

# fastp \
# --in1 $R1 \
# --in2 $R2 \
# --out1 $data/trimmed/${sample}_R1_001.fastq.gz \
# --out2 $data/trimmed/${sample}_R2_001.fastq.gz

############ quality check trimmed data ###########################################


# ml fastqc/0.11.5
# ml MultiQC/1.9

# mkdir -p $data/fastqc_post/
# R1=$(ls $data/trimmed/*_S${SGE_TASK_ID}_R1_001.fastq.gz)
# R2=$(ls $data/trimmed/*_S${SGE_TASK_ID}_R2_001.fastq.gz)

# sample1=$(basename $R1 '_001.fastq.gz')
# sample2=$(basename $R2 '_001.fastq.gz')


# mkdir -p $data/fastqc_post/$sample1
# mkdir -p $data/fastqc_post/$sample2

# fastqc $R1 -o $data/fastqc_post/$sample1 -t 5
# fastqc $R2 -o $data/fastqc_post/$sample2 -t 5


# # multiqc $data/fastqc_post/* -n $data/multiqc_fastqc_post

###########################################################################
#
# align and quantify gene expression
#
##########################################################################

conda activate rna_seq

salmon="$main/salmon"

# 1) get salmon index for human: http://refgenomes.databio.org/v3/assets/splash/2230c535660fb4774114bfa966a62f823fdb6d21acf138d4/salmon_sa_index?tag=default

# cd $salmon/index
# wget http://refgenomes.databio.org/v3/assets/archive/2230c535660fb4774114bfa966a62f823fdb6d21acf138d4/salmon_sa_index?tag=default
# # unzip downloaded index
# tar -avxf salmon_sa_index\?tag\=default
 
# 2) use salmon's mapping mode for qunatification

R1=$(ls $data/trimmed/*_S${SGE_TASK_ID}_R1_001.fastq.gz)
R2=$(ls $data/trimmed/*_S${SGE_TASK_ID}_R2_001.fastq.gz)

sample=$(basename $R1 '_R1_001.fastq.gz')

mkdir -p $salmon $salmon/salmon_map/ 
mkdir -p $salmon/salmon_map/$sample

salmon quant -i $salmon/index -l A \
-1 $R1 -2 $R2 \
-o $salmon/salmon_map/$sample \
-p 5 --gcBias --seqBias \
-g $main/reference/gencode.v39.annotation.gtf.gz




