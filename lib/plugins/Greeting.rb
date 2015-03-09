require 'cinch'
require 'yaml'

class Cinch::Greeting
  include Cinch::Plugin
  
  #plugin_name = "Greeting"
  
  match /(^|^hal:.)(morning|good morning|afternoon|good afternoon|evening|good evening)(.?$|.+hal)/i, use_prefix: false, method: :join
  
  match /(^|\s)(hi|hello)($|([:,!\.\?]?\s)(hal|everyone))/i, use_prefix: false, method: :hello
  match /^hal[:,!\.\?]?\s(hi|hello)/i, use_prefix: false, method: :hello
  #match /^(hi|hello)$/i, use_prefix: false, method: :hello
  
  match /(^|^hal.+)(thanks|thank you)($|([:,!\.\?]?\s)hal)/i, use_prefix: false, method: :thanks
  match /(^helo|^ehlo)(.*)$/i, use_prefix: false, method: :smtp
  match /^syn$/i, use_prefix: false, method: :ack
  listen_to :join, method: :join
  listen_to :help, method: :help
  
    #help
  def help(m, prefix)
    if(prefix.nil?)
      prefix = ""
    end
    
    m.reply "#{prefix}Greeting good (morning|afternoon|evening)"
    m.reply "#{prefix}Greeting (hi|hello)"
    m.reply "#{prefix}Greeting thanks"
    m.reply "#{prefix}Greeting (HELO|EHLO) NAME - SMTP like hello and function list"
    m.reply "#{prefix}Greeting SYN - ACK"
  end
  
  def join(m)
    unless m.user.nick == bot.nick
      if(Time.now.hour < 5) 
	m.reply "You're here way too late / early #{m.user.nick}!"
      elsif(Time.now.hour < 12)
	m.reply "Good morning #{m.user.nick}!"
      elsif(Time.now.hour < 17)  
	m.reply "Good afternoon #{m.user.nick}!"
      elsif(Time.now.hour < 19)  
	m.reply "Good evening #{m.user.nick}!"
      else
	m.reply "Go Home #{m.user.nick}!"
      end
    end
  end
  
  def hello(m)
    unless m.user.nick == bot.nick
      m.reply "Hello, #{m.user.nick}"
    end
  end
  
  def thanks(m)
    m.reply "You're welcome, #{m.user.nick}"
  end
  
  def smtp(m, command, hname = "")
    if(command.downcase == "ehlo")
      if(hname.empty?)
	m.reply "501 Syntax: EHLO [your name]"
      else
	smtp(m, "helo", hname)
	m.reply "250 ehlo-plugin-help"
	@bot.handlers.dispatch :help, m, "250-"
      end
    elsif(command.downcase == "helo")
      if(hname.empty?)
	m.reply "501 Syntax: HELO [your name]"
      else
	hname.strip!
	m.reply "250 hal-9000.csl.illinois.edu Hello #{hname} [\"#{m.user.nick}\" #{m.user.user}@#{m.user.host}]"
      end
    end
  end
  
  def ack(m)
    m.reply "ACK"
  end
end