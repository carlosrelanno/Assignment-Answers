require_relative './classes'
require 'rest-client'

def fetch(url, headers = {accept: "*/*"}, user = "", pass="")
  response = RestClient::Request.execute({
    method: :get,
    url: url.to_s,
    user: user,
    password: pass,
    headers: headers})
  return response
  
  rescue RestClient::ExceptionWithResponse => e
    $stderr.puts e.inspect
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
  rescue RestClient::Exception => e
    $stderr.puts e.inspect
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
  rescue Exception => e
    $stderr.puts e.inspect
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
end



class AnnotatedGene < Gene
  def initialize(params = {})
    super(params)
    @dna_seq = ''
    @prot_seq = ''
    
  end
end


database = Database.new(gene_info_file: "/home/osboxes/Assignment-Answers/Assignment_1/StockDatabaseDataFiles/gene_information.tsv",
                        seed_stock_file: "/home/osboxes/Assignment-Answers/Assignment_1/StockDatabaseDataFiles/seed_stock_data.tsv",
                        cross_file: "/home/osboxes/Assignment-Answers/Assignment_1/StockDatabaseDataFiles/cross_data.tsv")

for gene in database.genes.values
  data = fetch("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=fasta&id=#{gene.gene_id}")
  puts data.body
end
