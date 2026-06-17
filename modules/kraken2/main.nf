process TAXONOMY_ASSIGNMENT {
    
    tag "${sample_id}"

    conda "${moduleDir}/environment.yml"

    input:
    tuple val(sample_id), path(trimming_results)

    output:
    tuple val(sample_id), path("${sample_id}_report.txt"), emit: taxonomy_assignment_reports

    script:
    """
    kraken2 --db ${params.database_kraken2} --threads ${params.threads} --report ${sample_id}_report.txt --gzip-compressed --output ${sample_id}_output.txt ${trimming_results}
    """
}
