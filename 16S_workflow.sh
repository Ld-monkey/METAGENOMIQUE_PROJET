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


