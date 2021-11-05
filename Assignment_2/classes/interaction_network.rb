require 'ruby-progressbar'

class InteractionNetwork
    attr_accessor :genes
    attr_accessor :interactions
    attr_accessor :original_genes
    attr_accessor :lvl1_interactions
    attr_accessor :go_annotations
    attr_accessor :kegg_annotations
    def initialize(params={})
      @original_list = params.fetch(:original_list)
      @all_genes = params.fetch(:all_genes)
      @interactions = params.fetch(:interactions)
      @genes = Array.new
      get_genes
      @original_genes = @genes.select {|g| g.level == 1}
      @lvl1_interactions= Array.new
      get_level1_interactions
      @go_annotations = Hash.new
      @kegg_annotations = Hash.new
      # gene_name = @genes.map {|g| g.id}.to_a
      # puts gene_name.length == gene_name.uniq!.length
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
      @genes = @genes.sort_by{|g| g.id}
    end
  
    def get_level1_interactions
      if @original_genes.any?
        @interactions.each do |i|
          if @original_list.include? i[0] and @original_list.include? i[1]
            @lvl1_interactions << i
          end
        end
      end
    end
  
    def annotate
      progressbar = ProgressBar.create(format: "%a %b\u{15E7}%i %p%% %t",
        progress_mark: ' ',
        remainder_mark: "\u{FF65}",
        total: @genes.length)
      @genes.each do |gene| 
        gene.get_kegg
        gene.get_go
        unless gene.kegg_pathways.nil?
          @kegg_annotations.merge!(gene.kegg_pathways)
        end
        unless gene.go.nil?
          @go_annotations.merge!(gene.go)
        end
        progressbar.increment
      end
      @kegg_annotations.sort_by{|k, v| k.match(/ath(\d+)/).to_s.to_i}
      @go_annotations.select! {|k, v| v.match(/^P:/)}
      @go_annotations.sort_by{|k, v| k.match(/GO:(\d+)/).to_s.to_i}
    end
  end
  