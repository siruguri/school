class Lesson < ActiveRecord::Base
  attr_accessible :address, :city, :course_id, :start_time, :end_time, :description, :title, :user_id, :slug, :venue_id, :summary, :level_id, :tweet_message

  scope :for_city, lambda { |cn| Lesson.joins(:venue).merge(Venue.by_cityname cn) }
  
  has_many :attendances
  has_many :users, :through => :attendances
  before_save :generate_slug
  belongs_to :venue
  belongs_to :teacher, class_name: "User"

  def generate_slug
    self.slug = Slug.new(title).generate if self.slug.blank?
  end

  def to_param
    slug || id
  end

  def self.lessons_this_month(options={})
    from = Time.current.beginning_of_month
    to = Time.current.end_of_month

    self.where(start_time: (from..to))
  end

  def self.future_lessons(options={})
    self.where("end_time > (?)", Time.current).order("start_time asc")
  end

  def self.past_lessons(options={})
    if options && options[:city]
      lessons = Lesson.for_city options[:city]
    else
      lessons = order("RANDOM()").limit(4)
      
      if lessons.empty?
        lessons << new
      end
    end

    lessons
  end


end
