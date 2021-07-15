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
    # @target_account_balance = payday_balance(date)
  end

  def set_calendar_events
    @bills = Bill.where(user_id: current_user.id).all
    @calendar_bills = @bills.flat_map { |x| x.calendar_bills(params.fetch(:start_date, Time.zone.now)) }
    @paydays = Payday.where(user_id: current_user.id).all
    @calendar_paydays = @paydays.flat_map { |x| x.calendar_paydays(params.fetch(:start_date, Time.zone.now)) }
    @calendar_account_balances = cookies[:show_balance_each_day] ? calendar_account_balances(params.fetch(:start_date, Time.zone.now)) : []
    @calendar_payday_deposits = cookies[:show_payday_deposits] ? calendar_payday_deposits(params.fetch(:start_date, Time.zone.now)) : []
    @events = @calendar_account_balances + @calendar_payday_deposits + @calendar_bills + @calendar_paydays
  end

  def account_balance_at(date = Date.today)
    last_payday = Payday.where(user_id: current_user.id).all.flat_map { |x| x.previous_payday(date) }
    last_payday = last_payday.any? ? last_payday.max_by(&:date) : nil # Check for [nil] returned

    bills_since_last_payday = Bill.where(user_id: current_user.id).all.flat_map do |x|
      x.bills_between(last_payday.date, date)
    end

    # TODO: Figure out what to do when there is not a previous payday
    last_payday ? payday_balance(last_payday.date) - bills_since_last_payday.inject(0) { |sum, x| sum + x.amount } : -1
    # last_payday ? payday_deposit(last_payday.date) : -1
  end

  def payday_balance(date)
    paydays = Payday.where(user_id: current_user.id).all
    upcoming_bills = Bill.where(user_id: current_user.id).all.flat_map do |x|
      x.next_bill(date)
    end
    balance = 0
    upcoming_bills.each do |bill|
      paydays_bill_cycle = paydays.flat_map { |x| x.paydays_between(bill.previous_bill(bill.date).date, bill.date) }
      num_paydays_bill_cycle = paydays_bill_cycle.length
      num_paydays_past = paydays_bill_cycle.select { |x| x.date <= date }.length
      balance += num_paydays_past * (bill.amount / num_paydays_bill_cycle)
      puts "DEBUG: #{bill.name} = #{bill.previous_bill(bill.date).date} - #{bill.date}"
      puts "DEBUG: #{bill.name} = #{num_paydays_past} * (#{bill.amount} / #{num_paydays_bill_cycle})"
    end
    balance
  end

  def payday_deposit(date)
    paydays = Payday.where(user_id: current_user.id).all
    upcoming_bills = Bill.where(user_id: current_user.id).all.flat_map do |x|
      x.next_bill(date)
    end
    balance = 0
    upcoming_bills.each do |bill|
      paydays_bill_cycle = paydays.flat_map { |x| x.paydays_between(bill.previous_bill(bill.date).date, bill.date) }
      num_paydays_bill_cycle = paydays_bill_cycle.length
      balance += bill.amount / num_paydays_bill_cycle
      puts "DEBUG: #{bill.name} = #{bill.previous_bill(bill.date).date} - #{bill.date}"
      puts "DEBUG: #{bill.name} = #{bill.amount} / #{num_paydays_bill_cycle}"
    end
    balance
  enddef calendar_account_balances(start)
    start_date = start.to_time.beginning_of_month.beginning_of_week
    end_date = start.to_time.end_of_month.end_of_week

    start_date.to_date.upto(end_date.to_date).map do |x|
      x += 1.second
      AccountBalance.new(x, account_balance_at(x))
    end
  end

  def calendar_payday_deposits(start)
    start_date = start.to_time.beginning_of_month.beginning_of_week
    end_date = start.to_time.end_of_month.end_of_week

    paydays = Payday.where(user_id:  current_user.id).all
    payday_dates = paydays.flat_map { |x| x.paydays_between(start_date, end_date) }
    payday_dates.map { |x| PaydayDeposit.new(x.date, payday_deposit(x.date)) }
  end
end
