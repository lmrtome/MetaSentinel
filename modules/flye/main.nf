process DENOVO_ASSEMBLY {
    
    tag "${sample_id}"

    conda "${moduleDir}/environment.yml"

    errorStrategy 'ignore'

    input:
    tuple val(sample_id), path(trimming_results)

    output:
     tuple val(sample_id), path("${sample_id}_flye/assembly.fasta"), emit: contigs

    script:
    """
    flye --${params.read_type} ${trimming_results} -o ${sample_id}_flye --threads ${params.threads} --meta 
    """
}
