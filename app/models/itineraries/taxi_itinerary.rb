require 'carrierwave/orm/activerecord'

class TaxiItinerary < Itinerary

  def get_taxi_itineraries(from, to, trip_datetime)

    base_url = "http://api.taxifarefinder.com/"
    api_key = Oneclick::Application.config.taxi_fare_finder_api_key
    api_key = '?key=' + api_key
    city = Oneclick::Application.config.taxi_fare_finder_api_city
    entity = '&entity_handle=' + city

    #Get fare
    task = 'fare'
    fare_options = "&origin=" + to[0].to_s + ',' + to[1].to_s + "&destination=" + from[0].to_s + ',' + from[1].to_s
    url = base_url + task + api_key + entity + fare_options

    Rails.logger.info "TripPlanner#get_taxi_itineraries-fare: url: #{url}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
    rescue Exception=>e
      Rails.logger.warn "Service failure: taxi: #{e.message}"
      Rails.logger.warn e.backtrace.first(5).join("\n")
      Honeybadger.notify(
        :error_class   => "Service failure",
        :error_message => "Service failure: taxi: #{e.message}",
        :parameters    => {url: url, resp: resp}
      )
      return false, {'id'=>500, 'msg'=>e.to_s}
    end

    Rails.logger.debug "TripPlanner#get_taxi_itineraries: resp.body: #{resp.body}"

    fare = JSON.parse(resp.body)
    if fare['status'] != "OK"
      Honeybadger.notify(
        :error_class   => "Service failure",
        :error_message => "Service failure: taxi: fare status not OK",
        :parameters    => {fare: fare}
      )
      return false, fare['explanation']
    end

    #Get providers
    task = 'businesses'
    url = base_url + task + api_key + entity

    Rails.logger.info "TripPlanner#get_taxi_itineraries-business: url: #{url}"

    begin
      resp = Net::HTTP.get_response(URI.parse(url))
    rescue Exception=>e
      Honeybadger.notify(
        :error_class   => "Service failure",
        :error_message => "Service failure: taxi: #{e.message}",
        :parameters    => {resp: resp}
      )
      return false, {'id'=>500, 'msg'=>e.to_s}
    end

    Rails.logger.debug "TripPlanner#get_taxi_itineraries: resp.body: #{resp.body}"

    businesses = JSON.parse(resp.body)
    if businesses['status'] != "OK"
      Honeybadger.notify(
        :error_class   => "Service failure",
        :error_message => "Service failure: taxi: business status not OK",
        :parameters    => {businesses: businesses}
      )
      return false, businesses['explanation']
    else
      return true, [fare, businesses]
    end

  end

  def format_as_generic_hash(itinerary)
    trip_itinerary = {}
    trip_itinerary['mode'] = Mode.taxi
    trip_itinerary['returned_mode_code'] = Mode.taxi.code
    trip_itinerary['duration'] = itinerary[0]['duration'].to_f
    trip_itinerary['walk_time'] = 0
    trip_itinerary['walk_distance'] = 0
    trip_itinerary['cost'] = itinerary[0]['total_fare']
    trip_itinerary['server_status'] = 200
    trip_itinerary['server_message'] = itinerary[1]['businesses'].to_yaml
    trip_itinerary['match_score'] = 1.2
    trip_itinerary['service'] = (ServiceType.where(code: 'taxi').first.services.first rescue nil)
    trip_itinerary
  end

end
