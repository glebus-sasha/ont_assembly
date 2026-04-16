include { GUNZIP                             } from '../modules/nf-core/gunzip'
include { FUNANNOTATE_CLEAN                  } from '../modules/local/funannotate/clean/'
include { FUNANNOTATE_SORT                   } from '../modules/local/funannotate/sort/'
include { FUNANNOTATE_MASK                   } from '../modules/local/funannotate/mask/'
include { FUNANNOTATE_PREDICT                } from '../modules/local/funannotate/predict/'
include { FUNANNOTATE_BUSCO_INSTALL          } from '../modules/local/funannotate/busco_install/'
include { FUNANNOTATE_ANTISMASH              } from '../modules/local/funannotate/antismash/'
include { FUNANNOTATE_ANNOTATE               } from '../modules/local/funannotate/annotate/'
include { FUNANNOTATE_FIX                    } from '../modules/local/funannotate/fix/'
include { INTERPROSCAN                       } from '../modules/local/interproscan/'
include { ANTISMASH                          } from '../modules/local/antismash/'
include { PHOBIUS                            } from '../modules/local/phobius/'
include { SIGNALP                            } from '../modules/local/signalp/'
include { EGGNOG_MAPPER                      } from '../modules/local/eggnog_mapper/'
include { QUAST                              } from '../modules/local/quast/'

workflow annotation {
    take:
    genome_template_file_species_name_strain_name
    busco_seed_species
    busco_db
    protein_alignments
    protein_evidence
    protein_evidence_2
    eggnog_proteins
    interproscan
    
    main:
    ch_genome       = genome_template_file_species_name_strain_name.map { it -> [ it[0], it[1] ] }
    species_name    = genome_template_file_species_name_strain_name.map { it -> [ it[0], it[2] ] }
    template_file   = genome_template_file_species_name_strain_name.map { it -> [ it[0], it[3] ] }
    strain_name     = genome_template_file_species_name_strain_name.map { it -> [ it[0], it[5] ] }
    GUNZIP(
        ch_genome
    )
    ch_genome = GUNZIP.out.gunzip
    FUNANNOTATE_CLEAN(
        ch_genome
        )
    ch_genome = FUNANNOTATE_CLEAN.out
    FUNANNOTATE_SORT(
        ch_genome
        )
    ch_genome = FUNANNOTATE_SORT.out
    FUNANNOTATE_MASK(
        ch_genome
        )
    ch_genome = FUNANNOTATE_MASK.out
/*     FUNANNOTATE_BUSCO_INSTALL(
        'hypocreaceae_odb12'
    ) */
    ch_fun_predict = ch_genome.join(species_name).join(strain_name)
    FUNANNOTATE_PREDICT(
        ch_fun_predict,
        busco_seed_species,
        busco_db,
        protein_alignments,
        protein_evidence,
        protein_evidence_2
        )
    ch_proteins = FUNANNOTATE_PREDICT.out.proteins
    ch_antismash = FUNANNOTATE_MASK.out.join(FUNANNOTATE_PREDICT.out.gbk)
    ANTISMASH(
        ch_antismash
        )
    PHOBIUS(
        ch_proteins
        )
    SIGNALP(
        ch_proteins
        )
    EGGNOG_MAPPER(
        ch_proteins, 
        eggnog_proteins
        )
    INTERPROSCAN(
        ch_proteins, 
        interproscan
        )
    ch_fun_annotate = species_name
        .join(template_file) 
        .join(FUNANNOTATE_PREDICT.out.predict_dir)   
        .join(ANTISMASH.out.gbk)
        .join(EGGNOG_MAPPER.out.emapper_annotations)
        .join(PHOBIUS.out)
        .join(SIGNALP.out)
        .join(INTERPROSCAN.out.xml)
    FUNANNOTATE_ANNOTATE(
        ch_fun_annotate
        )
    ch_gff = FUNANNOTATE_ANNOTATE.out.gff
    ch_gbk = FUNANNOTATE_ANNOTATE.out.gbk
    ch_tbl = FUNANNOTATE_ANNOTATE.out.tbl
    ch_fun_fix = ch_gbk.join(ch_tbl)
    FUNANNOTATE_FIX(
        ch_fun_fix
        )
    ch_quast_input = ch_genome.join(ch_gff)
    QUAST(
        ch_quast_input
        )
    ch_quast = QUAST.out
    
    emit:
    quast   = ch_quast
    gff     = ch_gff
}