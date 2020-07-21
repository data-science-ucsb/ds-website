module Stackbit

  module Filters

    def if(input, if_true, if_false)
        return input ? if_true : if_false
    end

    def starts_with(input, str)
      return input.start_with?(str)
    end

    def ends_with(input, str)
      return input.end_with?(str)
    end

    def path_join(*path_parts)
      return File.join(*path_parts)
    end

    def link(input)
      relative_path = input.strip

      return relative_path if relative_path.start_with?("#")

      site = @context.registers[:site]

      site.each_site_file do |item|
        return item.url if item.relative_path == relative_path
        # This takes care of the case for static files that have a leading /
        return item.url if item.relative_path == "/#{relative_path}"
      end

      raise ArgumentError, <<~MSG
        Could not find document '#{relative_path}' in 'link' filter.

        Make sure the document exists and the path is correct.
      MSG
    end

    def is_empty(input)
      if input.respond_to?(:empty?)
        return input.empty?
      else
        return !input
      end
    end

    def is_not_empty(input)
      if input.respond_to?(:empty?)
        return !input.empty?
      else
        return !!input
      end
    end

    def replace_regexp(input, pattern, replacement)
      regexp = /#{pattern}/
      return input.gsub(regexp, replacement)
    end

    def sprintf(format, argument)
      return Object.send(:sprintf, format, argument)
    end

    def get_page(page_path)

      site = @context.registers[:site]
      relative_page_path = page_path.sub(/^\//, '')
      relative_page_parts = relative_page_path.split('/')

      if site.collections.key?(relative_page_parts[0])
        if relative_page_parts.length > 2
          raise ArgumentError, "get_page can not have sub-folders inside collection folder, received #{page_path}"
        end
        return site.collections[relative_page_parts[0]].docs.find do |doc|
          if doc.data.key?("slug") && doc.data.key?("ext")
            doc.data["slug"] + doc.data["ext"] == relative_page_parts[1]
          else
            doc.basename == relative_page_parts[1]
          end
        end
      else
        return site.pages.find { |page| page.relative_path == relative_page_path }
      end

    end

    def get_pages(folder_path)

      site = @context.registers[:site]

      relative_folder_path = folder_path.sub(/^\//, '').sub(/\/$/, '')
      if relative_folder_path == ""
        relative_folder_path = "."
      end

      relative_folder_parts = relative_folder_path.split('/')

      if site.collections.key?(relative_folder_parts[0])
        if relative_folder_parts.length != 1
          raise ArgumentError, "get_pages can not have sub-folders inside collection folder, received #{folder_path}"
        end
        return site.collections[relative_folder_parts[0]].docs
      else
        return site.pages.select { |page| File.dirname(page.path).sub(/^\//, '').sub(/\/$/, '') == relative_folder_path && File.basename(page.path) != 'index.md' }
      end

    end

    def get_data(data_path)

      site = @context.registers[:site]
      data = site.data

      data_path = data_path.sub(File.extname(data_path), '')
      path_parts = data_path.split('/').reject { |p| p.empty? }
      if path_parts.first === '_data'
        path_parts.shift
      end

      for part in path_parts
         if data.has_key? part
           data = data[part]
         else
           return nil
         end
      end

      return data

    end

    class Cycler < Liquid::Drop

      def initialize(values)
        @values = values
        @counter = 0
      end

      def next
        res = @values[@counter % @values.length]
        @counter += 1
        return res
      end

    end

    def cycler(input, delimiter = " ")
        return Cycler.new(input.split(delimiter, -1))
    end

  end

end

Liquid::Template.register_filter(Stackbit::Filters)
