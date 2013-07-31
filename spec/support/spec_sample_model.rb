module Cauterize
  module CauterizeHelpers
    def gen_a_model
      Cauterize.scalar(:foo) do |t|
        t.type_name :uint8
      end

      Cauterize.enumeration(:color) do |e|
        e.value :red
        e.value :blue
        e.value :green
      end

      Cauterize.fixed_array(:color_list) do |a|
        a.array_type :color
        a.array_size 41
      end

      Cauterize.variable_array(:int8_list) do |a|
        a.size_type  :uint8
        a.array_type :int8
        a.array_size 200
      end

      Cauterize.composite(:two_things) do |t|
        t.field :thing_1, :uint8
        t.field :thing_2, :uint16
      end

      Cauterize.group(:one_of_everything) do |t|
        t.field :a_foo, :foo
        t.field :a_color, :color
        t.field :a_color_list, :color_list
        t.field :an_int8_list, :int8_list
        t.field :a_two_things, :two_things
      end
    end
  end
end
