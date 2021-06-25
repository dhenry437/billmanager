class HomeController < ApplicationController
  before_action :authenticate_user!

  before_action :set_calendar_events, only: :index
  before_action :set_target_account_balance, only: :index
  # before_action :set_next_deposit, only: :index
  # before_action :set_last_deposit, only: :index

  def index; end

  def set_next_deposit
    next_payday = Payday.where(user_id: current_user.id).all.flat_map(&:next_payday)
    next_payday = next_payday.any? ? next_payday.min_by(&:date) : nil # Check for [nil] returned
    @next_deposit = nil if next_payday.nil? || balance_at(next_payday.date) - @target_account_balance
  end

  def set_last_deposit
    last_payday = Payday.where(user_id: current_user.id).all.flat_map(&:previous_payday)
    last_payday = last_payday.any? ? last_payday.max_by(&:date) : nil # Check for [nil] returned
    @last_deposit = nil if last_payday.nil? || @target_account_balance - (balance_at(last_payday.date - 1.day))
  end

  def set_target_account_balance
    date = params[:date] || Date.today
    date = date.to_date + 1.second
    @target_account_balance = account_balance_at(date)
  end

  def set_calendar_events
    @bills = Bill.where(user_id: current_user.id).all
    @calendar_bills = @bills.flat_map { |x| x.calendar_bills(params.fetch(:start_date, Time.zone.now)) }
    @paydays = Payday.where(user_id: current_user.id).all
    @calendar_paydays = @paydays.flat_map { |x| x.calendar_paydays(params.fetch(:start_date, Time.zone.now)) }
    @events = @calendar_bills + @calendar_paydays
  end

  # Calculate target account balance for a given date
  def balance_at(date = Date.today)
    # date += 1.second # maybe in the wrong place
    balance_at = 0
    upcoming_bills = Bill.where(user_id: current_user.id).all.flat_map do |x|
      x.next_bill(date)
    end
    upcoming_bills.each do |bill|
      paydays_between = Payday.where(user_id: current_user.id).all.flat_map do |x|
        x.paydays_between(date, bill.date)
      end
      balance_at += bill.amount / (paydays_between.empty? ? 1 : paydays_between.length)
    end
    balance_at
  end

  def account_balance_at(date = Date.today)
    last_payday = Payday.where(user_id: current_user.id).all.flat_map { |x| x.previous_payday(date) }
    last_payday = last_payday.any? ? last_payday.max_by(&:date) : nil # Check for [nil] returned

    bills_since_last_payday = Bill.where(user_id: current_user.id).all.flat_map do |x|
      x.bills_between(last_payday.date, date)
    end

    # TODO: Figure out what to do when there is not a previous payday
    last_payday ? balance_at(last_payday.date) - bills_since_last_payday.inject(0) { |sum, x| sum + x.amount } : -1
  end
end
