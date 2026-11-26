# frozen_string_literal: true

require "capybara/selenium/driver"
require "capybara/selenium/driver_specializations/chrome_driver"

# Chrome 158 (GitHub runners, 25 Nov 2026) rejects the wildcard origin Capybara 3.40 uses when it
# resets the browser between examples:
#   execute_cdp("Storage.clearDataForOrigin", origin: "*", ...)
#   => Selenium::WebDriver::Error::InvalidArgumentError: invalid argument: * is not a valid URL
# which made every system spec fail at teardown. When Chrome refuses "*", clear the cookies with
# Network.clearBrowserCookies and the storage of the origin the example last visited instead.
# Older Chrome versions accept "*" and never reach the fallback.
module ChromeStorageClearFix
  def reset!
    url = begin
      current_url
    rescue StandardError
      nil
    end
    @last_storage_origin = origin_of(url)
    super
  end

  private

  def execute_cdp(cmd, params = {})
    super
  rescue Selenium::WebDriver::Error::InvalidArgumentError
    raise unless cmd == "Storage.clearDataForOrigin" && params[:origin] == "*"

    super("Network.clearBrowserCookies")
    super(cmd, params.merge(origin: @last_storage_origin)) if @last_storage_origin
  end

  def origin_of(url)
    return nil unless url.to_s.start_with?("http")

    uri = URI.parse(url)
    default_port = uri.port == uri.default_port
    "#{uri.scheme}://#{uri.host}#{":#{uri.port}" unless default_port}"
  rescue URI::InvalidURIError
    nil
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeStorageClearFix)
