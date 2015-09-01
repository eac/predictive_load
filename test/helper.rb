require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/rg'
require 'active_record'
require 'predictive_load'
require 'predictive_load/active_record_collection_observation'
require 'query_diet/logger'
require 'query_diet/active_record_ext'

ActiveRecord::Base.class_eval do
  include PredictiveLoad::ActiveRecordCollectionObservation
end

database_config = YAML.load_file(File.join(File.dirname(__FILE__), 'database.yml'))
ActiveRecord::Base.establish_connection(database_config['test'])
ActiveRecord::Base.default_timezone = :utc
require_relative 'schema'
require_relative 'models'

def assert_queries(num = 1)
  old = QueryDiet::Logger.queries.dup
  result = yield
  new = QueryDiet::Logger.queries[old.size..-1]
  assert_equal num, new.size, "#{new.size} instead of #{num} queries were executed.#{new.size == 0 ? '' : "\nQueries:\n#{new.map(&:first).join("\n")}"}"
  result
end
