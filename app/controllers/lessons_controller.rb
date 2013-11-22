class LessonsController < ApplicationController
  # GET /lessons
  # GET /lessons.json
  before_filter :admin_only, :except => [:index, :show, :day]

  def index
    gon.signed_in = user_signed_in?
    gon.user_lessons = current_user.lessons.pluck(:id) if user_signed_in?
    @lessons = Lesson.for_city(params[:city]).order("start_time DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lessons }
    end
  end

  # GET /lessons/1
  # GET /lessons/1.json
  def show
    @whiteboard = params[:whiteboard]
    @lesson = Lesson.find_by_slug(params[:id]) || Lesson.find(params[:id])
    if @whiteboard
      authenticate_user!
      if Time.now > @lesson.start_time-10.minutes && Time.now < @lesson.end_time
        rsvp = current_user.attendances.where(lesson_id: @lesson.id).first
        rsvp.update_attribute(:confirmed, true) if rsvp && !rsvp.confirmed 
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lesson }
    end
  end

  # GET /lessons/new
  # GET /lessons/new.json
  def new
    @lesson = Lesson.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @lesson }
    end
  end

  # GET /lessons/1/edit
  def edit
    @lesson = Lesson.find_by_slug(params[:id]) || Lesson.find(params[:id])
  end

  # POST /lessons
  # POST /lessons.json
  def create
    @lesson = Lesson.new(fix_dates(params[:lesson]))
    @lesson.venue_id = 1 if @lesson.venue_id.blank?
    @lesson.teacher = current_user
    respond_to do |format|
      if @lesson.save
        format.html { redirect_to @lesson, notice: 'Lesson was successfully created.' }
        format.json { render json: @lesson, status: :created, location: @lesson }
      else
        format.html { render action: "new" }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /lessons/1
  # PUT /lessons/1.json
  def update
    @lesson = Lesson.find_by_slug(params[:id]) || Lesson.find(params[:id])

    respond_to do |format|
      if @lesson.update_attributes(fix_dates(params[:lesson]))
        format.html { redirect_to @lesson, notice: 'Lesson was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lessons/1
  # DELETE /lessons/1.json
  def destroy
    @lesson = Lesson.find_by_slug(params[:id]) || Lesson.find(params[:id])
    @lesson.destroy

    respond_to do |format|
      format.html { redirect_to lessons_url }
      format.json { head :no_content }
    end
  end

private
  def fix_dates(l_params)
    date = l_params.delete("date")
    l_params[:start_time] =
      Time.zone.parse("#{date} #{l_params[:start_time]}")
    l_params[:end_time] =
      Time.zone.parse("#{date} #{l_params[:end_time]}")
    l_params
  end
end
