module Browsed
  class InvalidBrowserError < StandardError; end
  class TooManyProcessesError < StandardError; end
  class PotentiallyStaleProxyError < StandardError; end
end
