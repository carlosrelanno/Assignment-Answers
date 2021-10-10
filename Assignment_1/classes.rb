class SeedStock
  attr_accessor :seed_stock
  attr_accessor :mutant_gene_id
  attr_accessor :last_planted
  attr_accessor :storage 
  attr_accessor :grams_remaining
  attr_accessor :gene


  def initialize(params={})
    @seed_stock = params.fetch(:seed_stock, "unknown")
    @mutant_gene_id = params.fetch(:mutant_gene_id, "unknown")
    @gene = params.fetch(:gene, "unknown")
    @last_planted = params.fetch(:last_planted, "unknown")
    @storage = params.fetch(:storage, "unknown")
    @grams_remaining = params.fetch(:grams_remaining, "unknown")
    
  end
end


class Gene
  attr_accessor :gene_id
  attr_accessor :gene_name
  attr_accessor :mutant_phenotype

  
  def initialize(params = {})
    @gene_id = params.fetch(:gene_id, "unknown")
    @gene_name = params.fetch(:gene_name, "unknown")
    @mutant_phenotype = params.fetch(:mutant_phenotype, "unknown")
  end
end


class Database
  attr_accessor :genes
  attr_accessor :stock
  
  def initialize(params={})
    # Process gene table
    @gene_info_file = params.fetch(:gene_info_file)
    @genes = Hash.new() # This will store all gene objects
    gene_information = IO.readlines(@gene_info_file)
    for item in gene_information[1..-1]
      item = item.split("\t")
      @genes[item[0].to_sym] = Gene.new(gene_id: item[0],
                                        gene_name: item[1],
                                        mutant_phenotype: item[2])
    end 
    # Process seed stock table
    @seed_stock_file = params.fetch(:seed_stock_file)
    @stock = Hash.new()
    seed_stock_info = IO.readlines(@seed_stock_file)
    for item in seed_stock_info[1..-1]
      item = item.split("\t")
      @stock[item[0].to_sym] = SeedStock.new(seed_stock: item[0],
                                             mutant_gene_id: item[1],
                                             last_planted: item[2],
                                             storage:item[3],
                                             grams_remaining: item[4],
                                             gene: @genes[item[1].to_sym])
    end
  end
end
