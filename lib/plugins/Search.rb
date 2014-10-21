require 'cinch'
require 'google-search'
require 'htmlentities'

class Cinch::Search
  include Cinch::Plugin
  
  #plugin_name = "Search"
  
  match /google (.+)/, method: :websearch
  match /gg (.+)/, method: :websearch
  match /^(hal|Hal).? (.+)\?$/, use_prefix: false, method: :websearchtext
  @@lastsearch = nil
  
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
