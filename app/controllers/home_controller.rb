class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @target_account_balance = balance_at
    next_payday = Payday.where(user_id: current_user.id).all.flat_map { |x| x.next_payday }.min_by { |x| x.date }
    @next_deposit = balance_at(next_payday.date + 1.day) - @target_account_balance
    last_payday = Payday.where(user_id: current_user.id).all.flat_map { |x| x.last_payday }.max_by { |x| x.date }
    @last_deposit = @target_account_balance - balance_at(last_payday.date - 1.day)
  end

  def balance_at(date = Date.today)
    balance_at = 0
    upcoming_bills = Bill.where(user_id: current_user.id).all.flat_map do |x|
      x.bill_next_occurrence(date)
    end
    upcoming_bills.each do |bill|
      paydays_between = Payday.where(user_id: current_user.id).all.flat_map do |x|
        x.paydays_between(date, bill.date)
      end
      balance_at += bill.amount / (paydays_between.length + 1)
    end
    balance_at
  end
end
