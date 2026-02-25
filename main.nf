include { samplesheetToList         } from 'plugin/nf-schema'
include { assembly_taxonomy_hybrid           } from './subworkflows/assembly_taxonomy_hybrid.nf'
//include { convert_fast5_to_fastq             } from './subworkflows/convert_fast5_to_fastq.nf'
//include { annotation                         } from './subworkflows/annotation.nf'
include { phylogeny                          } from './subworkflows/phylogeny.nf'
include { MULTIQC                            } from './modules/nf-core/multiqc/'

workflow {

    ch_multiqc_files          = channel.empty()
/*
    //
    // SUBWORKFLOW: Convert FAST5 to FASTQ
    //
    if ( params.basecalling ) {
        ch_fast5 = channel.fromPath(params.fast5)
            .collect()
            .map { files -> [ species_name, files ] }
        dorado_models  = channel.value(file(params.dorado_models))
        convert_fast5_to_fastq(
            ch_fast5, 
            dorado_models
        )
        reads_long = convert_fast5_to_fastq.out.fastq
    }
    else {
        reads_long               = channel.fromPath(params.reads_long)
            .map { it -> [it.simpleName, it] }
        log.info ">>Skipping demultiplexing step"
    }
*/
    //
    // SUBWORKFLOW: Assembly
    //
    if ( params.assembly ) {
        channel
            .fromList(samplesheetToList(params.input, "${projectDir}/assets/schema_input.json"))
            .map {
                meta, fastq_1, fastq_2 ->
                    if (!fastq_2) {
                        return [ meta.id, meta + [ single_end:true ], [ fastq_1 ] ]
                    } else {
                        return [ meta.id, meta + [ single_end:false ], [ fastq_1, fastq_2 ] ]
                    }
            }
            .map { _sample, meta, reads -> [meta, reads] }
            .set { ch_reads }

        assembly_taxonomy_hybrid(ch_reads)
        genome = assembly_taxonomy_hybrid.out.genome
        ch_multiqc_files = ch_multiqc_files
            .mix(assembly_taxonomy_hybrid.out.multiqc_files)

    }
/*
    //
    // SUBWORKFLOW: Annotation
    //
    else {
        log.info ">>Skipping assembly step"
    }
    if ( params.annotation ) {
        species_name              = params.species_name
        strain_name               = params.strain_name
        template_file            = channel.value(file(params.template_file))
            .map{ it -> [it.simpleName, it] }
        ch_annotation_input = assembly_taxonomy_hybrid.out.genome
            .join(template_file)
            .join(species_name)
            .join(strain_name)
        protein_alignments       = channel.value(file(params.protein_alignments))
        protein_evidence         = channel.value(file(params.protein_evidence))
        protein_evidence_2       = channel.value(file(params.protein_evidence_2))
        eggnog_proteins          = channel.value(file(params.eggnog_proteins))
        interproscan             = channel.value(file(params.interproscan))
        annotation(
            ch_annotation_input,
            params.busco_seed_species,
            params.busco_db,
            protein_alignments,
            protein_evidence,
            protein_evidence_2,
            eggnog_proteins,
            interproscan
        )
        ch_multiqc_files = ch_multiqc_files
            .mix(assembly_taxonomy_hybrid.out.fastqc.map { it -> it[1]} )
            .mix(assembly_taxonomy_hybrid.out.fastqc_trimmed.map { it -> it[1]} )
    }
    else {
        log.info ">>Skipping annotation step"
    }
*/
    //
    // SUBWORKFLOW: Phylogeny
    //
    if ( params.phylogeny ) {
        genes_accessions = channel.fromPath(params.genes)
            .splitCsv(header:true)
            .flatMap { row ->
                def species = row.species
                def strain  = row.Strain
                def genes   = ['ITS','tef1','rpb2']
                
                genes.collect { gene ->
                    def id = row[gene]
                    if (id) return [species: species, strain: strain, gene: gene, id: id]
                }.findAll { it -> it != null }
            }
        phylogeny(
            genome,
            genes_accessions
        )
        ch_multiqc_files = ch_multiqc_files
            .mix(phylogeny.out.multiqc_files)
    }
    else {
        log.info ">>Skipping phylogeny step"
    }
    ch_multiqc_files = ch_multiqc_files.collect()
    //
    // MODULE: MultiQC
    //
    ch_multiqc_logo = channel.value(file("${projectDir}/assets/oxkolpakova-ont-assembly_logo_light.svg"))
    MULTIQC(
        ch_multiqc_files,
        [],
        [],
        ch_multiqc_logo,
        [],
        []
    )
}

