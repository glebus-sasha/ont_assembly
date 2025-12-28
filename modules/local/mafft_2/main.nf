process MAFFT_2 {
    tag "all_samples"
    conda 'bioconda::mafft'
    container 'staphb/mafft:7.526'
    cpus params.cpus 

    input:
    tuple val(sid), path(fasta)

    output:
    tuple val(sid), path("*_multi.fasta"), emit: multifasta
       
    script:
    """
    mafft --auto $fasta > ${sid}_multi.fasta 
    """
}