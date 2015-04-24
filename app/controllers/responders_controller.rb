class RespondersController < ApplicationController

  def index
    @responders = Responder.all
    if params[:show] == 'capacity'
      types = ['Fire', 'Police', 'Medical']
      @capacity = {}
      types.each do |type|
        @capacity[type] = set_capacity(type) 
      end
      render json: { capacity: @capacity }
    else
      render { @responders }
    end
  end

  def matchResponder(severity, responders) 
    responders.find { |responder| responder.capacity == severity } || responders.pop
  end

  def show
    begin
      @responder = Responder.find_by_name!(params[:name])
    rescue ActiveRecord::RecordNotFound => e
      render :status => 404
    else
      render @responder
    end
  end

  def create
    @responder = Responder.create(responder_params) 
    forbidden_attributes = [:emergency_code, :id, :on_duty]
    forbidden_attribute = false
    forbidden_attributes.each do |attr|
      if params[:responder][attr]
        @message = { message: "found unpermitted parameter: #{attr}" }
        forbidden_attribute = true
        render json: @message, status: 422
        break;
      end
    end
    unless forbidden_attribute
      begin
        @responder.save!
      rescue (ActiveRecord::RecordInvalid) => e
        @message = {message: e.record.errors.as_json}
        render json: @message, status: 422
      else
        render @responder, status: 201
      end
    end
  end

  def update
    @responder = Responder.find_by_name!(params[:name])
    if params[:responder][:on_duty]
      @responder.update(responder_params)
      render @responder
    else
      forbidden_attributes = [:name, :type, :emergency_code, :capacity]
      forbidden_attributes.each do |attr|
        if params[:responder][attr]
          @message = { message: "found unpermitted parameter: #{attr}" }
          render json: @message, status: 422
          break;
        end
      end
    end
  end

  def new
    render json: {message: "page not found"}, status: 404
  end

  def edit
    render json: {message: "page not found"}, status: 404
  end

  def destroy
    render json: {message: "page not found"}, status: 404
  end

  private

  def responder_params
    params.require(:responder).permit(:type, :name, :capacity, :on_duty)
  end

  def set_capacity(type)
    unresolved_emergencies = Emergency.where(resolved_at: nil)
    typed_responders = Responder.where(type: type)
    on_duty_responders  = typed_responders.where(on_duty: true)
    not_duty_responders = typed_responders.where(on_duty: false)

    total = get_total_capacity(typed_responders) 
    total_on_duty = get_total_capacity(on_duty_responders)

    on_duty_available = on_duty_responders_available({ responders:  on_duty_responders,
                                                       emergencies: unresolved_emergencies,
                                                       type:        type})
    total_available_and_on_duty = get_total_capacity(on_duty_available)

    available_responders = on_duty_available + not_duty_responders
    total_available = get_total_capacity(available_responders)

    [total, total_available, total_on_duty, total_available_and_on_duty]
  end

  def get_total_capacity(responders)
    responders.inject(0) { |total_capacity, responder| total_capacity + responder.capacity }
  end

  def on_duty_responders_available(params)
    type        = params[:type]
    emergencies = params[:emergencies].to_a
    responders  = params[:responders].to_a
    emergency_severity_attr = "#{type.downcase}_severity"

    emergencies.sort! { |x, y| y[emergency_severity_attr] <=> x[emergency_severity_attr] }
    responders.sort! { |x, y| x.capacity <=> y.capacity }

    emergencies.each do |emergency|
      severity = emergency[emergency_severity_attr]
      until severity <= 0 || responders.length == 0
        responder = matchResponder(severity, responders)
        responders.delete(responder)
        severity -= responder.capacity
      end
    end
    responders
  end
end
