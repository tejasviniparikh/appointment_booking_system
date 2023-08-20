class Availability < ApplicationRecord
  belongs_to :doctor, class_name: 'User'
  enum status: { available: 0, occupied: 1 }
  delegate :full_name, to: :doctor, prefix: true

  before_validation :set_end_time

  validates :start_time, :end_time, presence: true

  def date
    start_time&.strftime('%d-%m-%Y')
  end

  def start_time=(start_time)
    if start_time.blank?
      super(start_time)
    else
      formatted_time = Time.parse(start_time)
      super(formatted_time.beginning_of_minute)
    end
  end

  def set_end_time
    return if start_time.blank?

    self.end_time = (start_time + 59.minutes).end_of_minute
  end

  def formatted_start_time
    start_time&.strftime('%H:%M')
  end

  def formatted_end_time
    end_time&.strftime('%H:%M')
  end
end
