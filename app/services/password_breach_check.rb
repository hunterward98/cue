# frozen_string_literal: true

require "net/http"

# k-anonymity check against the Pwned Passwords range API (auth plan_3):
# only the first five hex chars of the SHA-1 ever leave the box. Runs on
# password set/change only — never on login — and fails open with a
# logged warning: signup availability beats perfection of the check.
class PasswordBreachCheck
  API_HOST = "api.pwnedpasswords.com"
  TIMEOUT = 2 # seconds

  def self.breached?(password)
    new.breached?(password)
  end

  def breached?(password)
    digest = OpenSSL::Digest::SHA1.hexdigest(password).upcase
    prefix = digest[0, 5]
    suffix = digest[5..]

    response = fetch_range(prefix)
    return false if response.nil?

    response.lines.any? { |line| line.split(":").first == suffix }
  end

  private

  def fetch_range(prefix)
    http = Net::HTTP.new(API_HOST, 443)
    http.use_ssl = true
    http.open_timeout = TIMEOUT
    http.read_timeout = TIMEOUT

    response = http.get("/range/#{prefix}", { "Add-Padding" => "true" })
    return response.body if response.is_a?(Net::HTTPSuccess)

    warn_unavailable("HTTP #{response.code}")
    nil
  rescue Timeout::Error, SystemCallError, OpenSSL::SSL::SSLError, SocketError => error
    warn_unavailable(error.class.name)
    nil
  end

  def warn_unavailable(reason)
    Rails.logger.warn("PasswordBreachCheck unavailable (#{reason}) — failing open")
  end
end
