require 'spacewalk_html_clean/command'

module SpacewalkHtmlClean
  module Commands

    class CleanSpacewalkHtmlXhtml < Command

      def applicable?(tag)
        ['html:xhtml', 'html:html'].include?(tag.name)
      end

      def process_tag(source, out, tag, path)
        if tag.name == 'html:xhtml'
          if tag.isSyntacticalEmptyElementTag()
            out.remove(tag)
          end
        elsif tag.name == 'html:html'
          attr = tag.getAttributes.get('xhtml')
          if attr
            out.remove(attr)
          end
        end
      end
    end

  end
end
