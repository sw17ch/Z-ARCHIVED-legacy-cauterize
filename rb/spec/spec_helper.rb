require 'require_all'
require 'mocha/api'

RSpec.configure do |config|
  config.mock_framework = :mocha
end

require_all Dir[File.dirname(__FILE__) + '/../lib/**/*.rb']
