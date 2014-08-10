require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PeekDimensions do
  include PeekDimensionsSpecHelper

  subject { PeekDimensions }

  describe "read_jpeg" do
    it "returns jpeg dimensions" do
      fixture = 'jpg/sample-1.jpg'
      subject.dimensions(fixture_path(fixture)).should == fixture_dimensions(fixture)
    end

    it "returns gif dimensions" do
      fixture = 'gif/sample-1.gif'
      subject.dimensions(fixture_path(fixture)).should == fixture_dimensions(fixture)
    end

    xit "returns png dimensions" do
      fixture = 'png/sample-1.png'
      subject.dimensions(fixture_path(fixture)).should == fixture_dimensions(fixture)
    end

    xit "returns bmp dimensions" do
      fixture = 'bmp/sample-1.bmp'
      subject.dimensions(fixture_path(fixture)).should == fixture_dimensions(fixture)
    end
  end
end