class CalendarController < ApplicationController
  before_action :authenticate_user!

  def settings
    if params[:show_balance_each_day]
      cookies.permanent[:show_balance_each_day] = params[:show_balance_each_day]
    else
      cookies.delete(:show_balance_each_day)
    end

    if params[:show_payday_deposits]
      cookies.permanent[:show_payday_deposits] = params[:show_payday_deposits]
    else
      cookies.delete(:show_payday_deposits)
    end

    redirect_back(fallback_location: root_path)
  end
end
