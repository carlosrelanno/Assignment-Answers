require 'rest-client'
require 'ruby-progressbar'
require 'json'
# Progressbar from jfelchner avaliable at https://github.com/jfelchner/ruby-progressbar

class Tools
    def self.fetch(url, headers = {accept: "*/*"}, user = "", pass="")
        response = RestClient::Request.execute({
          method: :get,
          url: url.to_s,
          user: user,
          password: pass,
          headers: headers})
        return response
        
        rescue RestClient::ExceptionWithResponse => e
          $stderr.puts e.inspect
          response = false
          return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
        rescue RestClient::Exception => e
          $stderr.puts e.inspect
          response = false
          return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
        rescue Exception => e
          $stderr.puts e.inspect
          response = false
          return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
    end 
    def self.get_inter(gene)
        out = self.fetch("http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{gene}?format=tab25")
        return out.split("\n")
    end
end

class Gene
  attr_accessor :id
  attr_accessor :interactions
  attr_accessor :level

  def initialize(params={})
    @id = params.fetch(:id, false)
    @level = params.fetch(:level)
    @kegg_pathways = ''
    # @go
    @interactions = Array.new
    get_interactions
    clean_interactions
  end

  def get_interactions
    inter = Tools.get_inter(@id)
    inter.each do |i|
      id1uni, id2uni, c, d, id1, id2, *rest, score = i.split("\t")
      id1 = id1.match(/A[Tt]\d[Gg]\d\d\d\d\d/).to_s.upcase
      id2 = id2.match(/A[Tt]\d[Gg]\d\d\d\d\d/).to_s.upcase
      score = score.match(/\d+.\d+/).to_s
      if id1.upcase != @id.upcase # Some gene positions in intact are swapped
          id1, id2 = id2, id1
      end
      @interactions << [@id, id2, score]
    end
  end

  def clean_interactions
    @interactions.select! {|i| i[1] != ""} # Select all interactions that contain an arabidopsis gene
    @interactions.uniq! # remove duplicated interactions
    @interactions.select! {|i| i[1] != @id} # remove autointeractions
  end

  def get_kegg
    data = Tools.fetch("http://togows.org/entry/kegg-genes/ath:#{@id}/pathways.json")
    data = JSON.parse(data)
    @kegg_pathways = data
  end

  def get_go
    # data = Tools.fetch("http://togows.org/entry/kegg-genes/ath:#{@id}/pathways.json")
    # data = JSON.parse(data)
  end
end

class InteractionNetwork
  attr_accessor :genes
  attr_accessor :interactions
  attr_accessor :original_genes
  def initialize(params={})
    @all_genes = params.fetch(:all_genes)
    @interactions = params.fetch(:interactions)
    @genes = Array.new
    get_genes
    @original_genes = @genes.select {|g| g.level == 1}
  end

  def get_genes
    gene_names = Array.new
    @interactions.each do |i|
      gene_names << i[0]
      gene_names << i[1]
    end
    gene_names.uniq!
    gene_names.each do |name|
      @genes << @all_genes.select{|g| g.id == name}[0]
    end
  end

  def annotate
    progressbar = ProgressBar.create(format: "%a %b\u{15E7}%i %p%% %t",
      progress_mark: ' ',
      remainder_mark: "\u{FF65}",
      total: @genes.length)
    @genes.each {|gene| gene.get_kegg
                        gene.get_go
                        progressbar.increment}
    end
end

class Networker
  def initialize(params={})
    @gene_list = params.fetch(:gene_list)
    @genes = Array.new
    @interactions = Array.new
    @networks = Array.new

    # Load genes from the original list
    puts "Initializing network constructor with #{@gene_list.length} genes..."
    puts "Loading 1st level interactions..."
    load_genes(@gene_list, level=1) 
    @genes.select! {|g| g.interactions.any?}
    load_interactions(@genes) # Get all interactions
    puts "Found: #{@interactions.length} unique interactions from #{@genes.length} genes"

    # Load and process genes from the second level
    second_level_genes = @interactions.transpose[1]
    second_level_genes.uniq!
    puts "Loading 2nd level interactions..."
    load_genes(second_level_genes, level=2)
    @genes.select! {|g| g.interactions.any?}
    @genes.uniq!
    load_interactions(@genes.select {|g| g.level == 2})
    puts "Found: #{@interactions.length} unique interactions from #{@genes.length} genes"

    #Load and process genes from the third level
    third_level_genes = (@interactions.transpose[1] - @gene_list) - second_level_genes
    third_level_genes.uniq!
    puts "Loading 3rd level interactions..."
    load_genes(third_level_genes, level=3)
    @genes.select! {|g| g.interactions.any?}
    @genes.uniq!
    load_interactions(@genes.select {|g| g.level == 3})
    puts "Found: #{@interactions.length} unique interactions from #{@genes.length} genes"

    # Cleaning...
    puts "Starting with #{@genes.length} genes from 3 levels"
    # remove the interactions that occur with genes that are not in the first and second levels
    clean_genes
    # Eliminate second level genes with just an interaction
    @genes.reject! {|g| g.level == 3 and g.interactions.length < 2} 
    @genes = @genes.sort_by {|g| -g.interactions.length}
    clean_genes
    puts "Cleaned! #{@genes.length} genes remaining"
    
    # Network construction
    puts "Constructing networks..."
    @progressbar = ProgressBar.create(format: "%a %b\u{15E7}%i %p%% %t",
      progress_mark: ' ',
      remainder_mark: "\u{FF65}",
      total: @genes.map {|g| g.interactions.length}.to_a.inject(0, :+))
    @genes.each do |gene|
      unless @networks.any? {|n| n.genes.any? {|g| g.id == gene.id}}
        connex = Array.new
        connect(gene, connex)
        network = InteractionNetwork.new(interactions: connex, all_genes: @genes)
        @networks << network
      end
    end
    @networks.select! {|n| n.genes.length > 0}
    puts "\n-----Results-----"
    @networks.each {|n| puts "Network involving #{n.genes.length} genes and #{n.interactions.length} interactions.\nContains #{n.original_genes.length} genes from the original #{@gene_list.length}-genes group\n-----------------\n"}
  
    # Annotate networks
    puts "Annotating..."
    @networks.each{|n| n.annotate}
  end  

  def load_genes(list, level)
    progressbar = ProgressBar.create(format: "%a %b\u{15E7}%i %p%% %t",
      progress_mark: ' ',
      remainder_mark: "\u{FF65}",
      total: list.length)
    list.each do |gene|
      obj = Gene.new(id: gene, all_genes: @gene_list, level: level)
      @genes << obj
      progressbar.increment
  end

  def load_interactions(genes)
    genes.each do |gene|
      if gene.interactions.any?
        gene.interactions.each do |inter|
          @interactions << inter
        end
      end
    end
  end
  
  def save_interactions
    file = File.open('Files\net_interactions.txt', 'w')
    @interactions.each do |i|
      file << "#{i[0]}\t#{i[1]}\t#{i[2]}\n"
    end
    file.close
  end

  def save_genes
    file = File.open('Files\net_genes.txt', 'w')
    @genes.each do |g|
      file << "#{g.id}\n"
    end
    file.close
  end

  def clean_genes
    gene_names = Array.new
    @genes.each {|g| gene_names << g.id} # Create a record with all gene_names
    @genes.each do |gene|
      gene.interactions.select! {|i| gene_names.include?(i[1])} 
    end
  end

  def connect(gene, net)
    if net.length > 0
      if net.transpose[0].include? gene.id # If the gene has been already explored, the function stops here
        return
      end
    end
    gene.interactions.each do |inter|
      gene2 = @genes.select{|g| g.id == inter[1]}[0]
      if gene2.interactions.transpose[1].include? gene.id
        unless net.include? [inter[1], inter[0], inter[2]] 
          net << inter
        end
      end
      @progressbar.increment
      connect(gene2, net)
    end
  end
end
end