class Bill < ApplicationRecord
  belongs_to :user

  def schedule
    IceCube::Schedule.from_yaml recurring # Parse rule from yaml in DB
  end

  def bill_next_occurrence(start)
    if recurring.nil?
      date > Date.today ? [self] : nil
    else
      x = schedule.next_occurrence(start.to_time) # Get occurrences
      Bill.new(id: id, name: name, amount: amount, date: x) # Create new in memory bill
    end
  end

  def calendar_bills(start)
    if recurring.nil?
      [self] # Return the original bill if recurring is nil
    else
      start_date = start.beginning_of_month.beginning_of_week
      end_date = start.end_of_month.end_of_week

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
