class Mode < ActiveRecord::Base

  has_many :itineraries
  has_and_belongs_to_many :trips, join_table: :trips_desired_modes, foreign_key: :desired_mode_id

  belongs_to :parent, class_name: 'Mode'
  has_many :submodes, class_name: 'Mode', foreign_key: 'parent_id'

  # Updatable attributes
  # attr_accessible :id, :name, :active
    
  # set the default scope
  default_scope {where('active = ? and parent_id is null', true)}

  def self.transit
    where("code = 'mode_transit'").first
  end

  def self.paratransit
    where("code = 'mode_paratransit'").first
  end

  def self.taxi
    where("code = 'mode_taxi'").first
  end

  def self.rideshare
    where("code = 'mode_rideshare'").first
  end

  def to_s
    name
  end

end
