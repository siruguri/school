class UsersController < ApplicationController
  before_filter :load_and_authorize_user, :only => [:edit, :update]
  before_filter :admin_only, :only => [:index, :notify_subscribers]
  http_basic_authenticate_with :name => SENDGRID_EVENT_USERNAME,
    :password => SENDGRID_EVENT_PASSWORD, :only => :report_email_bounce

  # GET /unsubscribe/:code
  def unsubscribe

    code = params[:code]
    user = User.find_by_unsubscribe_token(code)
    user.subscribe = false
    user.save!

    render text: "you have been successfully unsubscribed from RailsSchool notifications. Thank you for all the good you have, cheers and astalavista."
  end

  # POST /notify_subscribers/1
  def notify_subscribers
    unless current_user.admin? && current_user.email.match(/railsschool.org$/)
      return head status: 403
    end
    lesson = Lesson.find(params[:id])
    User.where(subscribe: true).each do |u|
      NotificationMailer.delay.lesson_notification(lesson.id, u.id,
                                                   current_user.id)
    end
    if LessonTweeter.new(lesson, current_user).tweet
      flash[:notice] = "Subcribers notified and tweet tweeted"
    else
      flash[:notice] = "Subscribers notified but error sending tweet, perhaps it was too long?"
    end
    lesson.update_attribute(:notification_sent_at, Time.now)
    redirect_to lesson_path(lesson)
  end

  # GET /users
  def index
    @users = User.all
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
  end

  # GET /users/1/edit
  def edit
  end

  # POST /bounce_reports
  def report_email_bounce
    unless params[:email].present? && params[:event] == "bounce"
      return head :status => 422
    end
    user = User.find_by_email(params[:email])
    if user
      user.subscribe = false
      user.save
    end
    head :status => 200 # sendgrid demands a 200
  end

  # PUT /users/1
  def update

    if @user.update_attributes(params[:user])
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render action: "edit"
    end
  end

private
  def load_and_authorize_user
    @user = User.find(params[:id])
    redirect_to root_path unless (admin? || @user == current_user)
  end
end
