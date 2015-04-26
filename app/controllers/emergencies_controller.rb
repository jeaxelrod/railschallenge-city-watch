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
    @emergency = Emergency.create(emergency_params)
    if params[:emergency][:id]
      @message = { message: 'found unpermitted parameter: id' }
      render json: @message, status: 422
    elsif params[:emergency][:resolved_at]
      @message = { message: 'found unpermitted parameter: resolved_at' }
      render json: @message, status: 422
    else
      begin
        @emergency.save!
        dispatcher = Dispatcher.new(@emergency)
        result = dispatcher.result
        @emergency.update_attribute(:full_response, result[:resolved][:all])
        result[:responders].each do |responder|
          responder.update_attribute(:emergency_id, @emergency.id)
        end
        @emergency.save!

        @response = @emergency.as_json
        @response['full_response'] = result[:resolved][:all]
        @response['responders']    = result[:responders].map(&:name)
      rescue ActiveRecord::RecordInvalid => e
        @message = { message: e.record.errors.as_json }
        render json: @message, status: 422
      else
        render json: { emergency: @response }, status: 201
      end
    end
  end

  def update
    @emergency = Emergency.find_by_code!(params[:code])
    if params[:emergency][:code]
      @message = { message: 'found unpermitted parameter: code' }
      render json: @message, status: 422
    else
      @emergency.update(emergency_params)
      if @emergency.resolved_at
        responders = Responder.where(emergency_id: @emergency.id)
        responders.each do |responder|
          responder.update_attribute(:emergency_id, nil)
        end
      end
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
end
