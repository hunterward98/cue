# Coverage must start before any application code loads, so this sits at the
# very top of the very first file RSpec requires.
require "simplecov"

SimpleCov.start "rails" do
  enable_coverage :branch
  # Distinct command names let SimpleCov merge parallel workers and separate
  # unit/system runs into one resultset.
  command_name "rspec#{ENV.fetch("COVERAGE_SUITE", "")}#{ENV.fetch("TEST_ENV_NUMBER", "")}"

  # Deliberately no minimum_coverage here: a single process only sees its
  # slice of the suite (parallel workers, partial local runs), so an
  # in-process gate would false-fail. The absolute 100% line + branch gate is
  # `bin/rails coverage:check`, run after the whole suite. See docs/testing.md.
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "tmp/rspec_examples.txt"
  config.disable_monkey_patching!

  # Random order, reproducible with --seed N (printed on every run).
  config.order = :random
  Kernel.srand config.seed
end
