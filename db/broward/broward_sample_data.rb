#encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) are set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html

def add_users_and_places
  places = [
    {active: 1, name: 'My house', raw_address: '730 Peachtree St NE, Atlanta, GA 30308'},
    {active: 1, name: 'Atlanta VA Medical Center', raw_address: '1670 Clairmont Rd, Decatur, GA'},
    {active: 1, name: 'Formación Para el Trabajo', raw_address: '239 West Lake Avenue NW, Atlanta, GA 30314'},
    {active: 1, name: 'Atlanta Mission',  raw_address: '239 West Lake Avenue NW, Atlanta, GA 30314'}
  ]
  users = [
    {first_name: 'Denis', last_name: 'Haskin', email: 'dhaskin@camsys.com'},
    {first_name: 'Derek', last_name: 'Edwards', email: 'dedwards@camsys.com'},
    {first_name: 'Eric', last_name: 'Ziering', email: 'eziering@camsys.com'},
    {first_name: 'Galina', last_name: 'Dymkova', email: 'gdymkova@camsys.com'},
    {first_name: 'Aaron', last_name: 'Magil', email: 'amagil@camsys.com'},
    {first_name: 'Julian', last_name: 'Ray', email: 'jray@camsys.com'},
  ]

  users.each do |user|


    u = User.find_by_email(user[:email])
    unless u.nil?
      next
    end

    puts "Add user #{user[:email]}"

    u = User.create! user.merge({password: 'welcome1'})
    up = UserProfile.new
    up.user = u
    up.save!
    places.each do |place|
      p = Place.new(place)
      p.creator = u
      p.geocode
      u.places << p
      begin
        u.save!
      rescue Exception => e
        puts e.inspect
        puts u.errors.inspect
        u.places.each do |pl|
          puts pl.errors.inspect
        end
      end
    end
    Mode.all.each do |mode|
      ump = UserModePreference.new
      ump.user = u
      ump.mode = mode
      ump.save!
    end
    u.add_role :registered_traveler
  end
end

def add_services_and_providers
  disabled = Characteristic.find_by_code('disabled')
  no_trans = Characteristic.find_by_code('no_trans')
  nemt_eligible = Characteristic.find_by_code('nemt_eligible')
  ada_eligible = Characteristic.find_by_code('ada_eligible')
  veteran = Characteristic.find_by_code('veteran')
  low_income = Characteristic.find_by_code('low_income')
  date_of_birth = Characteristic.find_by_code('date_of_birth')
  age = Characteristic.find_by_code('age')
  walk_distance = Characteristic.find_by_code('walk_distance')

  #Traveler accommodations
  folding_wheelchair_accessible = Accommodation.find_by_code('folding_wheelchair_accessible')
  motorized_wheelchair_accessible = Accommodation.find_by_code('motorized_wheelchair_accessible')
  lift_equipped = Accommodation.find_by_code('lift_equipped')
  door_to_door = Accommodation.find_by_code('door_to_door')
  curb_to_curb = Accommodation.find_by_code('curb_to_curb')
  driver_assistance_available = Accommodation.find_by_code('driver_assistance_available')

  #Service types
  paratransit = ServiceType.find_by_code('paratransit')
  volunteer = ServiceType.find_by_code('volunteer')
  nemt = ServiceType.find_by_code('nemt')

  #trip_purposes
  work = TripPurpose.find_by_code('work')
  training = TripPurpose.find_by_code('training')
  medical = TripPurpose.find_by_code('medical')
  dialysis = TripPurpose.find_by_code('dialysis')
  cancer = TripPurpose.find_by_code('cancer')
  personal = TripPurpose.find_by_code('personal')
  general = TripPurpose.find_by_code('general')
  senior = TripPurpose.find_by_code('senior')
  grocery = TripPurpose.find_by_code('grocery')

  providers = [
      {name: 'BC CS Mass Transit', contact: '', external_id: "1"},
      {name: 'City of Tamarac', contact: '', external_id: "2"},
      {name: 'City of Wilton Manners', contact: ' ', external_id: "3"},
      {name: 'Cooper City Community Services', contact: ' ', external_id: "4"},
      {name: 'City of Miramar', contact: ' ', external_id: "5"},
      {name: 'Southeast Focal Point', contact: ' ', external_id: "6"},
      {name: 'American Cancer Society', contact: ' ', external_id: "7"},
      {name: 'City of Sunrise', contact: ' ', external_id: "8"},
      {name: 'Northwest Focal Point', contact: ' ', external_id: "9"},
      {name: 'City of Lauderdale Lakes', contact: ' ', external_id: "10"}

  ]

  #Create providers and services with custom schedules, eligibility, and accommodations
  providers.each do |provider|


    p = Provider.find_by_external_id(provider[:external_id])
    unless p.nil?
      next
    end
    puts "Adding provider #{provider[:external_id]}"
    p = Provider.create! provider
    p.save

    case p.external_id

      when "1" #BC
               #Create service
        service = Service.create(name: 'BC Paratransit', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
        end
        #Trip purpose requirements
        [senior, medical, cancer, grocery].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
        end

        #Add geographic restrictions
        ['Broward'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'county_name')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
        end
        ['Broward'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'county_name')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
        end


        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: ada_eligible, value: 'true')

        #Traveler Accommodations Requirements
        [motorized_wheelchair_accessible, lift_equipped, door_to_door, driver_assistance_available, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n, value: 'true')
        end


      when "2" #Tamarac

        service = Service.create(name: 'Social Services: Limited Transportation', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"8:00", end_time: "4:30", day_of_week: n)
        end

        #Trip Purpose Requirements
        [medical,grocery, cancer].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
        end

        #Add geographic restrictions
        ['33309', '33319', '33320', '33321', '33323', '33351', '33359'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
        end

        #Add geographic restrictions
        ['33309', '33319', '33320', '33321', '33323', '33351', '33359'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: no_trans, value: 'false')

        #Traveler Accommodations Requirements
        [curb_to_curb, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n, value: 'true')
        end

      when "3"   #Wilton Manors

        service = Service.create(name: 'Social Services', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
        end
        #Trip Purpose Requirements
        [medical, grocery, cancer].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
        end

        #Add geographic restrictions
        ['33305', '33311', '33334'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
        end

        ['33305', '33311', '33334'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
        end

        ServiceCharacteristic.create(service: service, characteristic: disabled, value: 'true')

        #Traveler Accommodations Provided
        [folding_wheelchair_accessible, door_to_door].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n, value: 'true')
        end

      when "4" #Cooper City

        service = Service.create(name: 'Senior Services Transportation', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"9:00", end_time: "17:00", day_of_week: n)
        end

        #Trip Purpose Requirements
        [medical, cancer, grocery, senior].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
        end

        #Add geographic restrictions
        ['33024', '33026', '33328', '33329', '33330'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
        end

        ['Broward'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'county_name')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: age, value: '60', value_relationship_id: 4)

        #Traveler Accommodations Requirements
        [door_to_door, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n, value: 'true')
        end

      when "5" #City of Miramar
               #
        service = Service.create(name: 'Senior Center', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"8:00", end_time: "16:30", day_of_week: n)
        end

        #Trip Purpose Requirements
        [senior, cancer, medical, grocery].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
        end

        #Add geographic restrictions
        ['33023', '33025', '33027', '33029'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
        end

        ['33023', '33025', '33027', '33029'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: age, value: '60', value_relationship_id: 4)

        #Traveler Accommodations Requirements
        [door_to_door, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n, value: 'true')
        end

      when "6" # SE Focal Point
               #
        service = Service.create(name: 'Joseph Meyerhoff Senior Center', provider: p, service_type: paratransit, advanced_notice_minutes: 7*24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"8:00", end_time: "16:00", day_of_week: n)
        end

        #Trip Purpose Requirements
        [grocery].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
        end

        #Add geographic restrictions
        ['33028', '33027', '33330', '33325', '33324', '33313', '33311', '33334', '33308', '33306', '33305', '33304', '33301', '33316', '33315', '33312', '33004', '33317', '33314', '33313', '33312', '333026', '33024', '33004', '33025', '33021', '33023', '33020', '33009', '33019'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
        end

        ['33028', '33027', '33330', '33325', '33324', '33313', '33311', '33334', '33308', '33306', '33305', '33304', '33301', '33316', '33315', '33312', '33004', '33317', '33314', '33313', '33312', '333026', '33024', '33004', '33025', '33021', '33023', '33020', '33009', '33019'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: age, value: '60', value_relationship_id: 4)

        #Traveler Accommodations Requirements
        [curb_to_curb, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n, value: 'true')
        end

      when "7" #American Cancer Society

        service = Service.create(name: 'Road to Recovery', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"9:00", end_time: "17:00", day_of_week: n)
        end

        #Trip Purpose Requirements
        [cancer].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
        end

        #Add geographic restrictions
        ['broward'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'county_name')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
        end

        #Add geographic restrictions
        ['broward'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'county_name')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: no_trans, value: 'false')

        #Traveler Accommodations Requirements
        [curb_to_curb, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n, value: 'true')
        end

      when "8" #City of Sunrise

        service = Service.create(name: 'Special & Community Support Services', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
        end

        #Trip Purpose Requirements
        [medical, cancer].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
        end

        #Add geographic restrictions
        ['33304', '33313', '33319', '33321', '33322', '33323', '33325', '33326', '33338', '33345', '33351', '33355'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
        end

        ['broward'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'county_name')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: no_trans, value: 'false')
        ServiceCharacteristic.create(service: service, characteristic: age, value: '62', value_relationship_id: 4)

        #Traveler Accommodations Requirements
        [curb_to_curb, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n, value: 'true')
        end

      when "9" #Northwest Focal Center

        service = Service.create(name: 'Senior Medical Transportation', provider: p, service_type: paratransit, advanced_notice_minutes: 2*24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
        end

        #Trip Purpose Requirements
        [medical, cancer].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
        end

        #Add geographic restrictions
        ['33063', '33065', '33093', '33068', '33067', '33073'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
        end

        ['33063', '33065', '33093', '33068', '33067', '33073'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: age, value: '60', value_relationship_id: 4)

        #Traveler Accommodations Requirements
        [curb_to_curb, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n, value: 'true')
        end

      when "10" #City of Luaderdale Lakes

        service = Service.create(name: 'Senior Transport', provider: p, service_type: paratransit, advanced_notice_minutes: 3*24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
        end

        #Trip Purpose Requirements
        [grocery, general, senior, medical, cancer].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
        end

        #Add geographic restrictions
        ['33063', '33068', '33067', '33073'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
        end

        ['33063', '33068', '33067', '33073'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: age, value: '60', value_relationship_id: 4)

        #Traveler Accommodations Requirements
        [curb_to_curb, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n, value: 'true')
        end


        service = Service.create(name: 'Disabled Transport', provider: p, service_type: paratransit, advanced_notice_minutes: 3*24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"9:00", end_time: "12:00", day_of_week: n)
        end

        #Trip Purpose Requirements
        [grocery, general, senior, medical, cancer].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
        end

        #Add geographic restrictions
        ['33063', '33068', '33067', '33073'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
        end

        ['33063', '33068', '33067', '33073'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: disabled, value: 'true')

        #Traveler Accommodations Requirements
        [curb_to_curb, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n, value: 'true')
        end


    end

  end
end

def add_fares
  service = Service.find_by_name('BC Paratransit')
  if service and service.fare_structures.count == 0
    FareStructure.create(service: service, fare_type: 0, base: 3.50)

  end

  service = Service.find_by_name('Social Services: Limited Transportation')
  if service and service.fare_structures.count == 0
    FareStructure.create(service: service, fare_type: 2, desc: "Tamarac Para-transit fee is $30.00 for 3 months or 40.00 for 6 months per person for unlimited marketing and medical transportation.")

  end

  service = Service.find_by_name('Social Services')
  if service and service.fare_structures.count == 0
    FareStructure.create(service: service, fare_type: 0, base: 1)

  end

  service = Service.find_by_name('Joseph Meyerhoff Senior Center')
  if service and service.fare_structures.count == 0
    FareStructure.create(service: service, fare_type: 0, base: 0, desc: "Free service for Senior Center members.")

  end

  service = Service.find_by_name('Road to Recovery')
  if service and service.fare_structures.count == 0
    FareStructure.create(service: service, fare_type: 0, base: 0)

  end

  service = Service.find_by_name('Special & Community Support Services')
  if service and service.fare_structures.count == 0
    FareStructure.create(service: service, fare_type: 0, base: 3)
  end
end


def add_cms
  Cms::Site.destroy_all
  site = Cms::Site.where(identifier: 'default').first_or_create(label: 'default', hostname: 'localhost', path: 'content')
  # site.snippets.create! identifier: 'plan-a-trip', label: 'plan a trip', content: '<div class="well">This is the content for Plan A Trip</div>'
  # site.snippets.create! identifier: 'home-top-logged-in', label: 'home-top-logged-in', content: '<div class="well">This is content for home-top-logged-in</div>'
  # site.snippets.create! identifier: 'home-top', label: 'home-top', content: '<div class="well">This is content for home-top</div>'
  # site.snippets.create! identifier: 'home-bottom-left-logged-in', label: 'home-bottom-left-logged-in', content: '<div class="well">This is content for home-bottom-left-logged-in</div>'
  # site.snippets.create! identifier: 'home-bottom-center-logged-in', label: 'home-bottom-center-logged-in', content: '<div class="well">This is content for home-bottom-center-logged-in</div>'
  # site.snippets.create! identifier: 'home-bottom-right-logged-in', label: 'home-bottom-right-logged-in', content: '<div class="well">This is content for home-bottom-right-logged-in</div>'
  # site.snippets.create! identifier: 'home-bottom-left', label: 'home-bottom-left', content: '<div class="well">This is content for home-bottom-left</div>'
  # site.snippets.create! identifier: 'home-bottom-center', label: 'home-bottom-center', content: '<div class="well">This is content for home-bottom-center</div>'
  # site.snippets.create! identifier: 'home-bottom-right', label: 'home-bottom-right', content: '<div class="well">This is content for home-bottom-right</div>'
  brand = Oneclick::Application.config.brand

      text = <<EOT
<h2 style="text-align: justify;">1-Click/Broward helps you find options to get from here to there, using public transit,
 door-to-door services, and specialized transportation.  Give it a try, and
 <a href="mailto://OneClick@camsys.com">tell us</a> what you think.</h2>
EOT
      site.snippets.create! identifier: 'home-top-logged-in', label: 'home-top-logged-in', content: text
      site.snippets.create! identifier: 'home-top', label: 'home-top', content: text
      text = <<EOT
1-Click/Broward was funded by the
 <a href="http://www.fta.dot.gov/grants/13094_13528.html" target=_blank>Veterans Transportation
 Community Living Initiative</a>.
EOT
      site.snippets.create! identifier: 'home-bottom-left-logged-in', label: 'home-bottom-left-logged-in', content: text
      site.snippets.create! identifier: 'home-bottom-left', label: 'home-bottom-left', content: text
      text = <<EOT
<span style="float: right;">1-Click/Broward is sponsored by
<a href="http://211-broward.org/" target=_blank>2-1-1 Broward</a>.</span>
EOT
      site.snippets.create! identifier: 'home-bottom-right-logged-in', label: 'home-bottom-right-logged-in', content: text
      site.snippets.create! identifier: 'home-bottom-right', label: 'home-bottom-right', content: text
      text = <<EOT
Tell us about your trip.  The more information you give us, the more options we can find!
EOT
      site.snippets.create! identifier: 'plan-a-trip', label: 'plan a trip', content: text

end

def create_agencies
  ['York Area Agency on Aging',
   'Penn-Mar Human Services',
   'Touch A Life',
   'York Adams Transit Authority',
   'York Center for Independent Living',
   'Staying Connected'].each do |a|
    a = Agency.find_by_name(a)
    unless a.nil?
      next
    end
    Agency.create! name: a
  end
end

add_users_and_places
add_services_and_providers
add_fares
add_cms
create_agencies