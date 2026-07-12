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

    # Self-improvement plan_3: "if a skill isn't getting triggered, wire
    # it better" made mechanical — every skill records the phrases that
    # must load it, so a miss is a documented rewrite, not a vibe.
    Dir[".claude/skills/*/SKILL.md"].each do |skill|
      content = File.read(skill)
      failures << "#{skill}: missing frontmatter 'name:'" unless content.match?(/^name:\s*\S+/)
      failures << "#{skill}: missing frontmatter 'description:'" unless content.match?(/^description:\s*\S+/)
      failures << "#{skill}: missing '## Trigger tests' section" unless content.include?("## Trigger tests")

      trigger_section = content[/## Trigger tests.*?(?=^## |\z)/m].to_s
      prompt_count = trigger_section.scan(/^\d+\.\s/).size
      if prompt_count < 3
        failures << "#{skill}: needs at least 3 recorded trigger-test prompts (found #{prompt_count})"
      end

      unless content.match?(/Last verified:\*\*\s*\d{4}-\d{2}-\d{2}/)
        failures << "#{skill}: missing a '**Last verified:** YYYY-MM-DD' date"
      end
    end

    abort(failures.join("\n")) if failures.any?
    puts "docs:lint — #{Dir['docs/decisions/[0-9]*.md'].size} ADRs, " \
         "#{Dir['.claude/skills/*/SKILL.md'].size} skills, all structural checks pass"
  end
end
