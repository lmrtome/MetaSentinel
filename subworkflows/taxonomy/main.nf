#!/usr/bin/env nextflow

/*
--------------
Import modules
--------------
*/

include {TAXONOMY_ASSIGNMENT} from '../../modules/kraken2/main.nf'
include {PLOT_TAXONOMY}       from '../../modules/kraken2_plot/main.nf'

workflow TAXONOMY {

take: trimmed_data

main:
/*
--------------------
Taxonomic assignment
--------------------
*/
 
 TAXONOMY_ASSIGNMENT (trimmed_data)

/*
---------------------
Plot taxonomy results
---------------------
*/

 PLOT_TAXONOMY (TAXONOMY_ASSIGNMENT.out.taxonomy_assignment_reports)

emit: 

taxonomy_reports = TAXONOMY_ASSIGNMENT.out.taxonomy_assignment_reports
taxonomy_plots   = PLOT_TAXONOMY.out.taxonomy_plots

}