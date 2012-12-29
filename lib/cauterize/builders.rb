module Cauterize
  module Builders
    class UnregisteredException < Exception; end
    class DuplicateException < Exception; end

    module_function

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
      if @builders and @builders[language]
        @builders[language][description_instance.class].new(description_instance)
      else
        raise UnregisteredException.new("The builder for #{description_instance.class} in #{language} is unregistered.")
      end
    end
  end
end
