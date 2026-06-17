#!/usr/bin/env nextflow

/*
---------------------------------
Workflow for abundance estimation
---------------------------------
*/

/*
-------------------------------------
Import modules for abundance workflow
-------------------------------------
*/

include {ESTIMATE_ABUNDANCE}        from '../../modules/salmon/main.nf'
include {PLOT_TRANSCRIPT_ABUNDANCE} from '../../modules/abundance_plot/main.nf'

workflow ABUNDANCE {

    take:

    contig
    mapping_result
    annotation_results

    main:
    
    /*
    ---------------------------------
    Contig-level abundance estimation
    ---------------------------------
    */

    contigs_abundance = mapping_result.join(contig)
                                      .map {sample_id, mapped_sam ,contigs -> 
                                      tuple(sample_id, contigs, mapped_sam) }

    abundance_results = ESTIMATE_ABUNDANCE (contigs_abundance)

    /*
    -------------------
    Plot abundance taxa
    -------------------
    */

    plot_inputs = abundance_results.join(annotation_results, by: 0)
                                   .map { sample_id, salmon_quant, diamond_res ->
                                   tuple(sample_id, diamond_res, file(params.taxa_names), salmon_quant) }

    PLOT_TRANSCRIPT_ABUNDANCE (plot_inputs)

    emit:

    abundance_results = ESTIMATE_ABUNDANCE.out.salmon_quant    
    abundance_plots   = PLOT_TRANSCRIPT_ABUNDANCE.out.abundance_plots
    combined_results  = PLOT_TRANSCRIPT_ABUNDANCE.out.combined_results

 }