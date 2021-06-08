class CalendarController < ApplicationController
  before_action :authenticate_user!

  def index
    @bills = Bill.where(user_id: current_user.id).all
    @calendar_bills = @bills.flat_map { |x| x.calendar_bills(params.fetch(:start_date, Time.zone.now)) }
  end
end
