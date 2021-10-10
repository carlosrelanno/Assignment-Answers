require_relative './classes'

# Database creation
database = Database.new(gene_info_file: "/home/osboxes/Assignment-Answers/Assignment_1/StockDatabaseDataFiles/gene_information.tsv",
                        seed_stock_file: "/home/osboxes/Assignment-Answers/Assignment_1/StockDatabaseDataFiles/seed_stock_data.tsv",
                        cross_file: "/home/osboxes/Assignment-Answers/Assignment_1/StockDatabaseDataFiles/cross_data.tsv")

# Planting 7 seeds of each seed and updating into new_stock_file.tsv
for key in database.stock.keys
  database.stock[key].plant(7)
end
database.write_database