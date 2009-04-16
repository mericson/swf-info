  class SwfInfo 

    require 'rubygems'
    require 'bindata'
    require 'open-uri'
    require 'zlib'

    attr_reader :path, :compressed, :version, :file_length, :width, :height
    
    def initialize( file ) 
      
      @path = file
      
      ##puts "Opening #{file}"
      
      open( file, "rb" ) do |f|
        
        sig = Sig.read( f )
        ##puts "Compressed flag is #{sig.compressed_flag}"
        ##puts "Version is #{sig.version}"
        ##puts "File length is #{sig.file_length}"
       
        if sig.compressed_flag == 'C'
          rest = CompressedData.read( f )
          swf = Zlib::Inflate.inflate( rest.rest )
          
        else
          rest = UncompressedData.read( f )
          swf = rest.rest
          
        end
        
        ##i = 0
        ##swf.each_byte do |b|
          
        ##  puts sprintf( "%02d: %08b %8d %2x %s", i, b, b, b, b.chr )
        ##  break if i >= 20
          
        ##  i += 1
        
        ##end          
        
        size = PackedRect.read( swf )
        rect = Rect.new( size.nbits, size.bit_array.collect { |q| q } )

        ##puts "Rect legnth is #{size.nbits}"
        ##puts "Size is #{a[0]/20}, #{a[2]/20} - #{a[1]/20}, #{a[3]/20}"          
        
        @path = file
        @compressed = (sig.compressed_flag == 'C' )
        @version = sig.version
        @file_length = sig.file_length 

        @width  = rect.values[1] / 20
        @height = rect.values[3] / 20
      end
    end
    
    class SwfInfo::Sig < BinData::MultiValue
      endian   :little
      
      string   :compressed_flag, :read_length => 1
      string   :remainder_sig,   :read_length => 2
      uint8    :version
      uint32   :file_length
    end

    class SwfInfo::CompressedData < BinData::MultiValue
      rest :rest
    end
    
    class SwfInfo::UncompressedData < BinData::MultiValue
      rest :rest
    end
    
    class SwfInfo::PackedRect < BinData::MultiValue
      bit5   :nbits
      array  :bit_array, :type => :bit1, :initial_length => lambda { nbits * 4 }
      array  :filler, :type => :bit1, :initial_length => lambda { 
        skip_bits = ( nbits * 4 ) % 8 == 0 ? 0 : 8 - ( (nbits * 4) % 8 ) 
      }
      
    end
    
    class SwfInfo::Rect 
      
      attr_reader :values

      def initialize( nbits, data, field_map = {} )
        @values = []
        
        ( data.length / nbits ).times do |i|
          sum = 0
          nbits.downto( 1 ) do |n|
            exp = n - 1
            sum += data.shift * (2 ** exp)
          end
          @values << sum
        end
      end
    end
  end

