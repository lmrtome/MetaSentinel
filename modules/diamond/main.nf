process CONTIG_ANNOTATION {
    
    tag "${sample_id}"

    conda "${moduleDir}/environment.yml"

    input:
    tuple val(sample_id), path(assembly_results)

    output:
    tuple val(sample_id), path("${sample_id}_matches.tsv"), emit: annotation_results

    script: 
    """
    diamond blastx \\
        --query   ${assembly_results} \\
        --db      ${params.database_diamond} \\
        --out     ${sample_id}_matches.tsv \\
        --outfmt  6 qseqid qlen sseqid staxids pident length evalue \\
        --threads ${params.threads}
    """
}
