class Payday < ApplicationRecord
  belongs_to :user

  # Parse the IceCube rule for a Payday
  def schedule
    IceCube::Schedule.from_yaml recurring # Parse rule from yaml in DB
  end

  # Returns the next future occurrence or recurrence of a Payday
  def calendar_paydays(start)
    if recurring.nil?
      [self] # Return the original payday if recurring is nil
    else
      start_date = start.to_time.beginning_of_month.beginning_of_week
      end_date = start.to_time.end_of_month.end_of_week

      schedule.occurrences_between(start_date, end_date).map do |x| # Get occurrences
        Payday.new(id: id, name: name, date: x) # Create new in memory payday
      end
    end
  end

  # Returns the next occurrence or recurrence of a Payday
  def next_payday(date = Date.today)
    if recurring.nil?
      date > Date.today ? [self] : nil
    else
      x = schedule.next_occurrence(date.to_time) # Get occurrences
      return nil if x.nil?

      Payday.new(id: id, name: name, date: x) # Create new in memory payday
    end
  end

  # Returns the previous occurrence or recurrence of a Payday
  def previous_payday(date = Date.today)
    if recurring.nil?
      date < Date.today ? [self] : nil
    else
      x = schedule.previous_occurrence(date.to_time) # Get occurrences
      return nil if x.nil?

      Payday.new(id: id, name: name, date: x) # Create new in memory payday
    end
  end

  # Returns a Payday and all its recurrences that lie in a given time period
  def paydays_between(start_date, end_date)
    if recurring.nil?
      date > Date.today && date < end_date ? [self] : nil
    else
      schedule.occurrences_between(start_date.to_time, end_date.to_time, spans: true).map do |x| # Get occurrences
        Payday.new(id: id, name: name, date: x) # Create new in memory payday
      end
    end
  end

  # Map date to start_time for simple_calendar
  def start_time
    date
  end
end
