require 'test_helper'

class EmergencyTest < ActiveSupport::TestCase
  def emergency
    @emergency ||= FactoryGirl.create(:emergency)
  end

  def test_valid
    assert emergency.valid?
  end

  def test_code_is_unique
    assert_raise(ActiveRecord::RecordInvalid) do
      FactoryGirl.create(:emergency, code: emergency.code)
    end
  end

  def test_code_cant_be_blank
    assert_raise(ActiveRecord::RecordInvalid) do
      FactoryGirl.create(:emergency, code: '')
    end
  end

  def test_fire_severity_cant_be_blank
    assert_raise(ActiveRecord::RecordInvalid) do
      FactoryGirl.create(:emergency, fire_severity: nil)
    end
  end

  def test_police_severity_cant_be_blank
    assert_raise(ActiveRecord::RecordInvalid) do
      FactoryGirl.create(:emergency, police_severity: nil)
    end
  end

  def test_medical_severity_cant_be_blank
    assert_raise(ActiveRecord::RecordInvalid) do
      FactoryGirl.create(:emergency, medical_severity: nil)
    end
  end

  def test_fire_severity_greater_or_equal_to_zero
    assert_raise(ActiveRecord::RecordInvalid) do
      FactoryGirl.create(:emergency, fire_severity: -1)
    end
  end

  def test_police_severity_greater_or_equal_to_zero
    assert_raise(ActiveRecord::RecordInvalid) do
      FactoryGirl.create(:emergency, police_severity: -1)
    end
  end

  def test_medical_severity_greater_or_equal_to_zero
    assert_raise(ActiveRecord::RecordInvalid) do
      FactoryGirl.create(:emergency, medical_severity: -1)
    end
  end
end
