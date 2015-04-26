require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

Rails::TestTask.new('test:models' => 'test:prepare') do |t|
  t.pattern = 'test/models/**/*_test.rb'
end
