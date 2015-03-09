require 'cinch'
require 'ffi/hunspell'

class Cinch::Spelling
  include Cinch::Plugin 
  
  match /sp (.+)/
  
  listen_to :help, method: :help
  def help(m, prefix)
    if(prefix.nil?)
      prefix = ""
    end
    
    m.reply "#{prefix}Spelling !sp WORD - suggestions for spelling a word"
  end
  
  def execute(m, word)
    FFI::Hunspell.dict do |dict|
      m.reply "#{m.user.nick}: #{word} should be spelt #{dict.suggest(word)}"
    end
  end
end