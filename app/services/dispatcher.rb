class Dispatcher
  attr_accessor :emergency
  attr_reader :full_response, :available_on_duty_responders
  TYPES = [:fire, :police, :medical]

  def initialize(emergency)
    @emergency = emergency
    @resolved = {}
    TYPES.each { |type| @resolved[type] = false }
    dispatch
  end

  def available_on_duty_responders
    @available_on_duty_responders ||= Responder.where(emergency_id: nil, on_duty: true)
  end

  def dispatched_responders
    @dispatched_responders  ||= []
  end

  private

  def dispatch
    TYPES.each do |type|
      send_responders(type)
    end
    @full_response = TYPES.inject(true) { |a, e| a && @resolved[e] }
  end

  def send_responders(type)
    responders  = on_duty_responders_by_type(type).to_a
    severity = severity_by_type(type)
    until severity <= 0 || responders.length == 0
      responder = match_responder(severity, responders)
      severity -= responder.capacity

      update_available_responders(responder)
      responders.delete(responder)
    end
    @resolved[type] = true if severity <= 0
  end

  def on_duty_responders_by_type(type)
    type_attr = type.to_s.capitalize
    available_on_duty_responders.where(type: type_attr)
  end

  def severity_by_type(type)
    severity_attr = "#{type}_severity"
    @emergency[severity_attr]
  end

  def update_available_responders(responder)
    dispatched_responders.push(responder)
    @available_on_duty_responders = @available_on_duty_responders.where.not(id: responder.id)
  end

  def match_responder(severity, responders)
    responders.find { |responder| responder.capacity == severity } || responders.pop
  end
end
