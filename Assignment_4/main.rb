require 'bio'
require 'stringio'

# 1. Create the databases
tair_path = 'Databases/TAIR10_cds_20101214_updated.fa' # DNA
pep_path = 'Databases/pep.fa' # Protein

# These bash commands check if some of the database files already exist. If not, the databases are created
puts `[ ! -f Databases/TAIR.nin ] && makeblastdb -in #{tair_path} -dbtype 'nucl' -out Databases/TAIR`
puts `[ ! -f Databases/PEP.pin ] && makeblastdb -in #{pep_path} -dbtype 'prot' -out Databases/PEP`
puts 'Databases created'

# 2. Create factories
factory_pep = Bio::Blast.local('blastx', 'Databases/PEP', '-e 10e-6')
factory_tair = Bio::Blast.local('tblastn', 'Databases/TAIR', '-e 10e-6')

# 3. Load fasta files
tair_file = Bio::FlatFile.auto(tair_path) # 35386 entries
pep_file = Bio::FlatFile.auto(pep_path) # 5146 entries


# We will start with the pep entries, since there are less of them

pep_file.each_entry() do |entry|
  report = factory_tair.query(entry) 
  
  next unless report.hits.any? # Skip if it does not find matches
  
  puts entry.definition, entry.entry_id, "#{report.hits.length} hits found"
  first_hit = report.hits[0]
  #puts first_hit.evalue, first_hit.definition
  
  # Search the entry with the definition of the first hit
  hit = nil
  tair_file.rewind()
  tair_file.each_entry() do |entry2|
    if first_hit.definition.split('|')[0].rstrip == entry2.entry_id
      puts 'Best hit found in plant database'
      hit = entry2
      break
    end
  end
  
  if hit.nil?
    puts 'Could not find the best hit in the database'
    puts first_hit.definition, "\n"
    next
  end
  
  # Query the best hit against the pep database
  report2 = factory_pep.query(hit)
  puts "#{report2.hits.length} hits found"
  best_second_hit = report2.hits[0]
  puts best_second_hit.definition.split('|')[0]
  if report2.hits[0].definition == entry.definition
    puts 'OJOOOO', report2.hits[0].definition, entry.definition
  end
  puts "\n"
end
#  print "#{hit.hit_id} : evalue #{hit.evalue}\t#{hit.target_id} at "
#  puts "#{hit.lap_at}"   # this tells you start and end of both the query and the hit sequences
#  hit.each do |hsp|
#    puts hsp.qseq  # this is the gapped Alignment as text of the query
#    puts hsp.hseq  # this is the gapped Alignment as text of the hit
#  end
#end