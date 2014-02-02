# Title:
#		Octopress HTML5 Audio Tag
#		http://antoncherkasov.me/projects/octopress-plugins
#
#               Modified by DT to allow cover artwork and score
# Author:
#		Anton Cherkasov
#		http://antoncherkasov.me
#		antoncherkasov@me.com
# Syntax:
#		{% audio url/to/mp3 %}
#		{% audio url/to/mp3 cover %}
#		{% audio url/to/mp3 cover score %}
# Example:
#		{% audio http://example.org/music.mp3 /img/cover.jpg /music/score.pdf %}
module Jekyll
  class DtAudioTag < Liquid::Tag
    @audio = nil
    
    def initialize(tag_name, markup, tokens)
      @name  = markup.strip
      super
    end
    
    def render(context)
      output = super
      base = context.registers[:site].config['source']
      audio = [ '<div class="dt-audio">' ]
      cover = "/music/artwork/#{@name}.jpg"
      score = "/music/score/#{@name}.pdf"

      if File.exist?(File.join(base, cover))
        audio << '<div class="dt-cover">'
        if File.exist?(File.join(base, score))
          audio << %{<a href="#{score}">}
        end
        audio << %{<img src="#{cover}"/>}
        if File.exist?(File.join(base, score))
          audio << %{</a>}
        end
        audio << "</div>"
      end
      audio << "<audio controls>"
      audio << "<source src='/music/audio/#{@name}.mp3'>"
      audio << "</audio>"
      audio << "</div>"
      audio.join("\n")
    end
  end
end
 
Liquid::Template.register_tag('dtaudio', Jekyll::DtAudioTag)
