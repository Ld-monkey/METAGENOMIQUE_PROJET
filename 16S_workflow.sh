#!/bin/bash

echo "----Projet 16S workflow----"

# Definition des variables.
dossier_reads=$1
dossier_sortie=$2

# Definir le lien pour le logiciel FastQC.
fastqc_folder=software/FastQC/

# Regarde si le dossier result est vide
if [ -z "$(ls -A results/fastqc)" ]; then
    # 1. Appelle du logiciel fastqc et de filtrage
    mkdir $2/fastqc
    ./$fastqc_folder/fastqc $1/*_R1.fastq.gz $1/*_R2.fastq.gz -o $2/fastqc
else
    echo "Le dossier results n'est pas vide."
    echo "Les fichiers sont déjà générés."
fi

# Ungip tous les fichier dans data/fastq.
if [ -e "data/fastq/*.gz" ]
then
    gunzip data/fastq/*.gz
else
    echo "Tous les fichier sont décompressés."
fi

# Definir le chemin pour le logiciel AlienTrimmer et séquence Alien.
alien_folder=data/soft/
dir_seq_alien=data/databases/

# Verification de l'existence results/alientrimmer.
if [ -d $2/alientrimmer ]
then
    echo "alientrimmer exist."
else
    mkdir $2/alientrimmer
fi

# 2. Filtrer les reads appariés a l'aide d'AlienTrimmer
if [ -e "results/alientrimmer/*.fastq" ]
then
    all_R1=`ls $1*_R1.fastq`
    for i in $all_R1
    do
        j=$(echo $i|sed "s:R1:R2:g")
        java -jar $alien_folder/AlienTrimmer.jar -if $i -ir $j -c $dir_seq_alien/contaminants.fasta -q 20 -of $2/alientrimmer/$(basename $i) -or $2/alientrimmer/$(basename $j)
    done
else
    echo "Tous les fastq sont générés."
    echo "Fin du filtrage de(s) read(s)"
fi

# Verification de l'existence results/fusion_reads.
if [ -d $2/fusion_reads ]
then
    echo "fusion_reads exist."
else
    mkdir $2/fusion_reads
    echo "dossier fusion_reads créé"
fi

# Pour trouver de l'aide de vsearch.
# ./$alien_folder/vsearch --help

# 3 - fusionner les reads à l'aide de Vsearch (paired-end reads merging)
# Et sort un fichier format fasta. + ajouter suffix a chaque read
# par ex : sample=1ng-25cycle-1

# Verifie si le dossier est vide.
if [ "$(ls -A results/fusion_reads/)" ]
then
    echo "Tous les fastq ont été fusionnés et ont généré des fastas."
    echo "Fin de la fusion de(s) fasta."
else
    all_R1=`ls $2alientrimmer/*_R1.fastq`
    for i in $all_R1
    do
        i_R1=$(basename $i)
        j=$(echo $i | sed "s:R1:R2:g")
        j_R2=$(basename $j)
        pre_outj=$(basename $j | cut -d. -f1)
        output=$(echo $pre_outj | sed "s/_R2//g")

        # paired-end reads mergin
        ./$alien_folder/vsearch --fastq_mergepairs $2alientrimmer/$i_R1 --reverse $2alientrimmer/$j_R2  --fastaout $2fusion_reads/$output.fasta --label_suffix ";sample=$output"
    done
fi

# Verification de l'existence results/concatenation_amplicon.
if [ -d $2/concatenation_amplicon ]
then
    echo "concatenation_amplicon exist."
else
    mkdir $2/concatenation_amplicon
    echo "dossier concatenation_amplicon créé"
fi

# Rassembler tous les fichiers en 1 seul ==> amplicon.fasta.

cat $2fusion_reads/*.fasta > $2concatenation_amplicon/amplicon.fasta
sed -i "s/ //g" $2concatenation_amplicon/amplicon.fasta
echo "La concatenation est complete -> amplicon.fasta"

# 4 étapes de clusterisation.
