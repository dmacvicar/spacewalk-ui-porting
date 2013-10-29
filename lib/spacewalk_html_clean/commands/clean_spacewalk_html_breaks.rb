require 'spacewalk_html_clean/command'

module SpacewalkHtmlClean
  module Commands

    class CleanSpacewalkHtmlBreaks < Command

      def applicable?(tag)
        ['br'].include?(tag.name)
      end

      def process_tag(source, out, tag, path)
        if tag.name == 'br'
          el = tag.getElement()
          p = el.getParentElement()
          nested = 0
          stack = []
          stack << el.getName()
          while p
            #puts p.getName()
            nested = nested + 1
            stack << p.getName()
            if p.getName() == 'p'
              # remove only if they dont have a parent p
              #puts "K: " + path + ": " + stack.join(' -> ')
              return
            end
            p = p.getParentElement()
          end
          #puts "R: " + path + ": " + stack.join(' -> ')
          out.remove(tag)
        end
      end

    end

  end
end
