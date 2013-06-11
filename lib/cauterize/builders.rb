module Cauterize
  module Builders
    class UnregisteredException < Exception; end
    class DuplicateException < Exception; end

    module_function

    def builders
      @builders
    end

    def register(language, description_class, builder_class)
      @builders ||= {}
      @builders[language] ||= {}

      if @builders[language][description_class]
        raise DuplicateException.new("A builder for #{description_class} is already registered for language #{language}.")
      else
        @builders[language][description_class] = builder_class
      end
    end

    def get(language, description_instance)
      unless @builders
        raise UnregisteredException.new("No builders are registered.")
      end

      unless @builders[language]
        s = "Language #{language} not registered."
        raise UnregisteredException.new(s)
      end

      unless @builders[language][description_instance.class]
        s = "Class #{description_instance.class} not registered for #{language}."
        raise UnregisteredException.new(s)
      end

      @builders[language][description_instance.class].new(description_instance)
    end
  end
end
