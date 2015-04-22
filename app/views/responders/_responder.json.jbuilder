json.responder do
  json.(@responder, :emergency_code, :type, :name, :capacity, :on_duty)
end
