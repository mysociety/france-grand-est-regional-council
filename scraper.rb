# frozen_string_literal: true

require 'pry'
require 'require_all'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

# require_rel 'lib'

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

class MembersPage < Scraped::HTML
  field :members do
    noko.css('.tshowcase-box').map { |box| fragment(box => Member) }
  end
end

class Member < Scraped::HTML
  field :id do
    noko[:id]
  end

  field :name do
    noko.css('.tshowcase-box-title').text
  end

  field :title do
    noko.css('.tshowcase-box-details').text
  end
end

url = 'http://www.alsacechampagneardennelorraine.eu/la-region-alsace-champagne-ardenne-lorraine/les-elus/'
page = scrape(url => MembersPage)

page.members.each do |member|
  data = member.to_h
  ScraperWiki.save_sqlite([:id], data)
end
