process QC_RAW_READS {
    
    tag "${sample_id}"

    conda "${moduleDir}/environment.yml"

    input:
    tuple val(sample_id), path(long_reads)

    output:
     tuple val(sample_id), path("NanoPlot-${sample_id}-raw"), emit: qc_raw_reads

    script:
    """
    NanoPlot --fastq ${long_reads} --threads ${params.threads} --outdir NanoPlot-${sample_id}-raw
    """
}
