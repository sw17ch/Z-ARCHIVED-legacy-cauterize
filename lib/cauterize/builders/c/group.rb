module Cauterize
  module Builders
    module C
      class Maxer
        # Produce a preprocessor string that results in the maximum size of the passed
        # in symbols. Uses the CA_MAX macro from the Cauterize support C files.
        def self.max_str(*syms)
          a = syms.to_a
          pre = syms.to_a.inject("") {|s, v| s + "CA_MAX(" + v.to_s + ", "}
          return pre + "0" + (")" * a.length)
        end
      end

      class Group < Buildable
        def initialize(blueprint)
          super(blueprint)
          @tag_enum = blueprint.tag_enum
        end

        def render
          "struct #{@blueprint.name.to_s}"
        end

        def declare(formatter, sym)
          formatter << "#{render} #{sym};"
        end

        def preprocessor_defines(formatter)
          field_lens = @blueprint.fields.values.map do |field|
            if field.type.nil?
              nil
            else
              Builders.get(:c, field.type).max_enc_len_cpp_sym
            end
          end.compact

          formatter << ["#define #{max_enc_len_cpp_sym}",
                        "(#{enum_builder.max_enc_len_cpp_sym} +",
                        Maxer.max_str(*field_lens)].join(" ")
        end

        def packer_defn(formatter)
          formatter << "CAUTERIZE_STATUS_T err;"

          # pack the tag
          formatter << "if (CA_OK != (err = #{enum_builder.packer_sym}(dst, &src->tag))) { return err; }"

          # pack the fields
          formatter << "switch (src->tag)"
          formatter.braces do
            having_data.each do |field|
              bldr = Builders.get(:c, field.type)
              formatter.backdent "case #{@blueprint.enum_sym(field.name)}:"
              formatter << "if (CA_OK != (err = #{bldr.packer_sym}(dst, &src->data.#{field.name}))) { return err; }"
              formatter << "break;"
            end

            format_no_data_stubs(formatter)

            formatter.backdent "default:"
            formatter << "return CA_ERR_INVALID_TYPE_TAG;"
            formatter << "break;"
          end
          formatter << "return CA_OK;"
        end

        def unpacker_defn(formatter)
          enum_builder = Builders.get(:c, @tag_enum)

          formatter << "CAUTERIZE_STATUS_T err;"

          # unpack the tag
          formatter << "if (CA_OK != (err = #{enum_builder.unpacker_sym}(src, &dst->tag))) { return err; }"

          # pack the fields
          formatter << "switch (dst->tag)"
          formatter.braces do
            having_data.each do |field|
              bldr = Builders.get(:c, field.type)
              formatter.backdent "case #{@blueprint.enum_sym(field.name)}:"
              formatter << "if (CA_OK != (err = #{bldr.unpacker_sym}(src, &dst->data.#{field.name}))) { return err; }"
              formatter << "break;"
            end

            format_no_data_stubs(formatter)

            formatter.backdent "default:"
            formatter << "return CA_ERR_INVALID_TYPE_TAG;"
            formatter << "break;"
          end
          formatter << "return CA_OK;"
        end

        def struct_proto(formatter)
          formatter << (render + ";")
        end

        def struct_defn(formatter)
          formatter << render
          formatter.braces do
            Builders.get(:c, @tag_enum).declare(formatter, "tag")
            formatter << "union"
            formatter.braces do
              @blueprint.fields.values.each do |field|
                if field.type
                  Builders.get(:c, field.type).declare(formatter, field.name)
                else
                  formatter << "/* No data associated with '#{field.name}'. */"
                end
              end
            end
            formatter.append(" data;")
          end
          formatter.append(";")
        end

        private

        def having_data
          @blueprint.fields.values.reject {|v| v.type.nil?}
        end

        def no_data
          @blueprint.fields.values.reject {|v| not v.type.nil?}
        end

        def format_no_data_stubs(formatter)
          if 0 < no_data.length
            formatter.backdent "/* No data associated with the remaining tags. */"
            no_data.each do |field|
              formatter.backdent "case #{@blueprint.enum_sym(field.name)}:"
            end
            formatter << "break;"
          end
        end

        def enum_builder; Builders.get(:c, @tag_enum) end
      end
    end
  end
end

Cauterize::Builders.register(:c, Cauterize::Group, Cauterize::Builders::C::Group)
