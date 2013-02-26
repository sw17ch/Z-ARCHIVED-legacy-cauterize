using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;

namespace Cauterize.Test
{
    public enum CauterizeEnumTest
    {
        Cet01 = 0,
        Cet02
    }
    [TestFixture]
    public class CauterizeEnumFormatterTest
    {
        [Test]
        public void TestDeserialize()
        {
            var bytes = new byte[1];
            bytes[0] = 1;
            var stream = new MemoryStream(bytes);
            var formatter = new CauterizeEnumFormatter();
            Assert.AreEqual(CauterizeEnumTest.Cet02, formatter.Deserialize(stream, typeof (CauterizeEnumTest)));
        }

        [Test]
        public void TestSerialize()
        {
            var bytes = new byte[4];
            var stream = new MemoryStream(bytes);
            var formatter = new CauterizeEnumFormatter();
            formatter.Serialize(stream, CauterizeEnumTest.Cet02);
            Assert.AreEqual(1, bytes[0]);
            Assert.AreEqual(0, bytes[1]);
            Assert.AreEqual(0, bytes[2]);
            Assert.AreEqual(0, bytes[3]);
        }
    }
}
