require 'nokogiri'

module Jekyll
    module Tags
      class ProTocGenerator < Jekyll::Generator
        def generate(site)
          parser = Jekyll::Converters::Markdown.new(site.config)

          site.pages.each do |page|
            page.data["subnav"] << { "title" => 'Test Generator', "url" => 'Test Generator' }
          end
        end
      end
      class RenderTocPro < Liquid::Tag
            def initialize(tag_name, input, tokens)
                  super
            end
            def render(context)
              @doc = Nokogiri::HTML::DocumentFragment.parse(context.registers[:page]['content'])

              %(<ul id="pro-sidebar" class="js-scroll-nav list-group">\n#{Parser.new(@doc).build_toc_list}</ul>)
            end
      end
      module TableOfContentsFilter
          def pro_toc(html)
              @doc = Nokogiri::HTML::DocumentFragment.parse(html)

              %(<ul id="pro-sidebar" class="js-scroll-nav list-group">\n#{Parser.new(@doc).build_toc_list}</ul>)
          end
      end
      class Parser
        def initialize(html, options = {})
              @doc = Nokogiri::HTML::DocumentFragment.parse(html)
              @entries = parse_content
        end
        def parse_content
          headers = Hash.new(0)

          (@doc.css(toc_headings) - @doc.css(toc_headings_within))
            .reject { |n| n.classes.include?('no_toc_section') }
            .inject([]) do |entries, node|
            text = node.text
            id = node.attribute('id') || 'ryan-id'

            suffix_num = headers[id]
            headers[id] += 1

            entries << {
              id: suffix_num.zero? ? id : "#{id}-#{suffix_num}",
              text: CGI.escapeHTML(text),
              node_name: node.name,
              header_content: node.children.first,
              h_num: node.name.delete('h').to_i
            }
          end
        end

        def toc_headings
            @toc_levels = 2..2
            @toc_levels.map { |level| "h#{level}" }.join(',')
        end

        def toc_headings_within
            @toc_levels = 2..2
            @toc_levels.map { |level| ".no_toc_section h#{level}" }.join(',')
        end

        def build_toc_list
          entries = @entries;
          i = 0
          limit = 3
          hasToggle = 0
          toc_list = +''
          min_h_num = @entries.map { |e| e[:h_num] }.min

          while i < entries.count
            entry = entries[i]
            if entry[:h_num] == min_h_num
              next_i = i + 1
              if next_i <= limit
                  toc_list << %(<li><a href="#" class="js-go-to" data-target="##{entry[:id]}">#{next_i}. #{entry[:text]}</a>)

                  if next_i < entries.count && entries[next_i][:h_num] > min_h_num
                    nest_entries = get_nest_entries(entries[next_i, entries.count], min_h_num)
                    toc_list << %(\n<ul id="pro-sidebar-sub" class="js-scroll-nav list-group">\n#{build_toc_list(nest_entries)}</ul>\n)
                    i += nest_entries.count
                  end
              else
                hasToggle += 1
                toc_list << %(<li id="sidebar-collapse" class="collapse"><a href="#" class="js-go-to" data-target="##{entry[:id]}">#{next_i}. #{entry[:text]}</a>)
              end

              toc_list << %(</li>\n)
            elsif entry[:h_num] > min_h_num
              nest_entries = get_nest_entries(entries[i, entries.count], min_h_num)
              toc_list << build_toc_list(nest_entries)
              i += nest_entries.count - 1
            end
            i += 1
          end
          if hasToggle > 0
             toc_list << %(<div id="blog-sidebar-loadmore" data-toggle="collapse" data-target="#sidebar-collapse" aria-expanded="false" aria-controls="sidebar-collapse" style="text-align: center; cursor: pointer; color: #407bff"><i class="fa"></i></div>)
          end
          toc_list
        end

        def get_nest_entries(entries, min_h_num)
            entries.inject([]) do |nest_entries, entry|
              break nest_entries if entry[:h_num] == min_h_num

              nest_entries << entry
            end
          end
      end
  end
end

Liquid::Template.register_filter(Jekyll::Tags::TableOfContentsFilter)
Liquid::Template.register_tag('render_toc', Jekyll::Tags::RenderTocPro)