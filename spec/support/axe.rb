require "axe/configuration"

# axe-core-rspec's own matcher assumes a Selenium driver (it calls
# `.manage.timeouts` and window-switching APIs Cuprite/Ferrum don't
# implement) — incompatible with the Cuprite driver this suite runs on.
# We still want the real axe-core engine, so this injects the same JS
# bundle the gem ships (`axe-core-api`'s vendored `axe.min.js`) and runs
# it directly through Capybara's driver-agnostic script evaluation.
module AxeHelpers
  def assert_no_axe_violations(tags: %w[wcag2a wcag2aa])
    page.execute_script(Axe::Configuration.instance.jslib) unless page.evaluate_script("!!window.axe")

    results = page.evaluate_async_script(<<~JS)
      var callback = arguments[arguments.length - 1];
      axe.run(document, { runOnly: { type: 'tag', values: #{tags.to_json} } })
        .then(function (results) { callback(results.violations); });
    JS

    summary = results.map do |violation|
      targets = violation["nodes"].flat_map { |node| node["target"] }.join(", ")
      "#{violation['id']} (#{violation['impact']}): #{violation['help']} — #{targets}"
    end

    expect(summary).to eq([]), "axe found violations:\n#{summary.join("\n")}"
  end
end

RSpec.configure do |config|
  config.include AxeHelpers, type: :system
end
