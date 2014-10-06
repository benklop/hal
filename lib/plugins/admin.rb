require 'cinch'
require 'yaml'

class Admin
  include Cinch::Plugin
  
  match "op", method: :op
  match "auth", method: :auth
  match "decl", method: :decl
  match /^!deop .+/, method: :deop
  listen_to :join
  
  #load config data 
  def initialize(*args)
    super

    synchronize(:admin_config) do
      config = YAML.load_file("../../etc/admin.yml")
      @admins = config["ops"]
      @admins.empty? do
	@admins = ["benklop"]
      end
      def @@tentative
    end
  end
  
  def unregister
    save_config
  end
  
  helpers do
    def is_admin?(user)
      user.refresh
      true if @admins.include?(user.nick)
    end
    
    def save_config
      config["ops"] = op_users
    
      synchronize(:admin_config) do
	File.open("../../etc/admin.yml", 'w') do |f|
	  YAML.dump(data, f)
	end
      end
    end
      
  end
  
  def join(m, channel)
    unless m.user.nick == bot.nick
      channel.op(m.user) if is_admin?(m.user)
    end
  end
  
  def op(m)
    @@tentative = m;
    m.reply "Another user with admin privileges must reply with '!auth' to allow you to become a permanent admin. '!decl' will decline."
  end
  
  def auth(m)
  end
  
  def decl(m)
  end
  
  def deauth(m, nick)
    
  end
  
end