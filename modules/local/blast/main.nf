process BLAST {
    tag "$r_meta $q_meta"
    conda 'bioconda::blast'
    container 'staphb/blast:2.16.0'
    //errorStrategy 'ignore'
    cpus params.cpus
       
    input:
    tuple val(r_meta), path(reference), val(q_meta), path(query)
    
    output:
    tuple val(r_meta), val(q_meta), path("${r_meta.id}_${q_meta.id}_blast.tsv"), emit: tsv
    
    script:
    """
    makeblastdb -in $reference -dbtype nucl -out genome_db
    blastn -query $query -db genome_db -outfmt 6 -out ${r_meta.id}_${q_meta.id}_blast.tsv
    """
}