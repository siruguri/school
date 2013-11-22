class HomeController < ApplicationController

  def about
  end

  def calendar
  end

  def contact
  end

  def faq
  end

  def index
    if global_city
      @lessons_this_month = Lesson.lessons_this_month(city: global_city)
      @past_lessons = Lesson.past_lessons(city: global_city)
      @future_lessons = Lesson.future_lessons(city: global_city)
    end
  end

end
