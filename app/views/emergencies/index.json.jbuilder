json.emergencies @emergencies do |emergency|
  json.(emergency, :code, :fire_severity, :police_severity, :medical_severity)
end
