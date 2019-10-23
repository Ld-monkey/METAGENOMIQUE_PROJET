#!/bin/bash

echo "Projet 16S workflow"

# Definition des variables.
dossier_reads=$1
dossier_sortie=$2

# Definir le lien pour le logiciel FastQC.
fastqc_folder=software/FastQC/

# Regarde si le dossier result est vide
if [ -z "$(ls -A results/)" ]; then
    # 1. Appelle du logiciel fastqc et de filtrage
    ./$fastqc_folder/fastqc $1/*_R1.fastq.gz $1/*_R2.fastq.gz -o $2
else
    echo "Le dossier results n'est pas vide."
    echo "Les fichiers sont déjà générés."
fi

# Definir le chemin pour le logiciel AlienTrimmer.
alien_folder=data/soft/

# 2. Filtrer un les reads appariés a l'aide d'AlienTrimmer
java -jar $alien_folder/AlienTrimmer.jar
