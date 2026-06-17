process QC_TRIMMED_READS {
    
    tag "${sample_id}"

    conda "${moduleDir}/environment.yml"
    
    input:
    tuple val(sample_id), path(trimming_results)

    output:
    tuple val(sample_id), path("NanoPlot-${sample_id}-filtered"), emit: qc_trimmed_reads

    script:
    """
    NanoPlot --fastq ${trimming_results} --threads ${params.threads} --outdir NanoPlot-${sample_id}-filtered
    """
}
