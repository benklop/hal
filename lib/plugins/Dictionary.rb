require 'cinch'
require 'mw_dictionary_api'

class Cinch::Dictionary
  include Cinch::Plugin 
  
  match /def (.+)/
  match /define (.+)/
  
  @@word_hash = {}
  
  listen_to :help, method: :help
  def help(m, prefix)
    if(prefix.nil?)
      prefix = ""
    end
    
    m.reply "#{prefix}Dictionary (!define|!def) WORD - Define a word"
  end
  
  def execute(m, word)
      puts "defining #{word}"
      api_key = config[:api_key] || raise("Missing required argument: :api_key")
      client = MWDictionaryAPI::Client.new(api_key)
      client.api_type = 'collegiate'
      
      result = client.search(word)
      
      puts result.to_yaml
    
      if(result.entries.count == 0)
	m.reply "did you mean one of: #{result.suggestions.to_s}?"
      else
	if(@@word_hash.has_key?(word))
	  @@word_hash[word] += 1
	  if(@@word_hash[word].to_i + 1 > result.entries.count)
	    @@word_hash[word] = 0
	  end
	else
	  @@word_hash[word] = 0
	end
	entry = result.entries[@@word_hash[word]]
	word_s = entry[:head_word]
	pronunciation = entry[:pronunciation].nil? ? "" : " (#{entry[:pronunciation]})"
	pos = entry[:part_of_speech]
	
	m.reply "#{word_s}#{pronunciation}, #{pos}:"
	entry[:definitions].each do |definition|
	  num = definition[:sense_number].to_i.zero? ? "" : "#{definition[:sense_number]}) "
	  text = definition[:text]
	  text[0] = ''
	  m.reply "#{num}#{definition[:text]}"
	  unless definition[:verbal_illustration].nil?
	    m.reply "illust: #{definition[:verbal_illustration]}"
	  end
	end
	if(result.entries.count > 1 && @@word_hash[word].to_i < result.entries.count)
	  m.reply "Run '!def #{word}' again to get the next definition. (#{@@word_hash[word] + 1} of #{result.entries.length})"
	end
      end
  end
end