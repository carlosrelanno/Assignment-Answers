require_relative '.\classes\networker.rb'

# 1. Load genes from file
if ARGV.length < 1
    puts 'This program requires a gene list file to work. Please specify one!'
    exit
end
file = ARGV[0]
gene_list = File.open(file, 'r').readlines()
gene_list = gene_list.map{|x| x.chomp.upcase}

# 2. Start the Networker object
net = Networker.new(gene_list: gene_list, threshold: 0.45, depth: 3, all_annotations: false)

# 3. The results are saved in Files\report.txt
# Please read usage and results in the README.md file