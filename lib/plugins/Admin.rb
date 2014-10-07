require 'cinch'
require 'yaml'

class Admin
  include Cinch::Plugin
  
  match 'op', method: :op
  match 'auth', method: :auth
  #match /^!auth.*/, method: :auth
  match 'decl', method: :decl
  match /^!deop .+/, method: :deop
  listen_to :join, method: :join
  listen_to :identified, method: :elevate

  def elevate(m)
    User("ChanServ@hybserv.eng.vmware.com").send("Op #trifecta")
  end

  def unregister
    save_config
  end

  def is_admin?(user)
    user.refresh
    puts "checking user list for #{user.nick}"
    config_file = YAML.load_file(File.expand_path("etc/admin.yml"))
    @@admins = config_file["admins"]

    @@admins.include?(user.nick)
  end
    
  def save_config
    config_file = YAML.load_file(File.expand_path("etc/admin.yml"))
    config_file["admins"] = @@admins

    synchronize(:admin_config) do
      File.open(File.expand_path("etc/admin.yml"), 'w') do |f|
        YAML.dump(config_file, f)
      end
    end  
  end
  
  def join(m)
    unless m.user.nick == bot.nick
      m.channel.op(m.user) if is_admin?(m.user)
    end
  end
  
  def op(m)
    @@tentative = m.user
    puts "trying to op #{@@tentative}"
    m.reply "A user with admin privileges must reply with '!auth' to allow you to become a permanent admin. '!decl' will decline."
  end
  
  def auth(m, nick=nil)
    if is_admin?(m.user)
      if nick.nil?
        user = @@tentative
      else
        user = User(nick)
      end
      puts "trying to op #{@@tentative}"
      @@admins.push(user.nick)
      save_config
      m.reply "#{m.user.nick}: you have added '#{user.nick}' to the admins group!"
      m.channel.op(user) if is_admin?(user)
      @@tentative = nil
    else
      m.reply "#{m.user.nick}: you are not authorized!"
    end

  end
  
  def decl(m)
    if is_admin?(m.user)
      user = @@tentative
      m.reply "#{m.user.nick}: '#{user.nick}' request has been declined."
      @@tentative = nil
    else
      m.reply "#{m.user.nick}: you are not authorized!"
    end

  end
  
  def deauth(m, nick=nil)
    if is_admin?(m.user)
      if not nick.nil?
        user = User(nick)
        if user.nil?
          m.reply "#{m.user.nick}: '#{nick}' is not a known nickname"
        else
          @@admins.delete(user.name)
          m.reply "#{m.user.nick}: '#{nick}' has been removed from the admins group!"
        end
      end
    else
      m.reply "#{m.user.nick}: you are not authorized!"
    end
  end
end
