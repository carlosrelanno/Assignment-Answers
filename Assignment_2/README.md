# Gene interacion network builder
For Bioinformatics Programming Challenges, 2021

## Description
This program tries to find the interaction networks that link genes from an input file. It will also annotate the found networks using both KEGG and GO pathways. The results are saved in the `Files\report.txt` file.
## Usage
The `Networker` is the main component of this program. It accepts multiple arguments when creating an instance:
* `gene_list`: the list containing the genes to process.
* `threshold`: interaction score threshold (0 - 1).
* `depth`: the depth of the network. Values higher than 3 could increase too much the proccessing time.
* `all_annotations`: wether to annotate all genes in a network or just the ones from the original gene list (true = all)

## Results
**Regarding threshold settings:** No gene interaction threshold increases enormously the workload, and does not give reliable information about the interaction. For this analysis I chose a `threshold: 0.45`.

Using a `depth: 2` the program returns a network containing 10 original genes form the original 168 ones (see report at `Files\report_2lev.txt`). Using a `depth: 3` we obtain a network that contains 14 of the original genes (see report at `Files\report_3lev.txt`). Although the number of connected genes seems low compared to the total 168, it is important to note that only 23 genes from the list have interactions with other ones above the previously mentioned threshold. These results seem to point towards a relation between these 14 upregulated and interacting gene products, although more candidates could be linked by other forms of interaction like genetic regulation.