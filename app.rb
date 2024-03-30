require "sinatra"
require "sinatra/reloader"
require "http"

get("/") do
  "Welcome to Omnicalc 3"
  erb(:home)
end

get("/umbrella") do
  erb(:umbrella)
end

post("/process_umbrella") do
  @location = params.fetch("location")

  gmaps_key = ENV.fetch("GMAPS_KEY")
  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{@location}&key=#{gmaps_key}"

  gmaps_data = HTTP.get(gmaps_url)
  parsed_gmaps_data = JSON.parse(gmaps_data)
  gmaps_results_array = parsed_gmaps_data.fetch("results")
  first_result_hash = gmaps_results_array.at(0)
  geometry_hash = first_result_hash.fetch("geometry")
  location_hash = geometry_hash.fetch("location")

  @lat = location_hash.fetch("lat")
  @lon = location_hash.fetch("lng")

  pirates_key = ENV.fetch("PIRATE_WEATHER_KEY")
  pirates_url = "https://api.pirateweather.net/forecast/#{pirates_key}/#{@lat},#{@lon}"

  pirates_data = HTTP.get(pirates_url)
  parsed_pirates_data = JSON.parse(pirates_data)

  currently_hash = parsed_pirates_data.fetch("currently")
  @temp = currently_hash.fetch("temperature")

  @summary = "N/A"
  minutely_hash = parsed_pirates_data.fetch("minutely",false)
  if(minutely_hash)
    @summary = minutely_hash.fetch("summary")
  end

  hourly_hash = parsed_pirates_data.fetch("hourly")
  hourly_data_array = hourly_hash.fetch("data")

  next_twelve_hours = hourly_data_array[1..12]
  precipitation = false

  next_twelve_hours.each do |hour|
    precipitation_pos = hour.fetch("precipProbability")
    if(precipitation_pos > 0.1)
      precipitation = true
      break
    end
  end
  
  @status = "You probably won’t need an umbrella today."
  if precipitation
    @status = "You might want to carry an umbrella!"
  end

  erb(:process_umbrella)
end

get("/message") do
  erb(:message)
end

post("/process_single_message") do
  erb(:process_message)
end

get("/chat") do
  erb(:chat)
end

post("/add_message_to_chat") do
end

post("clear_chat") do
end
