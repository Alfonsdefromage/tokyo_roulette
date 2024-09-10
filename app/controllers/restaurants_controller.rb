class RestaurantsController < ApplicationController
  skip_before_action :authenticate_user!
  require "nokogiri"
  require "open-uri"

  TOKYO_WARDS = {
    "Chiyoda" => "千代田",
    "Chuo" => "中央",
    "Minato" => "港",
    "Shinjuku" => "新宿",
    "Bunkyo" => "文京",
    "Taito" => "台東",
    "Sumida" => "墨田",
    "Koto" => "江東",
    "Shinagawa" => "品川",
    "Meguro" => "目黒",
    "Ota" => "大田",
    "Setagaya" => "世田谷",
    "Shibuya" => "渋谷",
    "Nakano" => "中野",
    "Suginami" => "杉並",
    "Toshima" => "豊島",
    "Kita" => "北",
    "Arakawa" => "荒川",
    "Itabashi" => "板橋",
    "Nerima" => "練馬",
    "Adachi" => "足立",
    "Katsushika" => "葛飾",
    "Edogawa" => "江戸川"
  }

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
    @tokyo_wards = TOKYO_WARDS
    @categories = CATEGORIES
  end

  def create
    roulette
    redirect_to restaurants_roulette_path # Replace with the actual path or URL you want to redirect to
  end

  def roulette
    location = "渋谷"
    category = "イタリアン"

    url = "https://r.gnavi.co.jp/area/jp/rs/?fw=#{category}&fwp=#{location}" # the url of the web page you want to scrape
    encoded_url = URI::DEFAULT_PARSER.escape(url)
    html = URI.open(encoded_url) # open the html of the page
    doc = Nokogiri::HTML.parse(html) # create a nokogiri doc based on that html

    restaurants = doc.search(".style_wrap___kTYa").map do |element|
      element.at_css('a')&.[]('href')
    end
    restaurant_url = restaurants.sample # get a random restaurant from the list

    html = URI.open(restaurant_url) # open the html of the page
    doc = Nokogiri::HTML.parse(html) # create a nokogiri doc based on that html

    @restaurant =
      {
        name: doc.at("#info-name").text.strip,
        address: doc.at(".adr.slink").text.strip.gsub(/\s+/, ' '),
      }

    restaurant_photos = "https://r.gnavi.co.jp/5t6hnafj0000/photo/"
    html_photos = URI.open(restaurant_photos) # open the html of the page
    doc_photos = Nokogiri::HTML.parse(html_photos) # create a nokogiri doc based on that html

    photos = doc_photos.search(".t4").map do |element|
      element.at_css('img')&.[]('src')
    end

    @photos = photos.sample(5) # get 5 random photos from the list
  end

  private

  def restaurant_params
    params.require(:restaurant).permit(:location, :category)
  end
end
