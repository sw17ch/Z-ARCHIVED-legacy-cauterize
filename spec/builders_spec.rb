module Cauterize
  describe Cauterize::Builders do
    describe "#register and #get" do
      let(:s) { Cauterize.scalar(:uint8_t) }
      before do
        class X; def initialize(i); end; end
        class Y; def initialize(i); end; end

        # save the old list so that we can restore it later.
        old_builders = nil
        Cauterize::Builders.module_exec do
          old_builders = @builders
          @builders = nil
        end
        @old_builders = old_builders
      end

      after do
        # restore the builders so as not to break any other tests
        old_builders = @old_builders
        Cauterize::Builders.module_exec do
          @builders = old_builders
        end
      end

      it "saves and retrieves classes" do
        Cauterize::Builders.register(:c, Cauterize::Scalar, X)
        Cauterize::Builders.get(:c, s).class.should be X
      end

      it "handles multiple languages" do
        Cauterize::Builders.register(:c, Cauterize::Scalar, X)
        Cauterize::Builders.get(:c, s).class.should be X

        Cauterize::Builders.register(:cs, Cauterize::Scalar, Y)
        Cauterize::Builders.get(:cs, s).class.should be Y
      end

      it "raises an error on duplicate registrations" do
        Cauterize::Builders.register(:c, Cauterize::Scalar, X)
        lambda {
          Cauterize::Builders.register(:c, Cauterize::Scalar, X)
        }.should raise_error /already registered/
      end

      it "is nil if no builder is registered" do
        Cauterize::Builders.get(:c, s).should be_nil
      end
    end
  end
end
