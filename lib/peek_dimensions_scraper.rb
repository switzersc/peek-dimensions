require 'open-uri'
require 'nokogiri'

# WIP
class PeekDimensionsScraper
  def scrape_dimensions(uri, should_read_image)
    html = Nokogiri::HTML(open(uri))
    html.xpath('//img').each do |img|
      if should_read_image.call(img)
        r = PeekDimensions.new
        puts r.get(img['src']).to_s
      end
    end
  end
end