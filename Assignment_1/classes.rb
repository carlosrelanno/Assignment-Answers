require 'date'

class SeedStock
  # SeedStock objects contain information stored in seed_stock_data, and have access to the gene
  # information through a Gene object contained in @gene.
  # Also, they possess the plant method, which removes the amount of seeds planted from the @grams_remaining atribute.
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
    @grams_remaining = params.fetch(:grams_remaining, "unknown").to_i
  end
  
  def plant(n)
    if n <= 0 # Just to avoid changing the date if planting 0 seeds
      return
    end
    
    if @grams_remaining > n
      @grams_remaining -= n
    else
      puts "WARNING: we have run out of Seed Stock #{@seed_stock}"
      @grams_remaining = 0
    end
    @last_planted = DateTime.now.strftime "%d/%m/%Y" # Set today as the last planted date
  end   
end


class Gene
  # Gene objects contain the fields form in gene_information.
  attr_accessor :gene_id
  attr_accessor :gene_name
  attr_accessor :mutant_phenotype

  def initialize(params = {})
    @gene_id = params.fetch(:gene_id, "unknown")
    @gene_name = params.fetch(:gene_name, "unknown")
    @mutant_phenotype = params.fetch(:mutant_phenotype, "unknown")
  end
end


class HybridCross
  # Description
  attr_accessor :parent1
  attr_accessor :parent2
  attr_accessor :chi_sq
  
  def initialize(params = {})
    @parent1 = params.fetch(:parent1, 'unknown')
    @parent2 = params.fetch(:parent2, 'unknown')
    @f2_wild = params.fetch(:f2_wild, 'unknown').to_f
    @f2_p1 = params.fetch(:f2_p1, 'unknown').to_f
    @f2_p2 = params.fetch(:f2_p2, 'unknown').to_f
    @f2_p1p2 = params.fetch(:f2_p1p2, 'unknown').to_f
    
    # Things to calculate chi-squared
    total = @f2_wild + @f2_p1 + @f2_p2 + @f2_p1p2
    exp = total/4
    @chi_sq = (@f2_wild - exp)**2 +
             (@f2_p1 - exp)**2 +
             (@f2_p2 - exp)**2 +
             (@f2_p1p2 - exp)**2
    @chi_sq /= exp
  end  
end


class Database
  # The database object is capable of extract the information from all three data files and construct three
  # hashes containing objects for each item. The method write_database will create a new_stock_file with the
  # performed changes.
  attr_accessor :genes
  attr_accessor :crosses
  attr_accessor :stock
  
  def initialize(params={})
    # Process gene table
    @gene_info_file = params.fetch(:gene_info_file)
    @genes = Hash.new() # This will store all gene objects
    gene_information = IO.readlines(@gene_info_file)
    for item in gene_information[1..-1]
      item = item.chomp.split("\t")
      @genes[item[0].to_sym] = Gene.new(gene_id: item[0],
                                        gene_name: item[1],
                                        mutant_phenotype: item[2])
    end
    
    # Process seed stock table
    @seed_stock_file = params.fetch(:seed_stock_file)
    @stock = Hash.new()
    seed_stock_info = IO.readlines(@seed_stock_file)
    @seed_stock_header = seed_stock_info[0]
    for item in seed_stock_info[1..-1]
      item = item.chomp.split("\t")
      @stock[item[0].to_sym] = SeedStock.new(seed_stock: item[0],
                                             mutant_gene_id: item[1],
                                             last_planted: item[2],
                                             storage:item[3],
                                             grams_remaining: item[4],
                                             gene: @genes[item[1].to_sym])
    end
    
    # Process cross table
    @cross_file = params.fetch(:cross_file)
    @crosses = Hash.new() # This will store all cross objects
    cross_information = IO.readlines(@cross_file)
    for item in cross_information[1..-1]
      item = item.chomp.split("\t")
      @crosses[(item[0].to_s+"_"+item[1].to_s).to_sym] = HybridCross.new(parent1: @stock[item[0].to_sym],
                                                             parent2: @stock[item[1].to_sym],
                                                             f2_wild: item[2],
                                                             f2_p1: item[3],
                                                             f2_p2: item[4],
                                                             f2_p1p2: item[5])
    end
  end
  
  def write_database
    file = File.open(@seed_stock_file.gsub("seed_stock_data", "new_stock_file"), "w")
    file.write(@seed_stock_header)
    for item in @stock.values
      file.write("#{item.seed_stock}\t#{item.mutant_gene_id}\t#{item.last_planted}\t#{item.storage}\t#{item.grams_remaining}\n")
    end
    file.close
  end
end
