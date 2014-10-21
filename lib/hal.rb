require 'cinch'
require 'yaml'


class Hal



  def add_plugins
    config_file = YAML.load_file(File.expand_path("etc/config.yml"))
    plugin_list = config_file["plugins"]
    puts "loading plugins #{plugin_list}"
    plugin_list.each do |plugin|
      load(File.expand_path("lib/plugins/#{plugin[0]}.rb"))
      @bot.plugins.register_plugin(Cinch.const_get(plugin[0]))
      @bot.config.plugins.options[Cinch.const_get(plugin[0])] = plugin[1]['config']
    end
  end

  def initialize
    @bot = Cinch::Bot.new do
      configure do |c|
        config_file = YAML.load_file(File.expand_path("etc/config.yml"))
        c.server = config_file["server"]
        c.channels = config_file["channels"]
        c.nick = config_file["nick"]
        c.user = config_file["user"]
      end
    end
    
    add_plugins

  end



  def start
    @bot.start
  end
end
