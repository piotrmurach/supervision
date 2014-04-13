# encoding: utf-8

require 'supervision'
require 'timeout'

module Helpers
  def wait_for(duration = nil)
    Timeout.timeout 1 do
      sleep(duration || 0.01) until yield
    end
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.include Helpers
end
