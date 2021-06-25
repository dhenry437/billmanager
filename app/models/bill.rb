class Bill < ApplicationRecord
  belongs_to :user

  # Parse the IceCube rule for a Bill
  def schedule
    IceCube::Schedule.from_yaml recurring # Parse rule from yaml in DB
  end

  # Returns the next occurrence or recurrence of a Bill
  def next_bill(start = Date.today)
    if recurring.nil?
      date > Date.today ? [self] : nil
    else
      x = schedule.next_occurrence(start.to_time) # Get occurrences
      Bill.new(id: id, name: name, amount: amount, date: x) # Create new in memory bill
    end
  end

  # Returns a Bill and all its recurrences that lie in a given time period
  def bills_between(start_date, end_date)
    if recurring.nil?
      date > Date.today && date < end_date ? [self] : nil
    else
      schedule.occurrences_between(start_date.to_time, end_date.to_time, spans: true).map do |x| # Get occurrences
        Bill.new(id: id, name: name, amount: amount, date: x) # Create new in memory bill
      end
    end
  end

  # Return occurrences and recurrences of a Bill for the calendar display month
  def calendar_bills(start)
    if recurring.nil?
      [self] # Return the original bill if recurring is nil
    else
      start_date = start.to_time.beginning_of_month.beginning_of_week
      end_date = start.to_time.end_of_month.end_of_week

      schedule.occurrences_between(start_date, end_date).map do |x| # Get occurrences
        Bill.new(id: id, name: name, amount: amount, date: x) # Create new in memory bill
      end
    end
  end

  # Map date to start_time for simple_calendar
  def start_time
    date
  end
end
