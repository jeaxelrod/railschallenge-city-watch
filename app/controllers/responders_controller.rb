class RespondersController < ApplicationController
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

  def responder_params
    params.require(:responder).permit(:type, :name, :capacity)
  end
end
