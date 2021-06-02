class Parking < ApplicationRecord
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
  
  has_many :user_parkings
  has_many :users, through: :user_parkings
  has_many :reviews, dependent: :destroy
  has_many_attached :photos
  validates :name, uniqueness: { scope: :address }, presence: true
  validates :address, presence: true
  validates :description, length: { minimum: 10 }, presence: true
  enum price: [:free, :paid]

  include PgSearch::Model
  pg_search_scope :search_by_name_and_address,
  against: [ :name, :address ],
  using: {
    tsearch: { prefix: true }
  }

  def average_review_score
    reviews.average(:rating).to_f.round(1)
  end

end
