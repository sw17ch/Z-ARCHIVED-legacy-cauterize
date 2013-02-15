module Cauterize
  module Builders
    module CS
      # sym - symbol - the lexical symbol associated with the generated entity
      # sig - signature - the C signature associated with the entity
      # proto - prototype - the C prototype associated with the entity
      # defn - definition - the C definition associated with the entity
      REQUIRED_METHODS = [
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

        # Things below here are tested in shared_examples_for_c_buildables #
        ####################################################################

        # Methods that are pretty much the same for everyone.
        # WFIXME what do I do with these???
        # def packer_sym; "Pack_#{@blueprint.name}" end
        # def packer_sig; "CAUTERIZE_STATUS_T #{packer_sym}(struct Cauterize * dst, #{render} * src)" end
        # def packer_proto(formatter)
        #   formatter << packer_sig + ";"
        # end

        # def unpacker_sym; "Unpack_#{@blueprint.name}" end
        # def unpacker_sig; "CAUTERIZE_STATUS_T #{unpacker_sym}(struct Cauterize * src, #{render} * dst)" end
        # def unpacker_proto(formatter)
        #   formatter << unpacker_sig + ";"
        # end

        # These are only different in a few type varieties.
        def render
          @blueprint.name.to_s.camel
        end
        def declare(formatter, sym)
          formatter << "public #{render} #{sym.to_s.camel} { get; set; }" 
        end
        def class_defn(formatter); nil end
        def enum_defn(formatter); nil end
      end
    end
  end
end
