require 'spacewalk_html_clean/command'

module SpacewalkHtmlClean
  module Commands

    class CleanTables < Command

      def applicable?(tag)
        tag.name == 'table'
      end

      def process_tag(source, out, tag, path)
        tag.getAttributes.each do |attr|
          if ['cellpadding', 'cellspacing', 'width'].include?(attr.name)
            out.remove(attr)
          end
        end
      end

    end

  end
end
