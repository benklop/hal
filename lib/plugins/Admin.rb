require 'cinch'
require 'yaml'

class Cinch::Admin
  include Cinch::Plugin
  
  
  match 'op', method: :op
  match 'auth', method: :auth
  match /auth (.+)/, method: :auth
  match 'decl', method: :decl
  match /deop (.+)/, method: :deop
  match /load (.+)/, method: :loadplug
  
  listen_to :join, method: :join
  listen_to :identified, method: :elevate
  listen_to :help, method: :help
  listen_to :connect, :method => :on_connect 

  
  def on_connect(*)
    @filemutex = Mutex.new
    @filepath = config[:file] || raise("Missing required argument: :file")
  end
    
  
  #help
  def help(m, prefix)
    if(prefix.nil?)
      prefix = ""
    end
    
    m.reply "#{prefix}Admin !op - Request Admin on channel"
    m.reply "#{prefix}Admin !auth - Grant Admin request"
    m.reply "#{prefix}Admin !decl - Decline Admin request"
    m.reply "#{prefix}Admin !deop NICK - Remove Admin"
    m.reply "#{prefix}Admin !load (PLUGNAME|all) - Reload plugin"
  end
  
  def unregister
    super
  end
  
  def loadplug(m, plug)
    # this needs to be reorganized so file load is actually first, followed by unloading the currently installed plugin, then loading it again. Should not unload if 
    # loading the file was not successful. This way we won't end up just unloading the plugin.
    
    
    if(is_admin?(m.user))
      m.reply "Unloading plugin if loaded"
      bot.plugins.each do |plugin|
	pname = plugin.class.name.split("::").last
	if plug == 'all' or plug == pname
	  m.reply "unloading Plugin #{pname}"
	  bot.plugins.unregister_plugin(plugin)
	end
      end
      m.reply "Loading plugin"
      
      if(plug == 'all')
	config_file = YAML.load_file(File.expand_path("etc/config.yml"))
        plugin_list = config_file["plugins"]
        puts plugin_list.to_yaml

	plugin_list.each do |plugin|
	  begin
	    load(File.expand_path("lib/plugins/#{plugin[0]}.rb"))
	    bot.plugins.register_plugin(Cinch.const_get(plugin[0]))
	    bot.config.plugins.options[Cinch.const_get(plugin[0])] = plugin[1]['config']
	    m.reply "Plugin #{plugin[0]} Loaded"
	  rescue
	    m.reply "Warning: plugin #{plug} did not load successfully!"
	  end
	end
      else
	begin
	  load(File.expand_path("lib/plugins/#{plug}.rb"))
	  bot.plugins.register_plugin(Cinch.const_get(plug))
	  
	  config_file = YAML.load_file(File.expand_path("etc/config.yml"))
	  plugin_list = config_file["plugins"]
	  #puts plugin_list.to_yaml
	  begin
	    plugin_list.each do |plugin|
	      if(plugin[0] == plug)
		puts plugin[1]['config']
		bot.config.plugins.options[Cinch.const_get(plug)] = plugin[1]['config']
	      end
	    end
	  rescue
	    m.reply "Warning: plugin #{plug} does not have a valid entry in the config file!"
	  end   
	  m.reply "Plugin #{plug} Loaded"
	rescue
	  m.reply "Warning: plugin #{plug} did not load successfully!"
	end
      end
    else
      m.reply "you don't have permission to load plugins"
    end
  end
  
  def elevate(m)
    m.bot.channels.each do |channel|
      User(config[:chanserv]).send("Op " + channel.name)
    end
  end


  def is_admin?(user)
    user.refresh
    puts "checking user list for #{user.nick}"
    @filemutex.synchronize do
      config_file = YAML.load_file(File.expand_path(@filepath))
      @@admins = config_file["admins"]
      @@admins.include?(user.nick)
    end
  end
    
  def save_config
    @filemutex.synchronize do
      config_file = YAML.load_file(File.expand_path(@filepath))
      config_file["admins"] = @@admins

      synchronize(:admin_config) do
	File.open(File.expand_path(@filepath), 'w') do |f|
	  YAML.dump(config_file, f)
	end
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
  
  def auth(m, nick = "")
    if is_admin?(m.user)
      puts "trying to op #{nick}"
      if nick.empty?
        user = @@tentative
      else
        user = User(nick)
      end
      puts "trying to op #{@@tentative}"
      @@admins.push(user.nick)
      @@admins.uniq!
      save_config
      m.reply "#{m.user.nick}: you have added '#{user.nick}' to the admins group!"
      m.channel.op(user) if is_admin?(user)
      @@tentative = ""
    else
      m.reply "#{m.user.nick}: you are not authorized!"
    end

  end
  
  def decl(m)
    if is_admin?(m.user)
      user = @@tentative
      m.reply "#{m.user.nick}: '#{user.nick}' request has been declined."
      @@tentative = ""
    else
      m.reply "#{m.user.nick}: you are not authorized!"
    end

  end
  
  def deauth(m, nick="")
    if is_admin?(m.user)
      unless nick.empty?
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
