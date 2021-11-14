require 'bio'
require_relative '.\tools.rb'

class RepeatFinder
    attr_accessor :gene_id
    attr_accessor :entry
    def initialize(params={})
        @gene_id = params.fetch(:gene)
        @search = params.fetch(:match, '')
        
        response = Tools.fetch("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{@gene_id}")
        @entry = Bio::EMBL.new(response.body)
        @gene_matches = Array.new
        # Search the pattern in the exons
        search_in_exons
        @gene_matches.uniq! 
        # Create the features
        @entry.to_biosequence
        add_features
    end

    def search_in_exons(search=@search)
        @entry.features.each do |feature|
            next unless feature.feature == 'exon' # Loop only over exons
            begin
                seq = @entry.seq.splice(feature.position) # This ensures the position notation is usable
            rescue
                next
            end
            positions = /(\d+)..(\d+)/.match(feature.position)
            exon_start, exon_end = positions.captures.map{|x| x.to_i}
            # puts "Exon start: #{exon_start}, end: #{exon_end}", feature.position
            match_datas = seq.seq.to_enum(:scan, /(?=(#{search}))/).map {Regexp.last_match} # Had to do this to get the overlapping matches
            unless match_datas.empty?
                match_datas.each do |m|
                    match_rel_start, match_rel_end = m.begin(0) + 1, m.begin(0) + 6 # CAREFUL
                    if feature.position.include?('complement')
                        match_gene_start = exon_end - match_rel_end + 1
                        match_gene_end = exon_end - match_rel_start + 1
                        match_pos = "complement(#{match_gene_start}..#{match_gene_end})"
                    else
                        match_gene_start = exon_start + match_rel_start - 1
                        match_gene_end = exon_start + match_rel_end - 1
                        match_pos = "#{match_gene_start}..#{match_gene_end}"
                    end
                    # puts @entry.seq.splice(match_pos) # As a control
                    @gene_matches << match_pos
                end
            end
        end
    end

    def add_features(name='kebab_repeat', positions=@gene_matches)
        positions.each do |pos|
            feature = Bio::Feature.new(name, pos)
            feature.append(Bio::Feature::Qualifier.new('repeat_motif', 'cttctt'))
            feature.append(Bio::Feature::Qualifier.new('note', 'found by seq finder by carlos'))
            if pos.include?('complement')
                feature.append(Bio::Feature::Qualifier.new('strand', '-'))
            else
                feature.append(Bio::Feature::Qualifier.new('strand', '+'))
            end
            @entry.features << feature
        end
    end
end

