require 'cinch'
require 'net/http'
require 'json'
require 'uri'

class Cinch::Preview
  include Cinch::Plugin  

  set(:prefix,'')
  
  match /http(s?):\/\/(.+)/i, use_prefix: false, method: :preview
  
  listen_to :help, method: :help
  
  def help(m, prefix)
    if(prefix.nil?)
      prefix = ""
    end
    
    m.reply "#{prefix}Preview - preview links"
  end
  
  def preview(m, match)
    
    prev_url = m.message.strip
    #some URLs need ot be modified
    if(prev_url.include?("imgur.com"))
      prev_url.sub!('.jpg','')
      prev_url.sub!('.png','')
      prev_url.sub!('.gif','')
      prev_url.sub!('i.','')
    end
    url = "http://readability.com/api/content/v1/parser?url=#{URI.encode(prev_url)}&token=#{config[:token]}"
    print "grabbing #{url}"
    begin
      resp = Net::HTTP.get_response(URI.parse(url)) # get_response takes an URI object
    
      data = JSON.parse(resp.body)
      if(prev_url.include?("imgur.com"))
	m.reply "::IMGUR:: #{data["title"]}: #{prev_url}"
      else
	if(data["dek"].nil?)
	  m.reply "::URL:: #{data["title"]}: #{data["excerpt"].sub('&hellip;', '...')}"
	else
	  m.reply "::URL:: #{data["title"]}: #{data["dek"]}"
	end
      end

    rescue
      print "Connection error."
    end
    
  end
end