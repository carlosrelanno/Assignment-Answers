# Gene ortholog finder
This program finds the possible orthologs between two species. The E-value threshold (10e-6) and the filter (soft) were chosen according to previous literature (1). Also, only the alignments with a coverage greater than 50% were selected.

## Results
1870 possible orthologs were found. The gene names are stored in `orthologs.txt`. In this file, the E-values and coverages are stored for both the A to B blast and B to A.


1. Moreno-Hagelsieb G, Latimer K. Choosing BLAST options for better detection of orthologs as reciprocal best hits. Bioinformatics. 2008 Feb 1;24(3):319-24. doi: 10.1093/bioinformatics/btm585. Epub 2007 Nov 26. PMID: 18042555.