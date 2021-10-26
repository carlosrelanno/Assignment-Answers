require_relative '.\classes.rb'
# Gene class experiments
gene = Gene.new(id: "AT2G13360", level: 1, threshold: 0.5)
gene.get_kegg
puts gene.kegg_pathways.values

gene.get_go
gene.go.keys.each {|k| print k, "\t", gene.go[k], "\n" }