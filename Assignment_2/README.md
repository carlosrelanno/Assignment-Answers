# Gene interacion network builder
For Bioinformatics Programming Challenges, 2021

## Description
This program tries to find the interaction networks that link genes from an input file. It will also annotate the found networks using both KEGG and GO pathways. The results are saved in the `Files\report.txt` file.
## Usage
The `Networker` is the main component of this program. It accepts multiple arguments when creating an instance:
gene_list: gene_list[0, 40], threshold: 0.45, depth: 2, all_annotations: false
* `gene_list`: the list containing the genes to process.
* `threshold`: interaction score threshold (0 - 1).
* `depth`: the depth of the network. Values higher than 3 could increase too much the proccessing time.
* `all_annotations`: wether to annotate all genes in a network or just the ones from the original gene list (true = all)

## Results
