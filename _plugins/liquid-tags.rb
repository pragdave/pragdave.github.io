module LiquidTags

  # class Img < Liquid::Tag
  #   def initialize(tag_name, img_name, tokens)
  #     super
  #     @img_name = img_name
  #   end
  # 
  #   def render(context)
  #     raise "here"
  #     %{<img class="img-fluid" src="#{@img_name}">}
  #   end
  # end
  # 
  # Liquid::Template.register_tag('img', Img)

  ######################################################################

  class CaptionImageTag < Liquid::Tag
    @img = nil
    @title = nil
    @class = ''
    @width = ''
    @height = ''

    def initialize(tag_name, markup, tokens)
      if markup =~ %r{(\S.*\s+)?(\.?/|/|https?://)(\S+)(\s+\d+\s+\d+)?(\s+.+)?}i
        @class = $1 || ''
        @img = $2 + $3
        if $5
          @title = $5.strip
          @attr_title = CGI.escape(@title)
        end
        if $4 =~ /\s*(\d+)\s+(\d+)/
          @width = $1
          @height = $2
        end
      end
      super
    end

    def render(context)
      output = super
      if @img
        "<span class='#{('caption-wrapper ' + @class).rstrip}'>" +
          "<img class='img-fluid caption' src='#{@img}' width='#{@width}' height='#{@height}' title='#{@attr_title}'>" +
          "<span class='caption-text'>#{@title}</span>" +
        "</span>"
      else
        "Error processing input, expected syntax: {% img [class name(s)] /url/to/image [width height] [title text] %}"
      end
    end
  end

  Liquid::Template.register_tag('imgcap', CaptionImageTag)

  ######################################################################

  class DtAudioTag < Liquid::Tag
    @audio = nil

    def initialize(tag_name, markup, tokens)
      @name  = markup.strip
      super
    end

    def render(context)
      output = super

      base  = File.join(File.dirname(__FILE__), "source/blog")

      cover = "music/artwork/#{@name}.jpg"
      score = "music/score/#{@name}.pdf"

      audio = [ '<div class="dt-audio">' ]

      if File.exist?(File.join(base, cover))
        audio << '<div class="dt-cover">'
        if File.exist?(File.join(base, score))
          audio << %{<a href="/blog/#{score}">}
        end
        audio << %{<img class="img-fluid"  src="/blog/#{cover}"/>}
        if File.exist?(File.join(base, score))
          audio << %{</a>}
        end
        audio << "</div>"
      end
      audio << "<audio controls>"
      audio << "<source src='/blog/music/audio/#{@name}.mp3'>"
      audio << "</audio>"
      audio << "</div>"
      audio.join("\n")
    end
  end

  Liquid::Template.register_tag('dtaudio', DtAudioTag)



  ######################################################################

  class ImageTag < Liquid::Tag
    @img = nil

    def initialize(tag_name, markup, tokens)
      attributes = ['class', 'src', 'width', 'height', 'title']

      if markup =~ /(?<class>\S.*\s+)?(?<src>(?:https?:\/\/|\/|\S+\/)\S+)(?:\s+(?<width>\d+))?(?:\s+(?<height>\d+))?(?<title>\s+.+)?/i
        @img = attributes.reduce({}) { |img, attr| img[attr] = $~[attr].strip if $~[attr]; img }
        if /(?:"|')(?<title>[^"']+)?(?:"|')\s+(?:"|')(?<alt>[^"']+)?(?:"|')/ =~ @img['title']
          @img['title']  = title
          @img['alt']    = alt
        else
          @img['alt']    = @img['title'].gsub!(/"/, '&#34;') if @img['title']
        end
        @img['class'].gsub!(/"/, '') if @img['class']
      end
      super
    end

    def render(context)
      if @img
        "<img #{@img.collect {|k,v| "#{k}=\"#{v}\"" if v}.join(" ")}>"
      else
        "Error processing input, expected syntax: {% img [class name(s)] [http[s]:/]/path/to/image [width [height]] [title text | \"title text\" [\"alt text\"]] %}"
      end
    end
  end

  Liquid::Template.register_tag('img1', ImageTag)

end
