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

# 2. Create factories
factory_pep = Bio::Blast.local('blastx', 'Databases/PEP', '-e 10e-6')
factory_tair = Bio::Blast.local('tblastn', 'Databases/TAIR', '-e 10e-6')

# 3. Load fasta files
tair_file = Bio::FlatFile.auto(tair_path) # 35386 entries
pep_file = Bio::FlatFile.auto(pep_path) # 5146 entries

output = File.new('orthologs.txt', 'w')
output.puts "PEP_id\tTAIR_id\tPEP>TAIR_evalue\tTAIR>PEP_evalue"

orthologs = Hash.new()
# We will start with the pep entries, since there are less of them

count = 0
pep_file.each_entry() do |entry|
  count +=1
  break if count > 100
  report = factory_tair.query(entry) 
  
  next unless report.hits.any? # Skip if it does not find matches
  
  #puts entry.definition, entry.entry_id, "#{report.hits.length} hits found"
  first_hit = report.hits[0]
  #puts first_hit.evalue, first_hit.definition
  
  # Search the entry with the definition of the first hit
  hit = nil
  tair_file.rewind() # Reset file pointer to the start of the flatfile
  tair_file.each_entry() do |entry2|
    if first_hit.definition.split('|')[0].rstrip == entry2.entry_id
      #puts 'Best hit found in plant database'
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
  #puts best_second_hit.definition.split('|')[0]
  
  
  # Check if the hits are recyprocal
  if report2.hits[0].definition == entry.definition
    puts 'Found one!'
    orthologs[entry.entry_id] = hit.entry_id
    output.puts "#{entry.entry_id}\t#{hit.entry_id}\t#{first_hit.evalue}\t#{best_second_hit.evalue}" 
  end
  #puts "\n"
end

puts orthologs
output.close


