require 'cinch'
require 'yelp'

class Cinch::Food
  include Cinch::Plugin

  match 'snack', method: :snack
  match 'drink', method: :drink
  match /i.?m hungry/i, use_prefix: false, method: :snack
  match /i.?m thirsty/i, use_prefix: false, method: :drink
  match /lunch (.+)/, method: :lunch
  match 'lunch', method: :lunch
  match 'food', method: :lunch
  match /i hunger/i, use_prefix: false, method: :lunch
  listen_to :help, method: :help
  
  def unregister
    super
  end
  
  def help(m, prefix)
    if(prefix.nil?)
      prefix = ""
    end
    
    m.reply "#{prefix}Food !snack (i.?m hungry) - Recommend a snack"
    m.reply "#{prefix}Food !drink (i.?m thirsty) - Recommend a drink"
    m.reply "#{prefix}Food !lunch (i hunger) - Recommend a restaurant"
  end
  
  def snack(m)
    
      if(Time.now.hour > 11 && Time.now.hour < 14)
	lunch(m)
      else
        puts "getting a snack"
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
          "blueberry yogurt",
          "sandwich"]
        m.reply "#{m.user.nick} you should grab some #{snacks.sample}!"
      end
    

  end
  
  def drink(m)
    puts "getting a drink"
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
    m.reply "#{m.user.nick} you should grab a can of #{drinks.sample}!"
  end 

  def lunch(m, search = "lunch")
    puts "getting a lunch"
    yelp_client = Yelp::Client.new({consumer_key: config[:consumer_key],
                                    consumer_secret: config[:consumer_secret],
				    token: config[:token],
				    token_secret: config[:token_secret]})
    
    params = { term: search, 
               limit: 20, 
               category_filter: 'restaurants',
               radius_filter: 11265.4
             }
    coordinates = { latitude: 39.924023,
                    longitude: -105.113344
                  }
    response = yelp_client.search_by_coordinates(coordinates, params)
    chosen = response.businesses.sample
    stars = "*" * chosen.rating.round(0)
    m.reply "#{m.user.nick}: #{chosen.name} (#{stars}) looks like a good place to go for #{search}! #{(chosen.distance * 0.000621371).round(1)} mi. away - #{chosen.url}"
  end
  
end