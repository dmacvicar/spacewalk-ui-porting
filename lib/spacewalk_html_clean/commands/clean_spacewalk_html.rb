require 'spacewalk_html_clean/command'

module SpacewalkHtmlClean
  module Commands

    class CleanSpacewalkHtml < Command

      def applicable?(tag)
        ['table', 'span', 'br'].include?(tag.name)
      end

      def process_tag(source, out, tag, path)
        tag.getAttributes.each do |attr|
          next unless ['class'].include?(attr.name)

          css_classes = tag.getAttributeValue('class').strip.split(' ')

          if tag.name == 'table' && css_classes.include?('details')
            css_classes = css_classes.reject {|x| x == 'details'}
            css_classes = [css_classes, 'table'].flatten.uniq
            out.replace(attr, %Q{class="#{css_classes.join(' ')}"})
          elsif tag.name == 'span' && css_classes.include?('small-text')
            css_classes = css_classes.reject {|x| x == 'small-text'}
            if css_classes.empty?
              el = tag.getElement()
              out.replace(el, %Q{<p><small>#{el.getContent()}</small></p>})
            end
          elsif tag.name == 'br'
            p = tag.getParentElement()
            while p
              puts p.getName()
            end
          end


        end
      end

    end

  end
end
