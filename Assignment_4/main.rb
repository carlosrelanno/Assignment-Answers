require 'bio'
require 'stringio'

# Create factories
factory_pep = Bio::Blast.local('blastx', 'Databases/PEP')
factory_tair = Bio::Blast.local('tblastn', 'Databases/TAIR')

# Load fasta files
file = Bio::FlatFile.auto('Databases/TAIR10_cds_20101214_updated.fa')
entry = file.entries[0]
report = factory_pep.query(entry.seq)


report.each do |hit|
  puts hit.hit_id, hit.inspect(), '------------'
end
#  print "#{hit.hit_id} : evalue #{hit.evalue}\t#{hit.target_id} at "
#  puts "#{hit.lap_at}"   # this tells you start and end of both the query and the hit sequences
#  hit.each do |hsp|
#    puts hsp.qseq  # this is the gapped Alignment as text of the query
#    puts hsp.hseq  # this is the gapped Alignment as text of the hit
#  end
#end