require 'rest-client'
# == Tools
#
# This class is a collection of tools to use in various assingments
#
# == Summary
# 
# It contains functions to get data from the web. Used too in assingment 2
#

class Tools

  # Get the content of a query url

  # @param url [String] the source url
  # @return [String] the content of the webpage
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
end
