# frozen_string_literal: true

namespace :coverage do
  desc "Collate all SimpleCov resultsets and enforce 100% line + branch coverage"
  task :check do
    require "simplecov"

    resultsets = Dir["coverage/.resultset.json"]
    abort("coverage:check: no coverage/.resultset.json found — run the specs first") if resultsets.empty?

    # The suite records coverage without a per-process minimum (see
    # spec/spec_helper.rb); this task merges every worker's results and is
    # the single place the 100% bar is enforced. Exits non-zero on a miss.
    SimpleCov.collate resultsets, "rails" do
      enable_coverage :branch
      minimum_coverage line: 100, branch: 100
    end
  end
end
