require_relative '.\classes.rb'

# 1. Load genes from file
gene_list = File.open('Files\ArabidopsisSubNetwork_GeneList.txt', 'r').readlines()
gene_list = gene_list.map{|x| x.chomp.upcase}

# 2. Start the Networker object
net = Networker.new(gene_list: gene_list, threshold: 0.5, depth: 3)