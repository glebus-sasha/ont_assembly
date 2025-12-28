process TOP_HIT_BLAST {
    tag "$r_meta $q_meta"
    
    //errorStrategy 'ignore'
    cpus params.cpus 

    input:
    tuple val(r_meta), val(q_meta), path(blast_results), path(fasta)

    output:
    tuple val(r_meta), val(q_meta), path("${r_meta.id}_${q_meta.id}_top_hit.fasta"), emit: fasta
       
    script:
    """
    sort -k12,12nr $blast_results |\
        head -n 1 |\
        awk '{if (\$9 < \$10) print \$2":"\$9"-"\$10; else print \$2":"\$10"-"\$9}' |\
        xargs samtools faidx $fasta |\
        sed "s/^>.*\$/>${r_meta.id}/" > ${r_meta.id}_${q_meta.id}_top_hit.fasta
    """
}