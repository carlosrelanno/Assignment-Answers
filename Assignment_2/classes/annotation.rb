require_relative '.\tools.rb'
require 'json'

class Annotation 
    attr_accessor :kegg
    attr_accessor :go
    def initialize(gene_id)
        @gene_id = gene_id
        @kegg = Hash.new 
        @go = Hash.new
        annotate
    end

    def annotate
        # Get kegg
        data = Tools.fetch("http://togows.org/entry/kegg-genes/ath:#{@gene_id}/pathways.json")
        data = JSON.parse(data)
        @kegg = data[0]

        # Get GO
        data = Tools.fetch("http://togows.org/entry/ebi-uniprot/#{@gene_id}/dr.json")
        data = JSON.parse(data)
        data = data[0]['GO']
        unless data.nil?
            data.each do |g|
                if g[1].match(/^P:/)
                    @go[g[0]] = g[1].to_s
                end
            end
        end
    end
end
