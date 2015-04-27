class RespondersController < ApplicationController
  def index
    @responders = Responder.all
    if params[:show] == 'capacity'
      types = %w(Fire Police Medical)
      @capacity = {}
      types.each do |type|
        @capacity[type] = make_capacity(type)
      end
      render json: { capacity: @capacity }
    else
      render { @responders }
    end
  end

  def show
    @responder = Responder.find_by_name!(params[:name])
  rescue ActiveRecord::RecordNotFound
    render status: 404
  else
    render @responder
  end

  def create
    return if render_create_forbidden_attribute
    @responder = Responder.create!(responder_params)
    render @responder, status: 201
  rescue (ActiveRecord::RecordInvalid) => e
    @message = { message: e.record.errors.as_json }
    render json: @message, status: 422
  end

  def update
    @responder = Responder.find_by_name!(params[:name])
    if params[:responder][:on_duty]
      @responder.update(responder_params)
      render @responder
    else
      render_update_forbidden_attribute
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

  def responder_params
    params.require(:responder).permit(:type, :name, :capacity, :on_duty)
  end

  def render_create_forbidden_attribute
    forbidden_attributes = [:emergency_code, :id, :on_duty]
    forbidden_attribute = forbidden_attributes.any? do |attr|
      next unless params[:responder][attr]
      @message = { message: "found unpermitted parameter: #{attr}" }
      render json: @message, status: 422
      true
    end
    forbidden_attribute
  end

  def render_update_forbidden_attribute
    forbidden_attributes = [:name, :type, :emergency_code, :capacity]
    forbidden_attributes.any? do |attr|
      next unless params[:responder][attr]
      @message = { message: "found unpermitted parameter: #{attr}" }
      render json: @message, status: 422
      true
    end
  end

  def make_capacity(type)
    typed_responders              = Responder.where(type: type)
    on_duty_responders            = typed_responders.select(&:on_duty)
    available_on_duty_responders =  on_duty_responders.select { |responder| !responder.emergency_id  }

    total                   = get_total_capacity(typed_responders)
    total_on_duty           = get_total_capacity(on_duty_responders)
    total_available_on_duty = get_total_capacity(available_on_duty_responders)
    total_available         = total - (total_on_duty - total_available_on_duty)

    [total, total_available, total_on_duty, total_available_on_duty]
  end

  def get_total_capacity(responders)
    responders.inject(0) { |a, e| a + e.capacity }
  end
end
