$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.dirname(__FILE__))

require 'peek_dimensions'
require 'ext/net_http'

module PeekDimensionsSpecHelper
  KNOWN_DIMENSIONS = {
    'jpg/sample-1.jpg' => [471, 274]

  }

  def fixture_path(fixture_sub_path)
    File.join(File.expand_path(File.dirname(__FILE__)), 'fixtures', fixture_sub_path)
  end

  def fixture_dimensions(fixture_sub_path)
    KNOWN_DIMENSIONS[fixture_sub_path]
  end
end