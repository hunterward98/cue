# frozen_string_literal: true

# Structural doc checks (self-improvement plan_2): honesty greps, not prose
# police. Runs in CI's lint job.
namespace :docs do
  desc "Check ADRs match the template and gotcha entries link a mechanism"
  task :lint do
    failures = []

    Dir["docs/decisions/[0-9][0-9][0-9][0-9]-*.md"].each do |adr|
      content = File.read(adr)
      %w[## Context ## Decision ## Why ## Revisit when].each do |section|
        failures << "#{adr}: missing '#{section}'" unless content.include?(section)
      end
    end

    gotchas = File.read("docs/gotchas.md")
    gotchas.scan(/^## (.+)$/).flatten.each do |entry|
      section = gotchas[/^## #{Regexp.escape(entry)}$.*?(?=^## |\z)/m]
      failures << "docs/gotchas.md: '#{entry}' has no 'Mechanism:' link" unless section&.include?("Mechanism:")
    end

    abort(failures.join("\n")) if failures.any?
    puts "docs:lint — #{Dir['docs/decisions/[0-9]*.md'].size} ADRs, all structural checks pass"
  end
end
