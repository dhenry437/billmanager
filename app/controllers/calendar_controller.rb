class CalendarController < ApplicationController
  before_action :authenticate_user!

  def index; end
    @events = Bill.where(user_id: current_user.id).all
end
