class EmergenciesController < ApplicationController
  def index
    @emergencies = Emergency.all.as_json
    num_resolved = Emergency.where(full_response: true).length
    total_emergencies = @emergencies.length
    full_responses = [num_resolved, total_emergencies]

    render json: { emergencies: @emergencies, full_responses: full_responses }
  end

  def show
    @emergency = Emergency.find_by_code!(params[:code])
  rescue ActiveRecord::RecordNotFound
    render status: 404
  else
    render @emergency
  end

  def create
    return if render_forbidden_attribute

    @emergency = Emergency.create!(emergency_params)
    dispatcher = Dispatcher.new(@emergency)
    full_response = dispatcher.full_response
    dispatched_responders = dispatcher.dispatched_responders

    @emergency[:full_response] = full_response
    @emergency.save!
    responders_busy(dispatched_responders, @emergency)

    @response = @emergency.as_json
    @response['responders'] = dispatched_responders.map(&:name)
    render json: { emergency: @response }, status: 201
  rescue ActiveRecord::RecordInvalid => e
    @message = { message: e.record.errors.as_json }
    render json: @message, status: 422
  end

  def update
    @emergency = Emergency.find_by_code!(params[:code])
    if params[:emergency][:code]
      @message = { message: 'found unpermitted parameter: code' }
      render json: @message, status: 422
    else
      @emergency.update(emergency_params)
      responders_available(@emergency) if @emergency.resolved_at
      render @emergency
    end
  rescue ActiveRecord::RecordNotFound
    render status: 404
  end

  def new
    render json: { message: 'page not found' }, status: 404
  end

  def edit
    render json: { message: 'page not found' }, status: 404
  end

  def destroy
    render json: { message: 'page not found' }, status: 404
  end

  private

  def emergency_params
    params.require(:emergency).permit(:code, :fire_severity, :police_severity, :medical_severity, :resolved_at)
  end

  def responders_busy(responders, emergency)
    responders.each do |responder|
      responder.update_attribute(:emergency_id, emergency.id)
    end
  end

  def responders_available(emergency)
    responders = Responder.where(emergency_id: emergency.id)
    responders.each do |responder|
      responder.update_attribute(:emergency_id, nil)
    end
  end

  def render_forbidden_attribute
    forbidden_attributes = [:id, :resolved_at]
    forbidden_attribute = forbidden_attributes.any? do |attr|
      next unless params[:emergency][attr]
      @message = { message: "found unpermitted parameter: #{attr}" }
      render json: @message, status: 422
      true
    end
    forbidden_attribute
  end
end
