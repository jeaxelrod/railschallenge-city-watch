require "test_helper"

class ResponderTest < ActiveSupport::TestCase

  def responder
    @responder ||= FactoryGirl.create(:responder) 
  end

  def test_valid
    assert responder.valid?
  end

  def test_type_cant_be_changed
    case responder.type
    when "Police"
      responder.type = "Fire"
    when "Fire"
      responder.type = "Medical"
    when "Medical"
      responder.type = "Police"
    end
    assert !responder.valid?
  end

  def test_capacity_cant_be_changed
    unless responder.capacity == 1
      responder.capacity -= 1
    else
      responder.capacity += 1
    end
    assert !responder.valid?
  end

  def test_capacity_valid_range_min
    responder = FactoryGirl.create(:responder, capacity: 1)
    assert responder.valid?
  end

  def test_capacity_valid_range_max
    responder = FactoryGirl.create(:responder, capacity: 5)
    assert responder.valid?
  end

  def test_capacity_invalid_range_below
    assert_raise(ActiveRecord::RecordInvalid) { FactoryGirl.create(:responder, capacity: 0) }
  end

  def test_capacity_invalid_range_above
    assert_raise(ActiveRecord::RecordInvalid) { FactoryGirl.create(:responder, capacity: 6) }
  end

  def test_name_is_unique
    assert_raise(ActiveRecord::RecordInvalid) do
      FactoryGirl.create(:responder, name: responder.name) 
    end
  end

end
