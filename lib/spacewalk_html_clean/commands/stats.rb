require 'spacewalk_html_clean/command'

module SpacewalkHtmlClean
  module Commands

    class Stats < Command

      WHITELIST = %w(nav div a p img center ul li i form select option input button \
           span h4 h3 h2 h1 strong hr table tr td ol th textarea hidden \
           title h5 style thead pre tbody em optgroup b tt noscript header \
           aside section footer link small)

      def applicable?(tag)
        WHITELIST.include?(tag.name)
      end

      def prepare!
        return if @stats
        @stats = {}
        WHITELIST.each {|t| @stats[t] = []}
      end

      def process_tag(source, out, tag, path)
        prepare!
        unless tag.getAttributes.to_s.strip == "" || tag.getAttributes.to_s.strip.match(/^class=|^method=|^href=|HREF=|src=|type=/)
          @stats["#{tag.name}"] << {tag.getAttributes.to_s.strip => path} 
        end
        print_stats!
      end

      def print_stats!
        @stats.each do |hash,array|
          next if array.empty?
          puts "HTML_TAG = <#{hash}>"
          puts "\tATTRIBUTES:"
          array.each do |hash_element|
            hash_element.each do |attr,path|
              puts "\t --> #{attr} --> #{path}"
            end
          end
          puts "END\n" + "#" * 80
        end
      end

    end

  end
end
