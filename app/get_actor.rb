require 'httparty'
require 'nokogiri'

class GetActor
  ACTOR_URL = 'http://www.rottentomatoes.com/celebrity/%s'
  REDIS_PREFIX = 'ROTTEN_ACTORS_'

  def self.query_actor(id)
    GetActor.new(id).query_image
  end

  def initialize(id)
    @id = id
    @image = load_from_cache || nil
  end

  def query_image
    return @image unless @image.nil?
    response = HTTParty.get ACTOR_URL % @id
    if response.code == 200
      document = Nokogiri::HTML(response.body)
      #document.search('link[rel=image_src]').attr('href').value
      @image = document.search('#mainImage').attr('src').value
      save_to_cache
      return @image
    else
      nil
    end
  end

  def load_from_cache
    REDIS.get(REDIS_PREFIX + @id)
  end

  def save_to_cache
    REDIS.setnx(REDIS_PREFIX + @id, @image)
  end


end