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
        TestGroupTypeBar,
        TestGroupTypeBaz
    }
    class TestGroup : CauterizeGroup
    {
        [Order(0)]
        public TestGroupType Type { get; set; }

        [Order(1)]
        public int Foo { get; set; }
        /* unused for 2/Bar */
        [Order(3)]
        public byte Baz { get; set; }
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
            group.Type = TestGroupType.TestGroupTypeBaz;
            group.Baz = 4;
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
            enumFormatter.Setup(f => f.Serialize(stream, TestGroupType.TestGroupTypeBaz));
            byteFormatter.Setup(f => f.Serialize(stream, (Byte)4));
            var formatter = new CauterizeGroupFormatter(factory.Object);
            formatter.Serialize(stream, group);
            enumFormatter.VerifyAll();
            byteFormatter.VerifyAll();
        }

        [Test]
        public void TestDeserialized_UnusedGroupData()
        {
            var stream = new MemoryStream();
            var factory = new Mock<CauterizeTypeFormatterFactory>();
            var enumFormatter = new Mock<ICauterizeTypeFormatter>();
            factory.Setup(f => f.GetFormatter(It.IsAny<Type>())).Returns((Type t) =>
                {
                    if (t == typeof (TestGroupType))
                    {
                        return enumFormatter.Object;
                    }
                    else
                    {
                        return null;
                    }
                });
            enumFormatter.Setup(f => f.Deserialize(stream, typeof (TestGroupType)))
                         .Returns(TestGroupType.TestGroupTypeBar);
            var formatter = new CauterizeGroupFormatter(factory.Object);
            var result = (TestGroup) formatter.Deserialize(stream, typeof (TestGroup));
            Assert.AreEqual(TestGroupType.TestGroupTypeBar, result.Type);
        }

        [Test]
        public void TestSerialized_UnusedGroupData()
        {
            var stream = new MemoryStream();
            var group = new TestGroup();
            group.Type = TestGroupType.TestGroupTypeBar;
            var enumFormatter = new Mock<ICauterizeTypeFormatter>();
            var factory = new Mock<CauterizeTypeFormatterFactory>();
            factory.Setup(f => f.GetFormatter(It.IsAny<Type>())).Returns((Type t) =>
                {
                    if (t == typeof (TestGroupType))
                    {
                        return enumFormatter.Object;
                    }
                    else
                    {
                        return null;
                    }
                });
            enumFormatter.Setup(f => f.Serialize(stream, TestGroupType.TestGroupTypeBar));
            var formatter = new CauterizeGroupFormatter(factory.Object);
            formatter.Serialize(stream, group);
            enumFormatter.VerifyAll();
        }
    }
}
