require 'spacewalk_html_clean/command'

module SpacewalkHtmlClean
  module Commands

    class BootstrapTables < Command

      def applicable?(tag)
        tag.name == 'table'
      end

      def process_tag(source, out, tag, path)
        tag.getAttributes.each do |attr|
          next unless ['class'].include?(attr.name)
          css_classes = tag.getAttributeValue('class').strip.split(' ')
          if css_classes.include?('details')
            css_classes = css_classes.reject {|x| x == 'details'}
            css_classes = [css_classes, 'table'].flatten.uniq
            out.replace(attr, %Q{class="#{css_classes.join(' ')}"})
          end
        end
      end

    end

  end
end
