class EmergenciesController < ApplicationController
  
  def index
    @emergencies = Emergency.all.as_json
    dispatcher = Dispatcher.new
    puts dispatcher.results
    total_emergencies = @emergencies.length
    num_resolved = dispatcher.results.inject(0) do |total_resolved, result|
      total_resolved +=  1  if result[:resolved][:all]
    end
    full_responses = [num_resolved, total_emergencies]

    render json: { emergencies: @emergencies, full_responses: full_responses }
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
      begin 
        @emergency.save!
        @response = @emergency.as_json
        dispatcher = Dispatcher.new
        result = dispatcher.results.find { |result| result[:emergency] == @emergency }

        @response["full_response"] = result[:resolved][:all]
        @response["responders"]    = result[:responders].map { |responder| responder.name }

      rescue ActiveRecord::RecordInvalid => e
        @message = {message: e.record.errors.as_json}
        render json: @message, status: 422
      else
        render json: {emergency: @response}, status: 201
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
