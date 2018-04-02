require 'feedjira'
require 'nokogiri'
require 'jekyll'

module Jekyll
  class JekyllDisplayMediumPosts < Generator
    safe true
    priority :high
def generate(site)
      jekyll_coll = Jekyll::Collection.new(site, 'medium_posts')
      site.collections['medium_posts'] = jekyll_coll
Feedjira::Feed.fetch_and_parse("https://medium.com/feed/" + ENV["MEDIUM_PUBLICATION"]).entries.each do |e|
        p "Title: #{e.title}, published on Medium #{e.url} #{e}"
        # Parse HTML to get first image
        page = Nokogiri::HTML(e[:content])
        p "#{page.css('img').first['src']}"
        title_image = page.css('img').first['src']

        # Parse Rest of Feed
        title = e[:title]
        content = e[:content]
        guid = e[:url]
        pubdate = e[:published]
        path = "./medium_posts/" + title.gsub(' ', '-') + ".md"
        path = site.in_source_dir(path)
        doc = Jekyll::Document.new(path, { :site => site, :collection => jekyll_coll })
        doc.data['layout']='medium_post';
        doc.data['title'] = title;
        doc.data['title_image'] = title_image;
        doc.data['feed_content'] = content;
        doc.data['original_url']=guid;
        doc.data['date']=pubdate.to_datetime;
        jekyll_coll.docs << doc
      end
    end
  end
end
