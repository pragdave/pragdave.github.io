module Jekyll
  module SortTagsFilter
    def sort_tags(tags)
      tags.to_a.sort_by {|k,v| k }
    end
  end
end

Liquid::Template.register_filter(Jekyll::SortTagsFilter)
