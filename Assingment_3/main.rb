require_relative 'crr_lasses/repeat_finder.rb'
require_relative 'crr_lasses/gff_writer.rb'
require 'ruby-progressbar'

file = IO.readlines('files\ArabidopsisSubNetwork_GeneList.txt', chomp: true)

progressbar = ProgressBar.create(format: "%a %b\u{15E7}%i %p%% %t", progress_mark: ' ', remainder_mark: "\u{FF65}", total: file.length)

gff_writer = GffWriter.new

# Find cttctt repeats in the exons of the genes and create features
file.each do |gene| 
    gff_writer.entries[gene] = RepeatFinder.new(gene: gene, match: 'cttctt').entry
    progressbar.increment
end

# Save the local (gene by gene) gff3 file
gff_writer.save_gff

# Report genes without the cttctt repeat
no_rep_file = File.open('files\no_repeat_genes.txt', 'w')
no_rep_file.puts "## Genes without exonic cttctt repeat"
gff_writer.entries.each do |id, entry|
    next if entry.features.select{|f| f.feature == 'kebab_repeat'}.any?
    no_rep_file.puts id
end
no_rep_file.close

# Save the genomic locations gff3 file
gff_writer.save_genomic_gff
