require 'cinch'
require 'google-search'
require 'htmlentities'
require 'nokogiri'

class Cinch::Search
  include Cinch::Plugin
  
  match /google (.+)/, method: :websearch
  match /gg (.+)/, method: :websearch
  match /^(hal|Hal).? (.+)\?$/, use_prefix: false, method: :websearchtext
  @@lastsearch = nil
  
  listen_to :help, method: :help
  def help(m, prefix)
    if(prefix.nil?)
      prefix = ""
    end
    
    m.reply "#{prefix}Search (!google|!gg) QUERY - search the web"
    m.reply "#{prefix}Search (hal|Hal) QUERY? - ask hal a question"
  end
  
  def search(query)
    search = Google::Search::Web.new do |search|
      search.query = query
      search.each_response { print '.'; $stdout.flush }
    end
    @@lastsearch = search
    search
  end

  def websearch(m, query)
    puts "searching #{query}"
    results = search(query)
    result = results.first
    txt = ("#{result.title} ( #{result.visible_uri} ) - #{result.content} [ #{result.uri} ]")
    txt.sub!("\n","")
    #term = txt.scan(/<b>([^<>]*)<\/b>/imu).flatten
    txt.sub!(/<b>/i, "\u0002")
    txt.sub!(/<\/b>/i, "\u000F")
    #reply = txt % Format(:bold, "#{term}")
    m.reply HTMLEntities.new.decode(txt)
  end
  
  def websearchtext(m, query)
    q = m.message.to_s
    q.sub!(/(hal|Hal).? /,"")
    q.sub!(/\?/,"")
    websearch(m, q)
  end
end
