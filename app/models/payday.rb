class Payday < ApplicationRecord
  belongs_to :user

  def schedule(start)
    IceCube::Schedule.from_yaml recurring # Parse rule from yaml in DB
  end

  def calendar_paydays(start)
    if recurring.nil?
      [self] # Return the original bill if recurring is nil
    else
      start_date = start.beginning_of_month.beginning_of_week
      end_date = start.end_of_month.end_of_week

      schedule(start_date).occurrences(end_date).map do |x| # Get occurrences
        Payday.new(id: id, name: name, date: x) # Create new in memory bill
      end
    end
  end

  # Map date to start_time for simple_calendar
  def start_time
    date
  end
end
