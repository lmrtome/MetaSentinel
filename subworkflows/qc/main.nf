#!/usr/bin/env nextflow

/*
--------------
Import modules
--------------
*/

include {QC_RAW_READS}        from '../../modules/nanoplot/qc_raw/main.nf'
include {TRIM_READS}          from '../../modules/chopper/main.nf'
include {QC_TRIMMED_READS}    from '../../modules/nanoplot/qc_trimmed_reads/main.nf'
include {MULTIQC_REPORT}      from '../../modules/multiqc/main.nf'

workflow QC { 

take: 

reads

main:
    
/*
------------------------------
Quality check step of raw data
------------------------------
*/

QC_RAW_READS (reads)

/*
-------------
Trimming step
-------------
*/

TRIM_READS (reads)

/*
----------------------------------
Quality check step of trimmed data
----------------------------------
*/

QC_TRIMMED_READS (TRIM_READS.out)

/*
--------------------------------------------------------------
Extract output directories from each module to pass to MultiQC
--------------------------------------------------------------
*/

 raw_dirs = QC_RAW_READS.out.map { _sample_id, file -> file }
 trimmed_dirs = QC_TRIMMED_READS.out.map { _sample_id, file -> file }

/*
-----------------------------------
Combine all directories for MultiQC
-----------------------------------
*/

 qc_all_dirs = raw_dirs
    .mix(trimmed_dirs)
    .collect()

/*
-----------
Run MultiQC
-----------
*/

 MULTIQC_REPORT (qc_all_dirs)

emit: 

 qc_raw = QC_RAW_READS.out.qc_raw_reads
 trimmed = TRIM_READS.out.trimmed_reads
 qc_trimmed = QC_TRIMMED_READS.out.qc_trimmed_reads
 multiqc_report = MULTIQC_REPORT.out.report
}