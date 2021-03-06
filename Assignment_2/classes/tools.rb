require 'rest-client'

class Tools
  # The class tools is a container for functions used to get information from databases
    def self.fetch(url, headers = {accept: "*/*"}, user = "", pass="")
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
    def self.get_inter(gene)
        out = self.fetch("http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{gene}?format=tab25")
        return out.split("\n")
    end
end
