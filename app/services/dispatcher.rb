class Dispatcher
  attr_accessor :responders, :emergencies
  attr_reader :results, :on_duty_responders, :available_on_duty_responders 
  TYPES = [:fire, :police, :medical]

  def initialize
    @responders = Responder.all
    @emergencies = Emergency.where(resolved_at: nil)
    @results = []
    dispatch()
  end

  def on_duty_responders
    @on_duty_responders ||= @responders.where(on_duty: true)
  end

  def available_on_duty_responders
    @available_on_duty_responders ||= on_duty_responders
  end

  def dispatched_responders
    @dispatched_responders ||= { fire: [], police: [], medical: []}
  end

  # A results contains result which is the following datatype:
  #   { emergency: An Emergency,
  #     responders: Array of Responder,
  #     resolved: [ fire: boolean, medical: boolean, police: boolean, all: boolean ] }
  #
  def results
    @results ||= []
  end

  private
  
  def dispatch
    TYPES.each do |type|
      send_responders(type)
    end
    resolve_emergencies()
  end

  def send_responders(type)
    responders  = on_duty_responders_by_type(type).to_a
    emergencies = sort_severity(type) 
    severity_attr = "#{type.to_s}_severity"

    emergencies.each do |emergency|
      severity = emergency[severity_attr]
      emergency_result = @results.find { |result| result[:emergency] == emergency } ||
                         new_result(emergency)
      until severity <= 0 || responders.length == 0
        responder = matchResponder(severity, responders)
        @available_on_duty_responders = available_on_duty_responders.where.not(id: responder.id)
        dispatched_responders[type].push(responder)
        severity -= responder.capacity
                
        emergency_result[:responders].push(responder)
      end
      emergency_result[:resolved][type] = true if severity <= 0
    end
  end

  def new_result(emergency)
    resolved = {}
    TYPES.each { |type| resolved[type] = false }
    resolved[:all] = false

    new_result = { emergency:  emergency,
                   resolved:   resolved,
                   responders: [] }
    @results.push(new_result)

    new_result
  end

  def resolve_emergencies
    @results.each do |result|
      result[:resolved][:all] = TYPES.inject(true) {|resolved, type| resolved && result[:resolved][type] }
    end
  end

  def sort_severity(type)
    severity_attr = "#{type.to_s}_severity"
    @emergencies.sort do |x, y|
      y[severity_attr] <=> x[severity_attr]
    end
  end

  def on_duty_responders_by_type(type)
    type_attr = type.to_s.capitalize
    on_duty_responders.where(type: type_attr)
  end

  def matchResponder(severity, responders)
    responders.find { |responder| responder.capacity == severity } || responders.pop
  end
end
