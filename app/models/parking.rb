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
  validates :risk_level, presence: true
  enum risk_level: [:safe, :risky]

  include PgSearch::Model
  pg_search_scope :search_by_name_and_address,
    against: [ :name, :address ],
  using: {
    tsearch: { prefix: true }
  }

  def average_review_score
    average = reviews.average(:rating).to_f
    if average % 1 == 0
      average.to_i
    else
      average.round(1)
    end
  end

  def free_or_paid
    if price == 'free'
      'FREE'
    else
      'Payment required at this spot'
    end
  end

end
