class EmergenciesController < ApplicationController
  
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

  private
  
  def emergency_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity)
  end
end
