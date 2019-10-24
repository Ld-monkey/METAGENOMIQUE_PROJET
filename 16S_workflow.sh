#!/bin/bash

echo "----Projet 16S workflow----"

# Definition des variables.
echo $1
echo $2

if [ -d $2 ]
then
    echo "$2 exist."
else
    mkdir $2
fi

# Definir le lien pour le logiciel FastQC.
fastqc_folder=FastQC/

# Regarde si le dossier result est vide.
if [ -z "$(ls -A $2/fastqc)" ]; then
    # 1. Appelle du logiciel fastqc et de filtrage
    mkdir $2/fastqc
    ./$fastqc_folder/fastqc $1/*_R1.fastq.gz $1/*_R2.fastq.gz -o $2/fastqc
else
    echo "Le dossier results n'est pas vide."
    echo "Les fichiers sont déjà générés."
fi

# Ungip tous les fichier dans fastq.
gunzip fastq/*.gz
echo "Tous les fichier sont décompressés."

# Definir le chemin pour le logiciel AlienTrimmer et séquence Alien.
alien_folder=soft/
dir_seq_alien=databases/

# Verification de l'existence results/alientrimmer.
if [ -d $2/alientrimmer ]
then
    echo "alientrimmer exist."
else
    mkdir $2/alientrimmer
fi

# 2. Filtrer les reads appariés a l'aide d'AlienTrimmer
all_R1=`ls $1/*_R1.fastq`
for i in $all_R1
do
    j=$(echo $i|sed "s:R1:R2:g")
    java -jar $alien_folder/AlienTrimmer.jar -if $i -ir $j -c $dir_seq_alien/contaminants.fasta -q 20 -of $2/alientrimmer/$(basename $i) -or $2/alientrimmer/$(basename $j)
done
echo "Tous les fastq sont générés."
echo "Fin du filtrage de(s) read(s)"

# Verification de l'existence results/fusion_reads.
if [ -d $2/fusion_reads ]
then
    echo "fusion_reads exist."
else
    mkdir $2/fusion_reads
    echo "dossier fusion_reads créé"
fi

# 3 - fusionner les reads à l'aide de Vsearch (paired-end reads merging)
# Et sort un fichier format fasta. + ajouter suffix a chaque read
# par ex : sample=1ng-25cycle-1

# Verifie si le dossier est vide.
if [ "$(ls -A results/fusion_reads/)" ]
then
    echo "Tous les fastq ont été fusionnés et ont généré des fastas."
    echo "Fin de la fusion de(s) fasta."
else
    all_R1=`ls $2/alientrimmer/*_R1.fastq`
    for i in $all_R1
    do
        i_R1=$(basename $i)
        j=$(echo $i | sed "s:R1:R2:g")
        j_R2=$(basename $j)
        pre_outj=$(basename $j | cut -d. -f1)
        output=$(echo $pre_outj | sed "s/_R2//g")

        # paired-end reads mergin
        ./$alien_folder/vsearch --fastq_mergepairs $2/alientrimmer/$i_R1 --reverse $2/alientrimmer/$j_R2  --fastaout $2/fusion_reads/$output.fasta --label_suffix ";sample=$output"
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
cat $2/fusion_reads/*.fasta > $2/concatenation_amplicon/amplicon.fasta
sed -i "s/ //g" $2/concatenation_amplicon/amplicon.fasta
echo "La concatenation est complete -> amplicon.fasta"

# 4 étapes de clusterisation.

# 4-1 : Déduplication en full length ou en prefix
# Abondances de chaque séquence devront être reportées.
# Verification de l'existence results/concatenation_amplicon.
# + 4-2 : Suppression des singletons < abondance 10 avec --miniquesize.
if [ -d $2/dereplication ]
then
    echo "dereplication exist."
else
    mkdir $2/dereplication
    echo "dossier dereplication créé"
fi
./$alien_folder/vsearch --derep_fulllength $2/concatenation_amplicon/amplicon.fasta --sizeout --minuniquesize 10 --output $2/dereplication/derep_amplicon.fasta

# 4-3 : Suppression des chimères : chimera detection
# Approche denovo, confirmer avec blast ?
if [ -d $2/chimeras ]
then
    echo "chimeras exist."
else
    mkdir $2/chimeras
    echo "dossier chimeras créé"
fi
./$alien_folder/vsearch --uchime_denovo $2/dereplication/derep_amplicon.fasta --nonchimeras $2/chimeras/chimeras.fasta

# 4-3 : Clustering = 97 identité, OTU=centroids
# Chaque centroid = OTU_numéro_de_séquence.
if [ -d $2/clustering ]
then
    echo "clustering exist."
else
    mkdir $2/clustering
    echo "dossier clustering créé"
fi
./$alien_folder/vsearch --cluster_size $2/chimeras/chimeras.fasta  --id 0.97 --relabel OTU_ --centroids $2/clustering/clustering.fasta

# Maintenant que nous avons les OTUs:
# 5-1 : Déterminer leurs abondances et retourner un table d'abondance.
if [ -d $2/table_abondance ]
then
    echo "table_abondance exist."
else
    mkdir $2/table_abondance
    echo "dossier table_abondance créé"
fi
./$alien_folder/vsearch --usearch_global $2/chimeras/chimeras.fasta --db $2/clustering/clustering.fasta --id 0.97 --otutabout $2/table_abondance/table_abondance

# 5-2 : Annoter
./$alien_folder/vsearch --usearch_global $2/clustering/clustering.fasta --db databases/mock_16S_18S.fasta --id 0.9 --top_hits_only --userfields query+target --userout $2/table_abondance/table_abondance
sed '1iOTU\tAnnotation' -i $2/table_abondance/table_abondance

echo "----Fin du programme---- "
