require 'stringio'
require 'net/http'

#
# References for image formats:
# http://en.wikipedia.org/wiki/Graphics_Interchange_Format
# http://en.wikipedia.org/wiki/Portable_Network_Graphics
# http://en.wikipedia.org/wiki/BMP_file_format
# http://en.wikipedia.org/wiki/JPEG
class PeekDimensions
  attr_reader :height, :width

  def initialize(uri)
    @read_handler = :read_unknown
    @io = StringIO.new
    @io.string.force_encoding('ASCII-8BIT')
    @width, @height = read_dimensions(uri)
  end

  def dimensions
    return @width, @height
  end

  def self.dimensions(uri)
    new(uri).dimensions
  end

  private

  def read_dimensions(uri)
    parsed_uri = uri.kind_of?(URI) ? uri : URI.parse(uri)
    http = Net::HTTP.new(parsed_uri.host)
    
    http.request_get(parsed_uri.path) do |response|
      response.read_body do |chunk|
        # append chunk to the end of io and return io.pos to its last location
        pos = @io.pos
        @io.pos = @io.length
        @io << chunk
        @io.pos = pos
        dimensions = read_dimensions_handler
        return dimensions if dimensions.is_a? Array
      end
    end

    return nil,nil
  end

  # Helper method for the common case of needing to read a length
  # of bytes from io, but not knowing if the length of bytes exists.
  # Returns the result of String#unpack, or nil when length exceeds
  # available bytes.
  def read_and_unpack(length, format)
    if @io.pos + length - 1 < @io.length
      return @io.read(length).unpack(format)
    end

    nil
  end

  # Invoke @read_handler
  def read_dimensions_handler
    send(@read_handler)
  end

  def read_unknown
    img_str = @io.string
    if    img_str[0,2] == "\xFF\xD8"         then @read_handler = :read_jpeg
    elsif img_str[0,4] == "\x47\x49\x46\x38" then @read_handler = :read_gif
    elsif img_str[0,2] == "\x42\x4D"         then @read_handler = :read_bmp
    end

    read_dimensions_handler unless @read_handler == :read_unknown
  end

  def read_gif
    @io.seek(6)
    read_and_unpack(4, 'vv')
  end

  def read_jpeg
    # TODO: eliminate sof_markers array
    sof_markers = ["\xc0", "\xc1", "\xc2", "\xc3","\xc5", "\xc6", "\xc7","\xc9", "\xca", "\xcb","\xcd", "\xce", "\xcf"]
    @io.seek(2) if @io.pos == 0 # Skip SOI marker
    until @io.eof? do
      unpacked = read_and_unpack(4, 'aan')
      break if unpacked.nil?
      
      marker, segment_code, segment_length = unpacked
      
      if sof_markers.include? segment_code
        unpacked = read_and_unpack(5, 'xnn')
        if unpacked.nil?
          # missing part of the segment. reset io position to beginning of segment.
          @io.pos = @io.pos - 4
          break
        else
          return unpacked.reverse # reverse because jpeg height comes before width
        end 
      else
        @io.seek(segment_length - 2, 1) # Skip to the next segment
      end
    end
  end

end
