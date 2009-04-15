require 'test_helper'

require 'swf_info.rb' 

class SwfInfoTest < Test::Unit::TestCase

  context "Stadiums swf" do
    setup do
      @swf = SwfInfo.new( 'http://graphics8.nytimes.com/packages/flash/newsgraphics/2009/0402-ny-stadiums-hp/BasicProject.swf' )
    end

    should "be compressed" do
      assert_equal true, @swf.compressed
    end    
    
    should "be 337 pixels wide" do
      assert_equal 337, @swf.width
    end

    should "be 290 pixels tall" do
      assert_equal 290, @swf.height
    end
    
  end


end
