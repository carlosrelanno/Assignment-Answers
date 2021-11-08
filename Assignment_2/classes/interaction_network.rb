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
  
    def annotate(all=true)
      if all
        to_annotate = @genes
      else
        to_annotate = @genes.select{|g| g.level == 1}
      end
      progressbar = ProgressBar.create(format: "%a %b\u{15E7}%i %p%% %t",
        progress_mark: ' ',
        remainder_mark: "\u{FF65}",
        total: to_annotate.length)
      to_annotate.each do |gene| 
        gene.annotate
        unless gene.annotations.kegg.nil?
          @kegg_annotations.merge!(gene.annotations.kegg)
        end
        unless gene.annotations.go.nil?
          @go_annotations.merge!(gene.annotations.go)
        end
        progressbar.increment
      end
      @kegg_annotations.sort_by{|k, v| k.match(/ath(\d+)/).to_s.to_i}
      @go_annotations.sort_by{|k, v| k.match(/GO:(\d+)/).to_s.to_i}
    end
  end
  