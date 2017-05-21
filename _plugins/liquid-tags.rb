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


  class HeadshotListTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      @name = markup.strip
    end

    HTML_TOP = '<table class="formats"><tr><th>Size</th><th>.jpg</th><th>.png</th></tr>'

    HTML_ROW = '<tr><td>SIZE</td><td>JPG</td><td>PNG</td></tr>'

    HTML_BOTTOM = '</table>'

    def render(context)
      result = {}
      base = File.join(Dir.pwd, "headshots", @name)
      sizes = Dir.glob(base + "*").map do |img|
        info = `file #{img}`
        if info =~ /(\d{2,}) ?x ?(\d{2,})/
          img_size = [ Integer($1), "#{$1}x#{$2}" ]
          file_size = human_size(File.stat(img).size)
          result[img_size] ||= {}
          result[img_size][File.extname(img)] = [ file_size, img ]
        end
      end

     sizes = result
        .sort_by {|img_size, _| img_size[0]}
        .map     {|img_size, formats|
          HTML_ROW
            .sub(/SIZE/, img_size[1])
            .sub(/PNG/, headshot_link(formats[".png"]))
            .sub(/JPG/, headshot_link(formats[".jpg"]))
      }
      HTML_TOP + sizes.join("\n") + HTML_BOTTOM
    end

    def headshot_link(format)
      url = format[1].sub(/.*images/, "/headshots")
      size = format[0]
      %{<a href="#{url}">#{size}</a>}
    end

    def human_size(size)
      if size > 1_000_000
        sprintf("%2.1fMB", size/1.0e6)
      else
        "#{Integer(size/1000)}kB"
      end
    end
  end

  Liquid::Template.register_tag('headshot_list', HeadshotListTag)

end
