#!/usr/bin/env nextflow

/*
------------------------------------------------------------------------------------
MetaSentinel: A Metagenomic Workflow for Pathogen Detection and Genomic Surveillance
Developer: Luiz Marcelo Ribeiro Tomé
Github: https://github.com/lmrtome/MetaSentinel
------------------------------------------------------------------------------------
*/

/*
----------------
Import workflows
----------------
*/

include {METASENTINEL} from './workflows/metasentinel.nf'

/*
----------------
Main script flow
----------------
*/

workflow { 
    main: 

    long_reads = channel.fromPath("${params.input}/*.fastq.gz")
                        .map { file -> def sample_id = file.baseName.replaceFirst(/\.f(ast)?q(\.gz)?$/, '') 
                        tuple(sample_id, file)}
                        
   

    METASENTINEL(long_reads)

    /*
    ------------------------------------------------------
    Define output directories and channels for publication
    ------------------------------------------------------
    */

    publish:

    /*
    ----------------------------------------------------
    Directories for quality control and trimming outputs
    ----------------------------------------------------
    */
        qc_raw_data       = METASENTINEL.out.qc_raw_data_output
        trimmed_data      = METASENTINEL.out.trimmed_data_output
        qc_trimmed_data   = METASENTINEL.out.qc_trimmed_data_output
        multiqc_qc        = METASENTINEL.out.multiqc_report
    /*
    -------------------------------------------------------------
    Directories for taxonomic classification and plotting outputs
    -------------------------------------------------------------
    */
        taxonomic_reports = METASENTINEL.out.taxonomy_reports
        taxonomic_plots   = METASENTINEL.out.taxonomy_plots

    /*
    -------------------------------------------------------
    Directories for de novo assembly and annotation outputs
    -------------------------------------------------------
    */
    
        de_novo_assembly  = METASENTINEL.out.de_novo_assembly
        annotation_output = METASENTINEL.out.annotation_output
        mapping_output    = METASENTINEL.out.mapping_output

    /*
    --------------------------------------------------------------
    Directories for AMR detection and abundance estimation outputs
    --------------------------------------------------------------
    */

        amr_output         = METASENTINEL.out.amr_output
        abundance_output   = METASENTINEL.out.abundance_output
        abundance_plots    = METASENTINEL.out.abundance_plots
        abundance_combined = METASENTINEL.out.abundance_combined

}

/*
----------------------------------------
Output definitions to result directories
----------------------------------------
*/

output {
    
    qc_raw_data {
        path { sample_id, _file -> "qc/${sample_id}/raw/" }
    }

    trimmed_data {
        path { sample_id, _file -> "trimmed/${sample_id}" }
    }

    qc_trimmed_data {
        path { sample_id, _file -> "qc/${sample_id}/trimmed/" }
    }

    multiqc_qc {
        path { "multiqc_report" }
    }

    taxonomic_reports {
        path { sample_id, _file -> "taxonomy/${sample_id}/reports/" }
    }

    taxonomic_plots {
        path { sample_id, _file -> "taxonomy/${sample_id}/plots/" }
    }

    de_novo_assembly {
        path { sample_id, _file -> "assembly/${sample_id}" }
    }

    annotation_output {
        path { sample_id, _file -> "annotation/${sample_id}" }
    }

    mapping_output {
        path { sample_id, _file -> "mapping/${sample_id}" }
    }

    amr_output {
        path { sample_id, _file -> "amrfinder/${sample_id}" }
    }

    abundance_output {
        path { sample_id, _file -> "abundance_output/${sample_id}" }
    }

    abundance_plots {
        path { sample_id, _file -> "abundance/${sample_id}/abundance_plots/" }
    }

    abundance_combined {
        path { sample_id, _file -> "abundance/${sample_id}/abundance_combined/"}
    }
}

/*
-----------------------------------
THE END OF THE MAIN WORKFLOW SCRIPT
-----------------------------------
*/
