require 'net/http'

#
# References for image formats:
# http://en.wikipedia.org/wiki/Graphics_Interchange_Format
# http://en.wikipedia.org/wiki/Portable_Network_Graphics
# http://en.wikipedia.org/wiki/BMP_file_format
# http://en.wikipedia.org/wiki/JPEG
class PeekDimensions
  
  def initialize
    @read_handler = :read_unknown
    @io = StringIO.new
    @io.string.force_encoding('ASCII-8BIT')
  end

  def get(uri)
    uri = URI.parse(uri)
    http = Net::HTTP.new(uri.host)
    
    http.request_get(uri.path) do |response|
      response.read_body do |chunk|
        # append chunk to the end of io and return io.pos to its last location
        pos = @io.pos
        @io.pos = @io.length
        @io << chunk
        @io.pos = pos
        dim = read
        return dim if dim.is_a? Array
      end
    end
  end

  private

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

  def read
    send(@read_handler)
  end

  def read_unknown
    img_str = @io.string
    if    img_str[0,2] == "\xFF\xD8"         then @read_handler = :read_jpeg
    elsif img_str[0,4] == "\x47\x49\x46\x38" then @read_handler = :read_gif
    elsif img_str[0,2] == "\x42\x4D"         then @read_handler = :read_bmp
    end

    read unless @read_handler == :read_unknown
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
      marker, segment_code, segment_length = @io.read(4).unpack('aan')
    
      if sof_markers.include? segment_code
        return read_and_unpack(5, 'xnn')
      else
        @io.seek(segment_length - 2, 1) # Skip to the next segment
      end
    end
  end

end
