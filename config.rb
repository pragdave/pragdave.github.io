###
# middleman-casper configuration
###

config[:casper] = {
  blog: {
    url: 'https://pragdave.me',
    name: 'PragDave',
    description: 'Consulting • Teaching • Speaking • Elixir • Ruby',
    date_format: '%d %B %Y',
    navigation: true,
    logo: '/images/dave_gnome_head.jpg'
  },
  author: {
    name: 'PragDave',
    bio: nil, # Optional
    location: nil, # Optional
    website: "https://pragdave.me",
    gravatar_email: "dave@thomases.com",
    twitter: "@pragdave"
  },
  navigation: {
    "Home" => "/"
  }
}

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

after_build do
  File.rename 'build/feed.xml', 'build/index.xml'
end

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (https://middlemanapp.com/advanced/dynamic_pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

def get_tags(resource)
  if resource.data.tags.is_a? String
    resource.data.tags.split(',').map(&:strip)
  else
    resource.data.tags
  end
end

def group_lookup(resource, sum)
  results = Array(get_tags(resource)).map(&:to_s).map(&:to_sym)

  results.each do |k|
    sum[k] ||= []
    sum[k] << resource
  end
end

tags = resources
  .select { |resource| resource.data.tags }
  .each_with_object({}, &method(:group_lookup))

tags.each do |tag, articles|
  proxy "/tag/#{tag.downcase.to_s.parameterize}/feed.xml", '/feed.xml',
    locals: { tag: tag, articles: articles[0..5] }, layout: false
end

proxy "/author/#{config.casper[:author][:name].parameterize}.html",
  '/author.html', ignore: true

# General configuration
# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

###
# Helpers
###

helpers do

  def by_tag
    blog
      .tags
      .sort_by{ |t,a| t }
      .map do |tag, articles|

      content_tag(:li) do
        content_tag(:a, href: "/tag/#{tag}") do
          "#{tag} (#{articles.size})"
        end
      end
    end
  end

  def by_year
    blog
      .articles
      .map {|a| a.date.year }
      .uniq
      .map { |year|
      content_tag(:li) do
        content_tag(:a, href: blog_year_path(year, "PragDave" )) do
          year.to_s
        end
      end
      }
  end

  def last_n_posts(n)
    blog.articles[0...n].map do |article|
      content_tag(:li) do
        content_tag(:a, href: article.url) do
          article.title
        end
      end
    end
  end

  def sub_list(title, cls, list)
    content_tag(:div, class: "card #{cls}") do
      content_tag(:div, class: "card-header") do
        content_tag(:h4, title, class: "nav-heading")
      end +
      content_tag(:div, class: "card-block") do
        content_tag(:ul, list)
      end
    end
  end


  def full_blog_navigation_list
    content_tag(:div, :sidenav) do
      [
        sub_list("Last 5 posts", "sub-lines", last_n_posts(5)),
        sub_list("By tag",       "sub-cloud by-tag", by_tag),
        sub_list("By year",      "sub-cloud by-year", by_year),
      ]
        .flatten.join("\n")
    end

    #   - if href.respond_to?(:each)
    #     %li{class: "nav-heading"}
    #       = label
    # [ *config[:casper][:navigation],
    # ]
  end
end



activate :blog do |blog|
  # This will add a prefix to all links, template references and source paths
  # blog.prefix = "blog"

  blog.name = "PragDave"
  blog.permalink = "blog/{year}/{month}/{day}/{title}.html"
  # Matcher for blog source files
  blog.sources = "blog/{year}-{month}-{day}-{title}.html"
  blog.taglink = "tag/{tag}.html"
  # blog.layout = "layout"
  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  # blog.year_link = "{year}.html"
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  blog.tag_template = "tag.html"

  blog.calendar_template = "calendar.html"

  # Enable pagination
  blog.paginate = true
  # blog.per_page = 10
  # blog.page_link = "page/{num}"
end

# Pretty URLs - https://middlemanapp.com/advanced/pretty_urls/
activate :directory_indexes

# Middleman-Syntax - https://github.com/middleman/middleman-syntax
set :haml, { ugly: true }

set :markdown_engine, :redcarpet

set(:markdown,
    fenced_code_blocks: true,
    smartypants: true,
    footnotes: true,
    link_attributes: { rel: 'nofollow' },
    tables: true)

activate :syntax, line_numbers: false




class Tilt::LiquidTemplate < Tilt::Template
  def evaluate(scope, locals, &block)
    locals = locals.inject({}){ |h,(k,v)| h[k.to_s] = v ; h }
    if scope.respond_to?(:to_h)
      scope  = scope.to_h.inject({}){ |h,(k,v)| h[k.to_s] = v ; h }
      locals = scope.merge(locals)
    end
    locals['yield'] = block.nil? ? '' : yield
    locals['content'] = locals['yield']
    @engine.render(locals, {registers: {
      middleman: scope
    }})
  end
end

module LiquidHelpers
  class Img < Liquid::Tag
    def initialize(tag_name, img_name, tokens)
      super
      @img_name = img_name
    end

    def render(context)
      %{<img class="img-fluid" src="#{@img_name}">}
    end
  end

  Liquid::Template.register_tag('img', Img)









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



  class Blockquote < Liquid::Block
    FullCiteWithTitle = /(\S.*)\s+(https?:\/\/)(\S+)\s+(.+)/i
    FullCite = /(\S.*)\s+(https?:\/\/)(\S+)/i
    AuthorTitle = /([^,]+),([^,]+)/
    Author =  /(.+)/

    def initialize(tag_name, markup, tokens)
      @by = nil
      @source = nil
      @title = nil
      if markup =~ FullCiteWithTitle
        @by = $1
        @source = $2 + $3
        @title = $4.titlecase.strip
      elsif markup =~ FullCite
        @by = $1
        @source = $2 + $3
      elsif markup =~ AuthorTitle
        @by = $1
        @title = $2.titlecase.strip
      elsif markup =~ Author
        @by = $1
      end
      super
    end

    def render(context)
      quote = paragraphize(super)
      author = "<strong>#{@by.strip}</strong>" if @by
      if @source
        url = @source.match(/https?:\/\/(.+)/)[1].split('/')
        parts = []
        url.each do |part|
          if (parts + [part]).join('/').length < 32
            parts << part
          end
        end
        source = parts.join('/')
        source << '/&hellip;' unless source == @source
      end
      if !@source.nil?
        cite = " <cite><a href='#{@source}'>#{(@title || source)}</a></cite>"
      elsif !@title.nil?
        cite = " <cite>#{@title}</cite>"
      end
      blockquote = if @by.nil?
        quote
      elsif cite
        "#{quote}<footer>#{author + cite}</footer>"
      else
        "#{quote}<footer>#{author}</footer>"
      end
      "<blockquote>#{blockquote}</blockquote>"
    end

    def paragraphize(input)
      "<p>#{input.lstrip.rstrip.gsub(/\n\n/, '</p><p>').gsub(/\n/, '<br/>')}</p>"
    end
  end

  Liquid::Template.register_tag('blockquote', Blockquote)



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

  Liquid::Template.register_tag('img', ImageTag)

end




# Build-specific configuration
configure :build do
  # Minify CSS on build
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  # activate :relative_assets

  # Ignoring Files
  ignore 'javascripts/_*'
  ignore 'javascripts/vendor/*'
  ignore 'stylesheets/_*'
  ignore 'stylesheets/vendor/*'
end
