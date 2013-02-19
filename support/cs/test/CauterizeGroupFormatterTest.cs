using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Moq;
using NUnit.Framework;
using Cauterize;

namespace Cauterize.Test
{
    enum TestGroupType
    {
        TestGroupTypeFoo = 0,
        TestGroupTypeBar
    }
    class TestGroup : CauterizeGroup
    {
        [Order(0)]
        public TestGroupType Type { get; set; }

        [Order(1)]
        public int Foo { get; set; }
        [Order(2)]
        public byte Bar { get; set; }
    }

    [TestFixture]
    public class CauterizeGroupFormatterTest
    {
        [Test]
        public void TestDeserialize()
        {
            var stream = new MemoryStream();
            var factory = new Mock<CauterizeTypeFormatterFactory>();
            var enumFormatter = new Mock<ICauterizeTypeFormatter>();
            var intFormatter = new Mock<ICauterizeTypeFormatter>();
            factory.Setup(f => f.GetFormatter(It.IsAny<Type>())).Returns((Type t) =>
                {
                    if (t == typeof (TestGroupType))
                    {
                        return enumFormatter.Object;
                    }
                    else if (t == typeof (int))
                    {
                        return intFormatter.Object;
                    }
                    else
                    {
                        return null;
                    }
                });
            enumFormatter.Setup(f => f.Deserialize(stream, typeof (TestGroupType)))
                         .Returns(TestGroupType.TestGroupTypeFoo);
            intFormatter.Setup(f => f.Deserialize(stream, typeof (int)))
                        .Returns(1024);
            var formatter = new CauterizeGroupFormatter(factory.Object);
            var result = (TestGroup) formatter.Deserialize(stream, typeof (TestGroup));
            Assert.AreEqual(TestGroupType.TestGroupTypeFoo, result.Type);
            Assert.AreEqual(1024, result.Foo);
        }

        [Test]
        public void TestSerialize()
        {
            var stream = new MemoryStream();
            var group = new TestGroup();
            group.Type = TestGroupType.TestGroupTypeBar;
            group.Bar = 4;
            var enumFormatter = new Mock<ICauterizeTypeFormatter>();
            var byteFormatter = new Mock<ICauterizeTypeFormatter>();
            var factory = new Mock<CauterizeTypeFormatterFactory>();
            factory.Setup(f => f.GetFormatter(It.IsAny<Type>())).Returns((Type t) =>
                {
                    if (t == typeof (TestGroupType))
                    {
                        return enumFormatter.Object;
                    }
                    else if (t == typeof (Byte))
                    {
                        return byteFormatter.Object;
                    }
                    else
                    {
                        return null;
                    }
                });
            enumFormatter.Setup(f => f.Serialize(stream, TestGroupType.TestGroupTypeBar));
            byteFormatter.Setup(f => f.Serialize(stream, (Byte)4));
            var formatter = new CauterizeGroupFormatter(factory.Object);
            formatter.Serialize(stream, group);
            enumFormatter.VerifyAll();
            byteFormatter.VerifyAll();
        }
    }
}
