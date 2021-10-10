require_relative './classes'

database = Database.new(gene_info_file: "/home/osboxes/Assignment-Answers/Assignment_1/StockDatabaseDataFiles/gene_information.tsv",
                        seed_stock_file: "/home/osboxes/Assignment-Answers/Assignment_1/StockDatabaseDataFiles/seed_stock_data.tsv",
                        cross_file: "/home/osboxes/Assignment-Answers/Assignment_1/StockDatabaseDataFiles/cross_data.tsv")


puts database.stock.keys
puts database.stock[:A334].inspect