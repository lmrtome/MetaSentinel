#!/usr/bin/env nextflow

/*
--------------------------------------
Import modules for annotation workflow
--------------------------------------
*/

include {CONTIG_ANNOTATION}    from '../../modules/diamond/main.nf'
include {MAP_READS_TO_CONTIGS} from '../../modules/minimap2/main.nf'
include {AMR_DETECTION}        from '../../modules/amrfinder/main.nf'

workflow ANNOTATION {

    take:

    trimmed
    contigs

    main:


    /*
    -------------------------------
    Taxonomic annotation of contigs
    -------------------------------
    */

    CONTIG_ANNOTATION (contigs)

    /*
    --------------------------------
    Mapping trimmed reads to contigs
    --------------------------------
    */
    
    reads_mapping = contigs.join(trimmed)
                          .map {sample_id, contig, reads -> 
                          tuple(sample_id, contig, reads) }

    MAP_READS_TO_CONTIGS (reads_mapping)

    /*
    --------------------------------------------------------------
    Detection of antimicrobial resistance genes with AMRFinderPlus
    --------------------------------------------------------------
    */

    AMR_DETECTION (contigs)

    emit: 

    annotation_results = CONTIG_ANNOTATION.out.annotation_results
    mapping_result     = MAP_READS_TO_CONTIGS.out.mapping_result
    amr_results        = AMR_DETECTION.out.amr_results

}
