process FUNANNOTATE_ANNOTATE {
    tag "${meta.id}"
    
    conda 'bioconda::funannotate'
    container 'nextgenusfs/funannotate:v1.8.15'
    //errorStrategy 'ignore'
    cpus params.cpus 

    input:
    tuple val(meta), val(species_name), path(template_file), path(fun_folder), path(antismash), path(emapper_annotations), path(phobius), path(signalp), path(iprscan)

    output:
    tuple val(meta), path("${fun_folder}/annotate_results")                      , emit: funannotate_annotate
    tuple val(meta), path("${fun_folder}/annotate_results/${species_name}*.gff3"), emit: gff
    tuple val(meta), path("${fun_folder}/annotate_results/${species_name}*.gbk") , emit: gbk
    tuple val(meta), path("${fun_folder}/annotate_results/${species_name}*.tbl") , emit: tbl

    script:
    """
    funannotate annotate -i $fun_folder \
      --species $species_name \
      --cpus $task.cpus \
      --sbt $template_file \
      --out ${meta.id}_annotate \
      --antismash $antismash \
      --eggnog $emapper_annotations \
      --phobius $phobius \
      --signalp $signalp \
      --iprscan $iprscan \
      --force
    """
    }