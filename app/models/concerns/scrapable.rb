module Scrapable
  extend ActiveSupport::Concern

  class_methods do

    def source(url)
      NokoGiri::HTML(open(url))
    end

    def container(descriptor)
      source.css descriptor
    end
  end
end