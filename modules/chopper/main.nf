process TRIM_READS {
    
    tag "${sample_id}"

    conda "${moduleDir}/environment.yml"

    input:
    tuple val(sample_id), path(long_reads)

    output:
    tuple val(sample_id), path("trimmed_${sample_id}.fastq.gz"), emit: trimmed_reads

    script:
    """
    gunzip -c ${long_reads} | chopper --trim-approach fixed-crop --headcrop ${params.headcrop} -q ${params.phredscore} -l ${params.minlen} --threads ${params.threads} | gzip > trimmed_${sample_id}.fastq.gz
    """
}
