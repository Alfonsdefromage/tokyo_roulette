class RestaurantsController < ApplicationController
  skip_before_action :authenticate_user!
  require "nokogiri"
  require "open-uri"
  require "uri"
  require "geocoder"
  require "deepl"

  CATEGORIES = {
    "Japanese" => "和食",
    "Sushi" => "寿司",
    "Ramen" => "ラーメン",
    "Yakitori" => "焼き鳥",
    "Chinese" => "中華",
    "Italian" => "イタリアン",
    "Curry" => "カレー",
    "Izakaya" => "居酒屋",
  }

  def new
    @categories = CATEGORIES
  end

  def create
    roulette
    session[:restaurant] = @restaurant
    session[:photos] = @photos
    redirect_to restaurants_path
  end

  def index
    @restaurant = session[:restaurant]
    @photos = session[:photos]
  end


  def roulette
    user_location = tranlsation_to_japanese(scrapping_params[:location])
    user_category = scrapping_params[:category_kanji]
    category = URI.encode_www_form_component(user_category)
    place = URI.encode_www_form_component(user_location)
    # category = URI.encode_www_form_component("和食")

    url = "https://r.gnavi.co.jp/area/jp/rs/?fwp=#{place}&fw=#{category}&r=500"
    html = URI.open(url)
    doc = Nokogiri::HTML.parse(html)

    restaurants = doc.search(".style_wrap___kTYa").first(5).map do |element|
      element.at_css('a')&.[]('href')
    end
    restaurant_url = restaurants.sample

    html = URI.open(restaurant_url)
    doc = Nokogiri::HTML.parse(html)

    @restaurant =
      {
        name: doc.at("#info-name").text.strip,

        address: doc.at(".adr.slink").text.strip.gsub(/\s+/, ' '),
      }

    restaurant_photos = restaurant_url + "/photo/"
    html_photos = URI.open(restaurant_photos)
    doc_photos = Nokogiri::HTML.parse(html_photos)

    photos = doc_photos.search(".t4").map do |element|
      element.at_css('img')&.[]('src')
    end

    @photos = photos.sample(5)
  end

  private

  def tranlsation_to_japanese(text)
    DeepL.configure do |config|
      config.auth_key = ENV["DEEPL_AUTH_KEY"]
    end
    translation = DeepL.translate text, "EN", "JA"
    translation.text
  end

  def scrapping_params
    params.require(:scrapping_params).permit(:location, :category)
  end
end
