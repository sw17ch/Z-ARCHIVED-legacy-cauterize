module Cauterize
  module Builders
    module Doc
      REQUIRED_METHODS = [
        :heading,
        :body,
      ]

      class BuildableException < Exception; end

      class Buildable
        def initialize(blueprint)
          @blueprint = blueprint
        end

        alias_method :orig_method_missing, :method_missing

        def method_missing(sym, *args)
          sym_required = REQUIRED_METHODS.include?(sym)

          if sym_required
            raise BuildableException.new("Classes deriving Buildable must implement the method #{sym}.")
          else
            orig_method_missing(sym, *args)
          end
        end
      end
    end
  end
end
