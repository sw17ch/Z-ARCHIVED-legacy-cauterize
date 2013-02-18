module Cauterize::Builders::CS
  class Scalar < Buildable
    def render
      bldr = Cauterize::Builders.get(:cs, @blueprint.type_name)
      bldr.render
    end
  end
end

Cauterize::Builders.register(:cs, Cauterize::Scalar, Cauterize::Builders::CS::Scalar)
