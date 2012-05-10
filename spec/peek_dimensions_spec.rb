require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PeekDimensions do
  include PeekDimensionsSpecHelper

  subject { PeekDimensions }

  describe "read_jpeg" do
    it "returns jpeg dimensions" do
      fixture = 'jpg/sample-1.jpg'
      subject.dimensions(fixture_path(fixture)).should == fixture_dimensions(fixture)
    end
  end
end