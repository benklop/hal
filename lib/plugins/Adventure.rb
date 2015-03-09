require 'cinch'
require 'dorothy'
require 'nokogiri'

class Cinch::Adventure
  include Cinch::Plugin 
  
  set :prefix, /^~/
  
  match /!play (.+)/, use_prefix: false, method: :play
  match /(.+)/, method: :command
  
  @machine = nil
  
  listen_to :help, method: :help
  
  def help(m, prefix)
    if(prefix.nil?)
      prefix = ""
    end
    
    m.reply "#{prefix}Adventure (!play <game name>) GAME - play a text adventure game"
    m.reply "#{prefix}Adventure (~[command]) GAME - play a text adventure game"
  end
  
  def interpret_output(html, command = "")
    text = ""
    noko = Nokogiri::HTML(html)
    
    str = noko.xpath("//span").first.inner_text
    str[0] = ''
    str[1] = ''
    if str == command
      noko.first.delete
    end
    noko.css("br").each { |node| node.replace(" \n") }
    noko.xpath("//span").each do |ele|
      if noko.css(".normal").include?(ele)
	text << ele.inner_text
      elsif noko.css(".bold").include?(ele)
	text << "\u0002" + ele.inner_text + "\u000F"
      elsif noko.css(".italic").include?(ele)
	text << "\u0016" + ele.inner_text + "\u000F"
      elsif noko.css(".underline").include?(ele)
	text << "\u001F" + ele.inner_text + "\u000F"
      elsif noko.css(".reverse").include?(ele)
	text << "\u0016" + ele.inner_text + "\u000F\n"
      else
	text << ele.inner_text
      end
    end
    puts text
    text
  end
  
  def play(m, program)
    m.reply "\u0002Prefix all commands to the game with a '~'!\u000F"
    m.reply "Loaded " + program
    @machine = Z::Machine.new(config[:path] + program)
    @machine.run
    @machine.screen.lower.remove_prompt
    puts @machine.screen.lower.to_html
    output = @machine.screen.lower.to_html
    @machine.screen.clear
    final = interpret_output(output)
    m.reply final
  end
  

  
  def command(m)
    msg = m.message
    msg[0] = ''
    puts "running command" + m.message
    @machine.keyboard << m.message << "\n"
    @machine.run
    @machine.screen.lower.remove_prompt
    puts @machine.screen.lower.to_html
    output = @machine.screen.lower.to_html
    @machine.screen.clear
    
    m.reply interpret_output(output, msg)
  end
end