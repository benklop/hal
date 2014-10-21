require 'cinch'
require 'ffi/hunspell'

class Cinch::Spelling
  include Cinch::Plugin 
  
  match /sp (.+)/
  
  def execute(m, word)
    FFI::Hunspell.dict do |dict|
      m.reply "#{m.user.nick}: #{word} should be spelt #{dict.suggest(word)}"
    end
  end
end