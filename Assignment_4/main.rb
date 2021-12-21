require 'bio'
require 'stringio'
require 'ruby-progressbar'

# Create the databases
tair_path = 'Databases/TAIR10_cds_20101214_updated.fa' # DNA
pep_path = 'Databases/pep.fa' # Protein

# These bash commands check if some of the database files already exist. If not, the databases are created
puts `[ ! -f Databases/TAIR.nin ] && makeblastdb -in #{tair_path} -dbtype 'nucl' -out Databases/TAIR`
puts `[ ! -f Databases/PEP.pin ] && makeblastdb -in #{pep_path} -dbtype 'prot' -out Databases/PEP`
puts 'Databases created'

# Create factories
factory_pep = Bio::Blast.local('blastx', 'Databases/PEP', '-e 10e-6 -F ‘‘m S’’')
factory_tair = Bio::Blast.local('tblastn', 'Databases/TAIR', '-e 10e-6 -F ‘‘m S’’')

# Load fasta files
tair_file = Bio::FlatFile.auto(tair_path) # 35386 entries
pep_file = Bio::FlatFile.auto(pep_path) # 5146 entries

output = File.new('orthologs.txt', 'w') # Output file
output.puts "PEP_id\tTAIR_id\tPEP>TAIR_evalue\tPEP>TAIR_cover\tTAIR>PEP_evalue\tTAIR>PEP_cover"

orthologs = Hash.new()
# We will start with the pep entries, since there are less of them

count = 0
pep_file.each_entry() do |entry|
  puts count
  count +=1
  report = factory_tair.query(entry) 
  
  next unless report.hits.any? # Skip if it does not find matches
  
  first_hit = report.hits[0]
  next unless first_hit.respond_to? :query_end
  coverage = (first_hit.query_end.to_f - first_hit.query_start.to_f)/first_hit.query_len.to_f
  next if coverage < 0.5
  
  # Search the entry with the definition of the first hit
  hit = nil
  tair_file.rewind() # Reset file pointer to the start of the flatfile
  tair_file.each_entry() do |entry2|
    if first_hit.definition.split('|')[0].rstrip == entry2.entry_id
      hit = entry2
      break
    end
  end
  
  if hit.nil?
    puts 'Could not find the best hit in the database'
    puts first_hit.definition, "\n"
    exit()
  end
  
  # Query the best hit against the pep database
  report2 = factory_pep.query(hit)
  #puts "#{report2.hits.length} hits found"
  best_second_hit = report2.hits[0]
  next unless best_second_hit.respond_to? :query_end # Sometimes I got a 'nil class does not have this method' error
  coverage_back = (best_second_hit.query_end.to_f - best_second_hit.query_start.to_f)/best_second_hit.query_len.to_f
  next if coverage_back < 0.5
  
  
  # Check if the hits are recyprocal
  if report2.hits[0].definition == entry.definition
    puts 'Found one!'
    orthologs[entry.entry_id] = hit.entry_id
    output.puts "#{entry.entry_id}\t#{hit.entry_id}\t#{first_hit.evalue}\t#{coverage.round(3)}\t#{best_second_hit.evalue}\t#{coverage_back.round(3)}" 
  end
end

puts orthologs
puts orthologs.keys.length
output.close


