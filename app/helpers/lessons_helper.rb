module LessonsHelper
  def etherpad_host(lesson)
    case
    when lesson.date > Time.parse("2012-11-07")
      "http://pad.railsschool.org/p/"
    when lesson.date > Time.parse("2012-08-31")
      "http://beta.etherpad.org/p/"
    else
      "http://typewith.me/p/"
    end
  end
end
