class RespondersController < ApplicationController

  def index
    @responders = Responder.all
    if params[:show] == 'capacity'
      types = ['Fire', 'Police', 'Medical']
      @capacity = {}
      dispatcher = Dispatcher.new
      types.each do |type|
        @capacity[type] = set_capacity(type, dispatcher) 
      end
      render json: { capacity: @capacity }
    else
      render { @responders }
    end
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

  def set_capacity(type, dispatcher)
    total =                   get_total_capacity(dispatcher.responders.where(type: type))
    total_on_duty =           get_total_capacity(dispatcher.on_duty_responders.where(type:type))
    total_available_on_duty = get_total_capacity(dispatcher.available_on_duty_responders.
                                where(type: type))
    total_available =         total - (total_on_duty - total_available_on_duty)
    
    [total, total_available, total_on_duty, total_available_on_duty]
  end

  
  def get_total_capacity(responders)
    responders.inject(0) { |total_capacity, responder| total_capacity + responder.capacity }
  end


end
