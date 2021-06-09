class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @target_account_balance = balance_at

    next_payday = Payday.where(user_id: current_user.id).all.flat_map(&:next_payday)
    next_payday = next_payday.any? ? next_payday.min_by(&:date) : nil # Check for [nil] returned
    @next_deposit = balance_at(next_payday.date) - @target_account_balance

    last_payday = Payday.where(user_id: current_user.id).all.flat_map(&:previous_payday)
    last_payday = last_payday.any? ? last_payday.max_by(&:date) : nil # Check for [nil] returned
    @last_deposit = nil if last_payday.nil? || @target_account_balance - (balance_at(last_payday.date - 1.day))
  end

  # Calculate target account balance for a given date
  def balance_at(date = Date.today)
    date += 1.second # maybe in the wrong place
    balance_at = 0
    upcoming_bills = Bill.where(user_id: current_user.id).all.flat_map do |x|
      x.next_bill(date)
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
