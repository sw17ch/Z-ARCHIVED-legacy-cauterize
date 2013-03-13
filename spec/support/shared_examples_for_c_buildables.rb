# shared examples for c buildables

module Cauterize
  include Cauterize::Builders::C

  shared_examples "a buildable" do
    let(:desc_instance) { type_constructor.call(:some_type_name) }
    let(:formatter) { default_formatter }
    let(:builder) { Cauterize::Builders.get(:c, desc_instance) }
    subject { described_class.new(desc_instance) }

    it "should be registered" do
      builder.class.should be described_class
    end

    it "errors on duplicate type names" do
      instances = BaseType.class_variable_get(:@@instances)
      instances[:a_common_name] = nil
      BaseType.class_variable_set(:@@instances, instances)
      lambda {
        type_constructor.call(:a_common_name)
      }.should raise_error /already exists/
    end

    describe :packer_sym do
      it "contains the word Pack" do
        subject.packer_sym.should match /Pack_/
      end
    end

    describe :packer_sig do
      it "looks like this" do
        r = /CALLCONV CAUTERIZE_STATUS_T DLLDECL (?<sym>[^\(]+)\(struct Cauterize \* dst, (?<rend>(?:(?:struct|enum) )?[^ ]+) \* src\)/
        subject.packer_sig.should match r
        m = subject.packer_sig.match(r)
        m[:sym].should == subject.packer_sym
        m[:rend].should == subject.render
      end
    end

    describe :packer_proto do
      it "should format the sig + ;" do
        subject.packer_proto(formatter)
        formatter.to_s.should == subject.packer_sig + ";"
      end
    end

    describe :packer_defn do
      before { subject.packer_defn(formatter) }

      it "contains the signature" do
        formatter.to_s.should match Regexp.escape(subject.packer_sig)
      end

      it "contains a return statement" do
        formatter.to_s.should match /return.*;/
      end
    end

    describe :unpacker_sym do
      it "contains the word Unpack" do
        subject.unpacker_sym.should match /Unpack_/
      end
    end

    describe :unpacker_sig do
      it "looks like this" do
        r = /CALLCONV CAUTERIZE_STATUS_T DLLDECL (?<sym>[^\(]+)\(struct Cauterize \* src, (?<rend>(?:(?:struct|enum) )?[^ ]+) \* dst\)/
        subject.unpacker_sig.should match r
        m = subject.unpacker_sig.match(r)
        m[:sym].should == subject.unpacker_sym
        m[:rend].should == subject.render
      end
    end

    describe :unpacker_proto do
      it "should format the sig + ;" do
        subject.unpacker_proto(formatter)
        formatter.to_s.should == subject.unpacker_sig + ";"
      end
    end

    describe :unpacker_defn do
      before { subject.unpacker_defn(formatter) }

      it "contains the signature" do
        formatter.to_s.should match Regexp.escape(subject.unpacker_sig)
      end

      it "contains a return statement" do
        formatter.to_s.should match /return.*;/
      end
    end
  end
end
