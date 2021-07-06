class CalendarController < ApplicationController
  before_action :authenticate_user!

  def index
    @bills = Bill.where(user_id: current_user.id).all
    @calendar_bills = @bills.flat_map { |x| x.calendar_bills(params.fetch(:start_date, Time.zone.now)) }

    @paydays = Payday.where(user_id: current_user.id).all
    @calendar_paydays = @paydays.flat_map { |x| x.calendar_paydays(params.fetch(:start_date, Time.zone.now)) }

    @events = @calendar_bills + @calendar_paydays
  end

  def settings
    if params[:show_balance_each_day]
      cookies.permanent[:show_balance_each_day] = params[:show_balance_each_day]
    else
      cookies.delete(:show_balance_each_day)
    end

    redirect_back(fallback_location: root_path)
  end
end
