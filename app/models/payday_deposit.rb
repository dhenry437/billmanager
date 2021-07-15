class PaydayDeposit
  attr_accessor :start_time, :amount

  def initialize(start_time, amount)
    @start_time = start_time
    @amount = amount
  end
end
