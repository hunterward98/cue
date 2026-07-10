# frozen_string_literal: true

namespace :spec do
  desc "Count :negative-tagged examples — a shrinking count on a PR is a review flag"
  task :negative_count do
    require "json"

    # --out keeps the JSON clean of SimpleCov's end-of-run chatter.
    system("bundle exec rspec --dry-run --tag negative --format json --out tmp/negative_specs.json >/dev/null 2>&1")
    backend = JSON.parse(File.read("tmp/negative_specs.json")).fetch("summary").fetch("example_count")

    frontend = Dir["app/frontend/**/*.test.{ts,tsx}"].sum do |file|
      File.read(file).scan(/\b(?:it|test)\(\s*['"](?:rejects|forbids|fails)/).size
    end

    puts "negative tests — backend: #{backend}, frontend: #{frontend}"
  end
end
