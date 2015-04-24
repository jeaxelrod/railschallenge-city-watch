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
      begin 
        @emergency.save!
        @emergency = @emergency.as_json
        emergency_response = dispatch_responders(@emergency)
        @emergency["responders"] = emergency_response[:responders]
        @emergency["full_response"] = emergency_response[:full_response]
      rescue ActiveRecord::RecordInvalid => e
        @message = {message: e.record.errors.as_json}
        render json: @message, status: 422
      else
        render json: {emergency: @emergency}, status: 201
      end
    end
  end

  def dispatch_responders(emergency)
    types = ['Fire', 'Police', 'Medical']
    response = {}
    emergency_responders = []
    full_responses = []
    types.each do |type|
      severity = emergency["#{type.downcase}_severity"]
      responders = Responder.where(type: type, on_duty: true).to_a.sort do |x, y|
        x.capacity <=> y.capacity
      end
      emergency_response = fix_emergency(severity, responders) 
      emergency_responders.concat(emergency_response[:responders])
      full_responses.push(emergency_response[:full_response])
    end
    response[:responders] = emergency_responders.map { |responder| responder.name }
    response[:full_response] = full_responses[0] && full_responses[1] && full_responses[2]
    response
  end

  def fix_emergency(severity, responders)
    response = { responders: []}
    until severity <= 0 || responders.length == 0
      responder = matchResponder(severity, responders)
      responders.delete(responder)
      response[:responders].push(responder)
      severity -= responder.capacity
    end
    response[:full_response] = severity <= 0
    response
  end

  def matchResponder(severity, responders)
    responders.find { |responder| responder.capacity == severity } || responders.pop
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
