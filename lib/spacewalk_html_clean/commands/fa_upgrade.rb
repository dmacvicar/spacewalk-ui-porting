require 'csv'
require 'spacewalk_html_clean/command'

module SpacewalkHtmlClean
  module Commands

    class FaUpgrade < Command

      def applicable?(tag)
        ['i', 'button', 'rhn:toolbar'].include?(tag.name)
      end

      def process_tag(source, out, tag, path)
        case tag.name
          #when 'rhn:toolbar' then process_toolbar(source, out, tag)
          when 'i' then process_i(source, out, tag)
        end
      end

      def load_renames!
        return if @renames
        # the rename table returns the same if there is
        # no entry
        @renames = Hash.new do |hash, key|
          key
        end

        # read csv into hash like [{'/img/rhn-icon-user.gif' => {:newicon => 'icon-user', :color => 'default'}, ...]
        path = File.join(File.dirname(__FILE__), '../../../data/fontawesome_renames.txt')
        File.read(path).lines.each do |line|
          k, v = line.strip.split(',')
          @renames[k] = v
        end
      end

      def process_i(source, out, tag)
        load_renames!
        class_attr = tag.getAttributes.get('class')
        return unless class_attr
        val = class_attr.getValue()
        return unless val
        classes = val.strip.split(' ')
        icon_classes = classes.grep(/^icon-(.+)/)
        other_classes = classes.reject {|x| icon_classes.include?(x)}

        # assume no human being would put the size class before
        fa_classes = icon_classes.map do |icon|
          'fa-' + @renames[icon.gsub(/^icon-/, '')]
        end
        fa_classes.unshift('fa') if not icon_classes.empty?
        fa_classes = other_classes + fa_classes
        out.replace(class_attr, %Q{class="#{fa_classes.join(' ')}"})
      end

    end

  end
end
