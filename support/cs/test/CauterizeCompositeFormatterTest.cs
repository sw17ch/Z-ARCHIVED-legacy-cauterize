using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Cauterize;
using Moq;
using NUnit.Framework;

namespace Cauterize.Test
{
    public class TestComposite : CauterizeComposite
    {
        [Order(0)]
        public Int16 MyIntSmall { get; set; }

        [Order(1)]
        public Int32 MyIntNormal { get; set; }
    }

    [TestFixture]
    public class CauterizeCompositeFormatterTest
    {
        [Test]
        public void TestDeserialize()
        {
            var stream = new MemoryStream();
            var factory = new Mock<CauterizeTypeFormatterFactory>();
            var sf1 = new Mock<ICauterizeTypeFormatter>();
            var sf2 = new Mock<ICauterizeTypeFormatter>();
            factory.Setup(f => f.GetFormatter(It.IsAny<Type>())).Returns((Type t) => t == typeof(Int16) ? sf1.Object : sf2.Object);
            sf1.Setup(sf => sf.Deserialize(stream, typeof (Int16))).Returns((Int16) 5);
            sf2.Setup(sf => sf.Deserialize(stream, typeof (Int32))).Returns(15);
            var formatter = new CauterizeCompositeFormatter(factory.Object);
            var output = (TestComposite) formatter.Deserialize(stream, typeof (TestComposite));
            Assert.AreEqual(15, output.MyIntNormal);
            Assert.AreEqual(5, output.MyIntSmall);
        }

        [Test]
        public void TestSerialize()
        {
            var stream = new MemoryStream();
            var factory = new Mock<CauterizeTypeFormatterFactory>();
            var sf1 = new Mock<ICauterizeTypeFormatter>();
            var sf2 = new Mock<ICauterizeTypeFormatter>();
            factory.Setup(f => f.GetFormatter(It.IsAny<Type>())).Returns((Type t) => t == typeof(Int16) ? sf1.Object : sf2.Object);
            sf1.Setup(sf => sf.Serialize(stream, (Int16)2));
            sf2.Setup(sf => sf.Serialize(stream, 2222));
            var formatter = new CauterizeCompositeFormatter(factory.Object);
            var testObj = new TestComposite();
            testObj.MyIntNormal = 2222;
            testObj.MyIntSmall = 2;
            formatter.Serialize(stream, testObj);
            sf2.VerifyAll();
            sf1.VerifyAll();
        }
    }
}
