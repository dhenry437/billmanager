class BillsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bill, only: %i[show edit update destroy]

  # GET /bills or /bills.json
  def index
    @bills = Bill.where(user_id: current_user.id).all
  end

  # GET /bills/1 or /bills/1.json
  def show; end

  # GET /bills/new
  def new
    @bill = Bill.new
  end

  # GET /bills/1/edit
  def edit
    return unless @bill.recurring
    hash = @bill.schedule.to_hash
    @rule_type = hash[:rrules][0][:rule_type].delete_prefix('IceCube::').delete_suffix('Rule').downcase
    @rule_interval = hash[:rrules][0][:interval]
    @occurs_until = hash[:end_time]&.to_date
  end

  # POST /bills or /bills.json
  def create
    @bill = Bill.new(name: params[:bill][:name], amount: params[:bill][:amount], date: params[:bill][:date])
    @bill.user_id = current_user.id
    @bill.recurring = generate_recurring_yaml

    respond_to do |format|
      if @bill.save
        format.html { redirect_to @bill, notice: "Bill was successfully created." }
        format.json { render :show, status: :created, location: @bill }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bills/1 or /bills/1.json
  def update
    respond_to do |format|
      if @bill.update(name: params[:bill][:name], amount: params[:bill][:amount], date: params[:bill][:date], recurring: generate_recurring_yaml)
        format.html { redirect_to @bill, notice: "Bill was successfully updated." }
        format.json { render :show, status: :ok, location: @bill }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bill.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bills/1 or /bills/1.json
  def destroy
    @bill.destroy
    respond_to do |format|
      format.html { redirect_to bills_url, notice: "Bill was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bill
    @bill = Bill.where(user_id: current_user.id).find(params[:id])
  end

    # Only allow a list of trusted parameters through.
  def bill_params
    params.require(:bill).permit(:name, :amount, :date, :recurring, :recurring_bool, :recurring_every, :recurring_period, :occurs_until)
  end

  def generate_recurring_yaml
    return unless params[:bill][:recurring_bool] == '1'

    schedule = if params[:bill][:occurs_until].empty? then
                 IceCube::Schedule.new(Date.parse(params[:bill][:date]))
               else
                 IceCube::Schedule.new(Date.parse(params[:bill][:date]), end_time: Date.parse(params[:bill][:occurs_until]))
               end

    case params[:bill][:recurring_period]
    when 'daily'
      schedule.add_recurrence_rule IceCube::Rule.daily(params[:bill][:recurring_every])
    when 'weekly'
      schedule.add_recurrence_rule IceCube::Rule.weekly(params[:bill][:recurring_every])
    when 'monthly'
      schedule.add_recurrence_rule IceCube::Rule.monthly(params[:bill][:recurring_every])
    when 'yearly'
      schedule.add_recurrence_rule IceCube::Rule.yearly(params[:bill][:recurring_every])
    end

    schedule.to_yaml
  end
end
