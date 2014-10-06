require 'cinch'
require 'yaml'



class Hal
  config = YAML.load_file(File.expand_path("etc/config.yml"))
  def initialize
    @bot = Cinch::Bot.new do
      configure do |c|
        c.server = config['server']
        c.channels = config['channels']
        c.nick = config['nick']
      end

      on :message, /^(hello|hi)/i do |m|
        m.reply "Hello, #{m.user.nick}"
      end

      on :message, /^(thanks.? hal|thank you.? hal)/i do |m|
        m.reply "You're welcome, #{m.user.nick}"
      end


      snacks = [
          "beef jerky",
          "pretzels",
          "sun chips",
          "boulder chips",
          "raisins",
          "cookies",
          "cheese",
          "pirate booty",
          "hummus crisps",
          "popcorn",
          "jalapeno chips",
          "peanuts",
          "cashews",
          "M&Ms",
          "trail mix",
          "strawberry yogurt",
          "blueberry yogurt"]

      on :message, /^(!snack|i.?m hungry)$/i do |m|
        m.reply "#{m.user.nick} you should grab some #{snacks.sample}!"
      end

      drinks = [
          "mountin dew",
          "diet mountain dew",
          "pepsi",
          "pepsi next",
          "dr. pepper",
          "diet dr. pepper",
          "coca cola",
          "diet coca cola",
          "fresca",
          "lemon seltzer",
          "lime seltzer",
          "peach seltzer",
          "berry seltzer",
          "root beer",
          "orange juice",
          "apple juice",
          "v8"]

      on :message, /^(!drink|i.m thirsty)$/i do |m|
        m.reply "#{m.user.nick} you should grab a can of #{drinks.sample}!"
      end
    end
  end

  def add_plugins
    plugin_list = config['plugins']
    plugin_list.each do |plugin|
      load(File.expand_path("lib/plugins/#{plugin}.rb"))
      @bot.configuration.plugins.plugins.push(plugin)
    end
  end

  initialize()
  add_plugins()
  @bot.start
end