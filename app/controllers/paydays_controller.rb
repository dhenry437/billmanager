class PaydaysController < ApplicationController
  before_action :set_payday, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /paydays or /paydays.json
  def index
    @paydays = Payday.where(user_id: current_user.id).all
  end

  # GET /paydays/1 or /paydays/1.json
  def show
  end

  # GET /paydays/new
  def new
    @payday = Payday.new
  end

  # GET /paydays/1/edit
  def edit
  end

  # POST /paydays or /paydays.json
  def create
    @payday = Payday.new(name: params[:payday][:name], date: params[:payday][:date], recurring: generate_recurring_yaml,
                         user_id: current_user.id)

    respond_to do |format|
      if @payday.save
        format.html { redirect_to @payday, notice: "Payday was successfully created." }
        format.json { render :show, status: :created, location: @payday }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @payday.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /paydays/1 or /paydays/1.json
  def update
    respond_to do |format|
      if @payday.update(name: params[:payday][:name], amount: params[:payday][:amount], date: params[:payday][:date], recurring: generate_recurring_yaml)
        format.html { redirect_to @payday, notice: "Payday was successfully updated." }
        format.json { render :show, status: :ok, location: @payday }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @payday.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /paydays/1 or /paydays/1.json
  def destroy
    @payday.destroy
    respond_to do |format|
      format.html { redirect_to paydays_url, notice: "Payday was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_payday
    @payday = Payday.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def payday_params
    params.require(:payday).permit(:name, :date, :recurring)
  end

  def generate_recurring_yaml
    return unless params[:payday][:recurring_bool] == '1'

    schedule = if params[:payday][:occurs_until].empty? then
                 IceCube::Schedule.new(Date.parse(params[:payday][:date]))
               else
                 IceCube::Schedule.new(Date.parse(params[:payday][:date]), end_time: Date.parse(params[:payday][:occurs_until]))
               end

    case params[:payday][:recurring_period]
    when 'daily'
      schedule.add_recurrence_rule IceCube::Rule.daily(params[:payday][:recurring_every])
    when 'weekly'
      schedule.add_recurrence_rule IceCube::Rule.weekly(params[:payday][:recurring_every])
    when 'monthly'
      schedule.add_recurrence_rule IceCube::Rule.monthly(params[:payday][:recurring_every])
    when 'yearly'
      schedule.add_recurrence_rule IceCube::Rule.yearly(params[:payday][:recurring_every])
    end

    schedule.to_yaml
  end
end
