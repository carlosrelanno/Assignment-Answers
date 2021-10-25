require_relative '.\classes.rb'

# 1. Load genes
gene_list = File.open('Files\ArabidopsisSubNetwork_GeneList.txt', 'r').readlines()
gene_list = gene_list.map{|x| x.chomp.upcase}

# 2. Get all data from interaction
# 3. Create connex objects

net = Networker.new(gene_list: gene_list)
