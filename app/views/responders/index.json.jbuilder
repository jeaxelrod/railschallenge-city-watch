json.responders @responders do |responder|
  json.(responder, :emergency_code, :type, :name, :capacity, :on_duty)
end

