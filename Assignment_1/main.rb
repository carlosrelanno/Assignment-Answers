# Import objects
require_relative './classes'

# Input files
if ARGV.length == 4 # If the name of the output stock file is given, the program will use that. If not, it will set one by default.
  gene_file, stock_file, cross_file, output_file = ARGV
else
  gene_file, stock_file, cross_file, output_file = ARGV << "new_stock_file.tsv"
end

# Database creation
# Automatically, the linked genes are analysed
database = Database.new(gene_info_file: gene_file,
                        seed_stock_file: stock_file,
                        cross_file: cross_file)

# Planting 7 seeds of each seed and updating into new_stock_file.tsv
for seed in database.stock.values
  seed.plant(7)
end
database.write_database(path='./StockDatabaseDataFiles', output_file)

# Getting a gene linkage report
database.linkage_report