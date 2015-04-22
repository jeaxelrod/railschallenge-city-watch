class EmergenciesController < ApplicationController
  
  def index
    @emergencies = Emergency.all
    render { @emergencies }
  end

  def show
    begin
      @emergency = Emergency.find_by_code!(params[:code])
    rescue ActiveRecord::RecordNotFound => e
      render status: 404
    else
      render @emergency
    end
  end

  def create
    @emergency = Emergency.create(emergency_params)
    if params[:emergency][:id]
      @message = { message: 'found unpermitted parameter: id' }
      render json: @message, status: 422
    elsif params[:emergency][:resolved_at]
      @message = { message: 'found unpermitted parameter: resolved_at' }
      render json: @message, status: 422
    else
      begin @emergency.save!
      rescue ActiveRecord::RecordInvalid => e
        @message = {message: e.record.errors.as_json}
        render json: @message, status: 422
      else
        render @emergency, status: 201
      end
    end
  end

  def update
    begin
      @emergency = Emergency.find_by_code!(params[:code])
      if params[:emergency][:code]
        @message = { message: 'found unpermitted parameter: code' }
        render json: @message, status: 422
      else
        @emergency.update(emergency_params)
        render @emergency
      end
    rescue ActiveRecord::RecordNotFound => e
      render status: 404
    else
    end
  end

  private
  
  def emergency_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity, :resolved_at)
  end
end
