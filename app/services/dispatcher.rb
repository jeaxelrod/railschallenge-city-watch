class Dispatcher
  attr_accessor :emergency
  attr_reader :results, :available_on_duty_responders
  TYPES = [:fire, :police, :medical]

  def initialize(emergency)
    @emergency = emergency
    dispatch
  end

  def available_on_duty_responders
    @available_on_duty_responders ||= Responder.where(emergency_id: nil, on_duty: true)
  end

  def dispatched_responders
    @dispatched_responders ||= { fire: [], police: [], medical: [] }
  end

  # A result contains result which is the following datatype:
  #   { responders: Array of Responder,
  #     resolved: [ fire: boolean, medical: boolean, police: boolean, all: boolean ] }
  #
  def result
    @result ||= new_result
  end

  private

  def dispatch
    TYPES.each do |type|
      send_responders(type)
    end
    resolve_emergency
  end

  def send_responders(type)
    responders  = on_duty_responders_by_type(type).to_a
    severity_attr = "#{type}_severity"
    severity = @emergency[severity_attr]
    until severity <= 0 || responders.length == 0

      responder = match_responder(severity, responders)
      @available_on_duty_responders = available_on_duty_responders.where.not(id: responder.id)
      dispatched_responders[type].push(responder)
      severity -= responder.capacity
      result[:responders].push(responder)
    end
    result[:resolved][type] = true if severity <= 0
  end

  def new_result
    resolved = {}
    TYPES.each { |type| resolved[type] = false }
    resolved[:all] = false

    { resolved:   resolved,
      responders: [] }
  end

  def resolve_emergency
    result[:resolved][:all] = TYPES.inject(true) { |a, e| a && result[:resolved][e] }
  end

  def on_duty_responders_by_type(type)
    type_attr = type.to_s.capitalize
    available_on_duty_responders.where(type: type_attr)
  end

  def match_responder(severity, responders)
    responders.find { |responder| responder.capacity == severity } || responders.pop
  end
end
