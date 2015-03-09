require 'cinch'
require 'net/http'
require 'json'
require 'uri'
require 'rubygems'
require 'nokogiri'

class Cinch::Shepherd
  include Cinch::Plugin 
  
  match /feed (.+)/
  
  listen_to :help, method: :help
  def help(m, prefix)
    if(prefix.nil?)
      prefix = ""
    end
    
    m.reply "#{prefix}Shepherd !feed URL - feed a url to the bot"
  end
  
  def execute(m, url)
    print "processing URL #{url}\n"
    prev_url = "http://readability.com/api/content/v1/parser?url=#{URI.encode(url)}&token=#{config[:token]}"
    resp = Net::HTTP.get_response(URI.parse(prev_url)) # get_response takes an URI object
    begin
      data = JSON.parse(resp.body)
      doc = Nokogiri::HTML(data["content"])
      doc.css('script, link').each { |node| node.remove }
      print doc.text.squeeze(" \n")
    rescue
    end
    
  end
end