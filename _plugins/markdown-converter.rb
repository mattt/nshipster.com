# frozen_string_literal: true

require 'yaml'

require 'jekyll'
require 'nokogiri'

module Jekyll
  module Converters
    class Markdown
      # :nodoc:
      class NSHipsterProcessor
        def initialize(config)
          @kramdown = KramdownParser.new(config)
        end

        def convert(content)
          html = @kramdown.convert(content)
          doc = Nokogiri::HTML::DocumentFragment.parse(html)

          remove_proprietary_attributes!(doc)
          secure_links_to_cross_origin_destinations!(doc)
          transform_apple_trademarks!(doc)
          transform_code_symbols!(doc)

          doc.to_html
        end

        private

        def remove_proprietary_attributes!(doc)
          doc.css('[markdown]').each do |element|
            element.remove_attribute('markdown')
          end
        end

        def transform_code_symbols!(doc)
          doc.css('p > code, li > code, td > code').each do |code|
            code.remove_attribute('class')
            code.inner_html = code.inner_html.gsub(/(?:([a-z])([A-Z]+))/, '\\1<wbr/>\\2')
          end
        end

        def transform_apple_trademarks!(doc)
          doc.css('p, li, td').each do |p|
            p.inner_html = p.inner_html.gsub(/iPhone X([SR])/, 'iPhone X<small>\\1</small>')
          end
        end

        def secure_links_to_cross_origin_destinations!(doc)
          doc.css('a[href]').each do |a|
            href = a.attr('href')
            next if href.match?(/^\/|#{ENV['DOMAIN']}/)

            a['rel'] = 'noopener'
          end
        end
      end
    end
  end
end
