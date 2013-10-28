require 'csv'
require 'spacewalk_html_clean/command'

module SpacewalkHtmlClean
  module Commands

    class ImagesToIcons < Command

      def applicable?(tag)
        tag.name == 'table'
        ['rhn:toolbar', 'img'].include?(tag.name)
      end

      def process_tag(source, out, tag, path)
        case tag.name
          when 'rhn:toolbar' then process_toolbar(source, out, tag)
          when 'img' then process_image(source, out, tag)
        end
      end

      def load_image_map!
        return if @image_map
        # read csv into hash like [{'/img/rhn-icon-user.gif' => {:newicon => 'icon-user', :color => 'default'}, ...]
        imglist = File.join(File.dirname(__FILE__), '../../../data/spacewalk_image_map.csv')
        csv_options = {:headers => true, :header_converters => :symbol, :converters => :all}
        @image_map = {}

        CSV.foreach(imglist, csv_options) do |line|
          @image_map[line.fields[0]] = Hash[line.headers[1..-1].zip(line.fields[1..-1])]
        end
      end

      def process_image(source, out, tag)
        load_image_map!

        @image_map.each do |key, fields|
          src = tag.getAttributeValue('src')
          if key == src
            unless fields[:color] == 'default'
              out.replace(tag, %Q{<i class="#{fields[:newicon]} #{fields[:color]}"></i>}) unless fields[:newicon].nil?
          else
              out.replace(tag, %Q{<i class="#{fields[:newicon]}"></i>}) unless fields[:newicon].nil?
            end
          end
        end
      end

      def process_toolbar(source, out, tag)
        load_image_map!

        @image_map.each do |key, fields|
          src = tag.getAttributeValue('img')
          if key == src
            img = tag.getAttributes.get('img')
            out.replace(img, %Q{icon="#{fields[:newicon]}"}) unless fields[:newicon].nil?
          end
        end
      end

    end

  end
end
