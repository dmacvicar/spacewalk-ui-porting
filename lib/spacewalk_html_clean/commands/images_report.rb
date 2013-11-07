require 'spacewalk_html_clean/command'
require 'base64'
require 'erb'
require 'ostruct'
require 'set'
require 'fastimage'

class String
  def unquote
    s = self.dup

    case self[0,1]
    when "'", '"', '`'
      s[0] = ''
    end

    case self[-1,1]
    when "'", '"', '`'
      s[-1] = ''
    end

    return s
  end
end

def find_top_git_directory
  dir = Dir.pwd
  while dir != '/'
    return File.expand_path(dir) if File.directory?(File.join(dir, '.git'))
    dir = File.dirname(dir)
  end
  nil
end

def find_images_directory
  File.join(find_top_git_directory, 'branding')
end

module SpacewalkHtmlClean
  module Commands

    class ImagesReport < Command

      def self.images_directory
        File.join(top_git_directory, 'branding')
      end

      option ["-i", "--images-directory"], "IMAGES_DIRECTORY",
             "Where images are located",
             :default => images_directory do |s|
        raise "Can't locate the images directory" unless File.directory?(images)
        images
      end

      option ['-o', '--output-dir'], 'OUTPUT_FILE', 'HTML report',
        :default => File.join(ENV['HOME'], 'Export')

      def applicable?(tag)
        ['rhn:toolbar', 'img'].include?(tag.name)
      end

      def init!
        return if @image_map
        @image_map = {}
        @image_ocurr = Hash.new do |hash, k|
          s = Set.new
          hash[k] = s
          s
        end

        path = File.join(File.dirname(__FILE__), '../../../data/spacewalk_image_map.csv')
        first_seen = false
        File.read(path).lines.each do |line|
          unless first_seen
            first_seen = true
            next
          end
          image, icon = line.split(',')
          @image_map[image] = icon
        end

        @image_rank = Hash.new(0)

        @image_map.each do |key, val|
          @image_rank[key] = 0
        end
      end

      def process_image(image, path)
        return unless  /(gif|png)$/.match(image)
        return unless image
        @image_rank[image] = @image_rank[image] + 1
        @image_ocurr[image].add(path)
      end

      def process_tag(source, out, tag, path)
        init!

        #if path =~ /manage_header/
        #  puts "#{path} #{tag.name}"
        #  puts tag.getAttributes
        #end

        if tag.name == 'img'
          src = tag.getAttributeValue('src')
          process_image(src, path) if src
        elsif tag.name == 'rhn:toolbar'
          img = tag.getAttributeValue('img')
          process_image(img, path) if img
          img = tag.getAttributeValue('miscImg')
          process_image("/img/" + img, path) if img
        elsif tag.name == 'rhn-toolbar'
          img = tag.getAttributeValue('img')
          process_image(img, path) if img
        end
      end

      def on_file_start(content, path)
        init!
        if not ['.java', '.pm'].include?(File.extname(path))
          return
        end
        # Look for images in strings in the java files
        [/"([^\\"]|\\\\|\\")*(gif|png)"/, /'([^']|')*(gif|png)'/].each do |reg|
          match = reg.match(content)
          next unless match
          img = match[0].unquote
          #puts "#{img} -> #{path}"
          process_image(img, path) if match
        end
      end

      def on_done
        template_path = File.join(File.dirname(__FILE__),
          '../../../data/image_report.html.tpl')

        erb = ERB.new(File.read(template_path))
        File.open(File.join(output_dir, 'index.html'), 'w') do |f|
          opts = OpenStruct.new({
            :image_map => @image_map,
            :image_rank => @image_rank,
            :images_directory => images_directory,
            :image_ocurr => @image_ocurr,
            :assets_directory => find_top_git_directory
          })
          f.write(erb.result(opts.instance_eval {binding}))
        end
        assets_directory = find_top_git_directory
        `rsync -a --delete #{File.join(assets_directory, 'branding/img')} #{output_dir}`
        `rsync -a --delete #{File.join(assets_directory, 'branding/fonts')} #{output_dir}`
        `rsync -a --delete #{File.join(assets_directory, 'branding/css')} #{output_dir}`
        `rsync -a --delete #{File.join(assets_directory, 'web/html/javascript')} #{output_dir}`
      end

    end

  end
end
