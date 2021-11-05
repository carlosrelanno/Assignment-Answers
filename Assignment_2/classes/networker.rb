require_relative '.\gene.rb'
require_relative '.\interaction_network.rb'
require 'ruby-progressbar'
require 'enumerator'
# Progressbar from jfelchner avaliable at https://github.com/jfelchner/ruby-progressbar

class Networker
    def initialize(params={})
      @gene_list = params.fetch(:gene_list)
      @depth = params.fetch(:depth)
      @genes = Array.new
      @interactions = Array.new
      @networks = Array.new
      @threshold = params.fetch(:threshold)
  
      # Load genes from the original list
      puts "Initializing network constructor with #{@gene_list.length} genes..."
      puts "Depth: #{@depth}, interaction score threshold: #{@threshold}"
      puts "Loading 1st level interactions..."
      load_genes(@gene_list, level=1) 
      @genes.select! {|g| g.interactions.any?}
      load_interactions(@genes) # Get all interactions
      puts "Found: #{@interactions.length} unique interactions from #{@genes.length} genes"
  
      # Load and process genes from the second level
      if @depth > 1
        second_level_genes = @interactions.transpose[1]
        if second_level_genes.nil?
          puts "No genes with valid interactions were found. Exiting program."
          exit 
        end
        second_level_genes.uniq!
        puts "Loading 2nd level interactions..."
        load_genes(second_level_genes, level=2)
        @genes.select! {|g| g.interactions.any?}
        @genes.uniq!
        load_interactions(@genes.select {|g| g.level == 2})
        puts "Found: #{@interactions.length} unique interactions from #{@genes.length} genes"
      end
  
      #Load and process genes from the third level
      if @depth > 2
        third_level_genes = (@interactions.transpose[1].uniq! - @gene_list) - second_level_genes
        third_level_genes.uniq!
        puts "Loading 3rd level interactions..."
        load_genes(third_level_genes, level=3)
        @genes.select! {|g| g.interactions.any?}
        @genes.uniq!
        load_interactions(@genes.select {|g| g.level == 3})
        puts "Found: #{@interactions.length} unique interactions from #{@genes.length} genes"
      end
  
      # Cleaning...
      puts "Starting with #{@genes.length} genes from #{@depth} level(s)"
      # remove the interactions that occur with genes that are not in the first and second levels
      clean_genes
      # Eliminate second and third level genes with just an interaction
      @genes = @genes.reject {|g| g.level == 2 and g.interactions.length < 2} 
      @genes.reject! {|g| g.level == 3 and g.interactions.length < 2} 
      @genes = @genes.sort_by {|g| -g.interactions.length}
      clean_genes
      puts "Cleaned! #{@genes.length} genes remaining"
      ay = File.open('Files\ups.txt', 'w')
      @genes.each {|g| ay << g.id + "\t" + g.level.to_s + "\t" + g.interactions.length.to_s + "\n"}
      ay.close
      #exit
  
      # Network construction
      puts "Constructing networks..."
      @genes.each do |gene|
        unless @networks.any? {|n| n.genes.any? {|g| g.id == gene.id}}
          connex = Array.new
          connect(gene, connex)
          if connex.length > 1
            network = InteractionNetwork.new(interactions: connex, all_genes: @genes, original_list: @gene_list)
            @networks << network
          end
        end
      end
      @networks.select! {|n| n.genes.length > 1}
      @networks.uniq!(&:genes)
      puts "\n-----Results-----"
      @networks.each {|n| puts "Network involving #{n.genes.length} genes and #{n.interactions.length} interactions.\nContains #{n.original_genes.length} genes from the original #{@gene_list.length}-genes group\n-----------------\n"}
      save_report
      #exit # HEY
      # Annotate networks
      puts "Annotating..."
      @networks.each{|n| n.annotate}
      save_report
    end  
  
    def load_genes(list, level)
      progressbar = ProgressBar.create(format: "%a %b\u{15E7}%i %p%% %t",
        progress_mark: ' ',
        remainder_mark: "\u{FF65}",
        total: list.length)
      list.each do |gene|
        obj = Gene.new(id: gene, all_genes: @gene_list, level: level, threshold: @threshold)
        @genes << obj
        progressbar.increment
      end
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
        connect(gene2, net)
      end
    end
  
    def save_report
      file = File.open('Files\report.txt', 'w')
      time = Time.new
      file << "GENE INTERACTION NETWORK REPORT\n\n"
      file << "Date: #{time.strftime("%d/%m/%Y  %k:%M")}\n"
      file << "Number of genes in the original list: #{@gene_list.length}\n"
      file << "Interaction score threshold: #{@threshold}\n"
      file << "Depth level for analysis: #{@depth}\n\n"
      direct_interactions = Array.new
      @networks.each {|n| direct_interactions += n.lvl1_interactions}
      file << "Genes from the list interacting directly: #{direct_interactions.length}\n"
      if direct_interactions.any?
        direct_interactions.each {|i| file << "#{i[0]} interacts with #{i[1]} with score #{i[2]}\n"}
      end
      file << "\nFound networks: #{@networks.length}\n"
      if @networks.any?
        @networks.each do |n|
          file << "--------------------\n"
          file << "Network involving #{n.genes.length} genes and #{n.interactions.length} interactions. Contains #{n.original_genes.length} original genes.\n"
          if n.original_genes.any?
            file << "Original genes inside:\n"
            n.original_genes.each {|g| file << g.id + "\n"}
          end
          if n.kegg_annotations.any?
            file << "\nKEGG annotations for this network:\n"
            n.kegg_annotations.keys.each {|k| file << "#{k}\t#{n.kegg_annotations[k]}\n"}
          end
          if n.go_annotations.any?
            file << "\nGene ontology terms for this network:\n"
            n.go_annotations.keys.each {|k| file << "#{k}\t#{n.go_annotations[k]}\n"}
          end
        end
        file << "--------------------\n"
      end
      file.close
    end
  end