require 'spacewalk_html_clean/command'

module SpacewalkHtmlClean
  module Commands

    class CleanSpacewalkHtmlVoidElements < Command

      def applicable?(tag)
        !['area', 'base', 'br', 'col',
         'embed', 'hr', 'img', 'input',
         'keygen', 'link', 'meta', 'param',
         'source', 'track', 'wbr'].include?(tag.name) &&
         (!tag.name.include?(':'))
      end

      def process_tag(source, out, tag, path)
        if tag.isSyntacticalEmptyElementTag()
          puts "#{path} -> #{tag.name}"
          # the parser gets confused with attributes with
          # bean keys
          tag.getAttributes.each do |attr|
            if attr.getValue() && attr.getValue().include?('<bean')
              return
            end
          end
          if tag.name == 'p'
            out.remove(tag)
          elsif tag.name == 'a'
            if tag.getAttributes.size == 1 && tag.getAttributes.get('name')
              out.replace(tag, %Q{<a name="#{tag.getAttributeValue('name')}"></a>})
            end
          end
        end
      end

    end

  end
end
