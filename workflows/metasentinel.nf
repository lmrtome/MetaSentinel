#!/usr/bin/env nextflow

/*
-------------------------------
Import subworkflows and modules
-------------------------------
*/

include {QC}              from '../subworkflows/qc/main.nf'
include {TAXONOMY}        from '../subworkflows/taxonomy/main.nf'
include {DENOVO_ASSEMBLY} from '../modules/flye/main.nf'
include {ANNOTATION}      from '../subworkflows/annotation/main.nf'
include {ABUNDANCE}       from '../subworkflows/abundance/main.nf'

/*
----------------
Main script flow
----------------
*/

workflow METASENTINEL {
    
    take:

    raw_reads_data

    main:

    /*
    -----------------------------------------------------------
    Quality control of raw reads and trimmed reads and trimming
    -----------------------------------------------------------
    */

    QC(raw_reads_data)
 
    /*
    ------------------------------------------------------
    Taxonomic classification of trimmed reads and plotting
    ------------------------------------------------------
    */

    TAXONOMY(QC.out.trimmed)

    /*
    --------------------------------------------------------------------------------------
    Conditional workflow for assembly, annotation and abundance estimation (default=false)
    --------------------------------------------------------------------------------------
    */

    de_novo_assembly   = channel.empty()
    annotation_output  = channel.empty()
    mapping_output     = channel.empty()
    amr_output         = channel.empty()
    abundance_output   = channel.empty()
    abundance_combined = channel.empty()
    abundance_plots    = channel.empty()

    if (params.run_assembly) {

        /*
        ----------------
        De novo assembly
        ----------------
        */

        DENOVO_ASSEMBLY (QC.out.trimmed)
    
        /*
        -------------------------------
        Taxonomic annotation of contigs
        -------------------------------
        */

        ANNOTATION (QC.out.trimmed, DENOVO_ASSEMBLY.out.contigs)

        /*
        -------------------------------
        Abundance estimation of contigs
        -------------------------------
        */

        ABUNDANCE (DENOVO_ASSEMBLY.out.contigs, ANNOTATION.out.mapping_result, ANNOTATION.out.annotation_results)

        de_novo_assembly   = DENOVO_ASSEMBLY.out.contigs
        annotation_output  = ANNOTATION.out.annotation_results
        mapping_output     = ANNOTATION.out.mapping_result
        amr_output         = ANNOTATION.out.amr_results
        abundance_output   = ABUNDANCE.out.abundance_results
        abundance_combined = ABUNDANCE.out.combined_results
        abundance_plots    = ABUNDANCE.out.abundance_plots
    }

    emit:

    qc_raw_data_output      = QC.out.qc_raw
    trimmed_data_output     = QC.out.trimmed
    qc_trimmed_data_output  = QC.out.qc_trimmed
    multiqc_report          = QC.out.multiqc_report
    taxonomy_reports        = TAXONOMY.out.taxonomy_reports
    taxonomy_plots          = TAXONOMY.out.taxonomy_plots
    de_novo_assembly        = de_novo_assembly
    annotation_output       = annotation_output
    mapping_output          = mapping_output
    amr_output              = amr_output
    abundance_output        = abundance_output
    abundance_plots         = abundance_plots
    abundance_combined      = abundance_combined 
    
}