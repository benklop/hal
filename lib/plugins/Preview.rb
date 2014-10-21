require 'cinch'

class Cinch::Preview
  include Cinch::Plugin  

  set :prefix ''
  
  match /http(s?):\\\\(.+)/
  
  def execute(m, word)
    
  end
end