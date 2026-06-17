#!/usr/bin/env Rscript

library(ggplot2)
library(dplyr)
library(readr)

args <- commandArgs(trailingOnly = TRUE)
sample_id <- args[1]
input_file <- args[2]

if (length(args) < 2) {
  stop("Usage: Rscript plot_kraken2_top20.R <sample_id> <kraken2_report.txt>")
}

report <- read_tsv(input_file, col_names = FALSE, skip = 1, show_col_types = FALSE)
colnames(report) <- c("Percentage", "Reads_Clade", "Reads_Taxon", "Rank", "NCBI_Taxon_ID", "Name")

species <- report %>%
  filter(Rank == "S") %>%
  select(Name, Reads_Clade) %>%
  arrange(desc(Reads_Clade)) %>%
  head(20)

species <- species %>%
  mutate(Percentage = (Reads_Clade / sum(Reads_Clade)) * 100,
         Label = paste0(Reads_Clade, " (", round(Percentage, 1), "%)"))

p <- ggplot(species, aes(x = reorder(Name, Reads_Clade), y = Reads_Clade, fill = Reads_Clade)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_fill_gradient(low = "white", high = "darkgreen") +
  labs(title = paste("Top 20 species -", sample_id),
       x = "Species",
       y = "Number of classified reads") +
  scale_y_continuous(sec.axis = sec_axis(~ . / sum(species$Reads_Clade) * 100, name = "Percentage (%)")) +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

ggsave(paste0(sample_id, "_top20_plot.pdf"), plot = p, width = 6, height = 6)
