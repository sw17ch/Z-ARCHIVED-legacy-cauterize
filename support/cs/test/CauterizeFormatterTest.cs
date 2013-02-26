using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;
using Cauterize;
using Moq;

namespace Cauterize.Test
{
    [TestFixture]
    public class CauterizeFormatterTest
    {
        [Test]
        public void TestDeserialize()
        {
            var subFormatter = new Mock<ICauterizeTypeFormatter>();
            var serializationStream = new MemoryStream();
            subFormatter.Setup(sf => sf.Deserialize(serializationStream, typeof (string))).Returns("hello world");
            var factory = new Mock<CauterizeTypeFormatterFactory>();
            factory.Setup(f => f.GetFormatter(typeof (string))).Returns(subFormatter.Object);
            var formatter = new CauterizeFormatter(typeof (string), factory.Object);
            Assert.AreEqual("hello world", formatter.Deserialize(serializationStream));
        }

        [Test]
        public void TestSerialize()
        {
            var subFormatter = new Mock<ICauterizeTypeFormatter>();
            var serializationStream = new MemoryStream();
            subFormatter.Setup(sf => sf.Serialize(serializationStream, "hello world"));
            var factory = new Mock<CauterizeTypeFormatterFactory>();
            factory.Setup(f => f.GetFormatter(typeof (string))).Returns(subFormatter.Object);
            var formatter = new CauterizeFormatter(typeof (string), factory.Object);
            formatter.Serialize(serializationStream, "hello world");
            subFormatter.VerifyAll();
        }
    }
}
