class GffWriter
    attr_accessor :entries
    def initialize
        @entries = Hash.new
    end

    def save_gff
        file = File.new('files\new_features.gff3', 'w')
        file.puts "##gff-version 3"
        @entries.each do |id, entry|
            next unless entry.features.select{|f| f.feature == 'kebab_repeat'}.any?
            entry.features.each do |feature|
                next unless feature.feature == 'kebab_repeat'
                file.print id, "\t" # 1. seqid
                file.print 'repeat_finder', "\t" # 2. Source
                file.print 'tandem_repeat', "\t" # 3. type (SO:0000705)
                positions = /(\d+)..(\d+)/.match(feature.position)
                ft_start, ft_end = positions.captures.map{|x| x.to_i}
                file.print ft_start, "\t" # 4. Start
                file.print ft_end, "\t" # 5. End
                file.print '.', "\t" # 6. Score
                file.print feature.assoc['strand'], "\t" # 7. Strand
                file.print '.', "\t" # 8. Phase
                file.print '.', "\n" # 9. Attributes
            end
        end
        file.puts "##FASTA"
        @entries.each do |id, entry|
            next unless entry.features.select{|f| f.feature == 'kebab_repeat'}.any?
            file.puts entry.seq.to_fasta(header=id)
        end
        file.close
    end

    def save_genomic_gff
        file = File.new('files\new_genomic_features.gff3', 'w')
        file.puts "##gff-version 3"
        @entries.each do |id, entry|
            next unless entry.features.select{|f| f.feature == 'kebab_repeat'}.any?
            entry.features.each do |feature|
                next unless feature.feature == 'kebab_repeat'
                file.print entry.entry, "\t" # 1. seqid
                file.print 'repeat_finder', "\t" # 2. Source
                file.print 'tandem_repeat', "\t" # 3. type (SO:0000705)
                positions = /(\d+)..(\d+)/.match(feature.position)
                ft_start, ft_end = positions.captures.map{|x| x.to_i}
                genomic_positions = /:\d:(\d+):(\d+):\d/.match(entry.ac[0])
                geno_start, geno_end = genomic_positions.captures.map{|x| x.to_i}
                file.print geno_start + ft_start - 1, "\t" # 4. Start
                file.print geno_start + ft_end -1, "\t" # 5. End
                file.print '.', "\t" # 6. Score
                file.print feature.assoc['strand'], "\t" # 7. Strand
                file.print '.', "\t" # 8. Phase
                file.print '.', "\n" # 9. Attributes
            end
        end
        file.puts "##FASTA"
        @entries.each do |id, entry|
            next unless entry.features.select{|f| f.feature == 'kebab_repeat'}.any?
            file.puts entry.seq.to_fasta(header="#{entry.ac[0]} (#{id})")
        end
        file.close
    end
end

