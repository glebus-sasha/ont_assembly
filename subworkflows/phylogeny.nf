include { ITSX                               } from '../modules/local/itsx/'
include { QUAST                              } from '../modules/nf-core/quast/'
include { FETCH_GENBANK                      } from '../modules/local/fetch_genbank/'
include { GUNZIP                             } from '../modules/nf-core/gunzip/main'
include { BLAST                              } from '../modules/local/blast/'
include { TOP_HIT_BLAST                      } from '../modules/local/local/top_hit_blast/'
include { CONCATENATE_ALL_FASTA              } from '../modules/local/local/concatenate_all_fasta/main.nf'
include { MAFFT_2                            } from '../modules/local/mafft_2/main.nf'
include { FAST_TREE                          } from '../modules/local/fast_tree/main.nf'



workflow phylogeny {
    
    take:
    genome
    genes_accessions
    
    main:
    ch_multiqc_files = channel.empty()
    ch_versions      = channel.empty()
    //
    // MODULE: ITSx
    //
    ITSX(
        genome
    )
    //
    // MODULE: QUAST
    //
/*     QUAST(
        [[], []],
        genome,
        [[], []]
    )
    ch_multiqc_files = ch_multiqc_files.mix(QUAST.out.results.map{ it -> it[1] } )
    ch_versions      = ch_versions.mix(QUAST.out.versions) */
    //
    // MODULE: Download genes from GenBank
    //
    FETCH_GENBANK(
        genes_accessions
    )    
    //
    // MODULE: GUNZIP
    //
    GUNZIP(
        genome
    )
    ch_genome = GUNZIP.out.gunzip
    //
    // MODULE: BLAST
    //
    ref_genes = FETCH_GENBANK.out.fasta
        .filter { meta, _fasta ->
            meta.species == 'T. amazonicum' &&
            meta.strain  == 'CBS 126898'
        }

    ch_blast_input = ch_genome.combine(ref_genes)
    BLAST(
        ch_blast_input
    )
    //
    // MODULE: Extract Top Hits fasta
    //
    TOP_HIT_BLAST(BLAST.out.tsv.combine(ch_genome, by: 0))
    ch_concatenate_input = TOP_HIT_BLAST.out.fasta
        .map { meta_1, meta_2, fasta -> [ [species: meta_1.id, strain: 'sp', gene: meta_2.gene, id: 'id'], fasta ] }
        .mix(FETCH_GENBANK.out.fasta)
        .map { meta, fasta -> [ meta.gene, fasta ] }
        .groupTuple()
    //
    // MODULE: Concatenate all fasta
    //
    CONCATENATE_ALL_FASTA(
        ch_concatenate_input
    )
    ch_concat_fasta = CONCATENATE_ALL_FASTA.out.fasta
    //
    // MODULE: MAFFT
    //
    MAFFT_2(
        ch_concat_fasta
    )
    ch_multifasta = MAFFT_2.out.multifasta
    //
    // MODULE: FastTree
    //
    FAST_TREE(
        ch_multifasta
    )
    ch_tree = FAST_TREE.out.nwk

    emit:
    tree          = ch_tree
    multiqc_files = ch_multiqc_files
    versions      = ch_versions
}