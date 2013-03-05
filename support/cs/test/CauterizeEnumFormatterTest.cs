using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;

namespace Cauterize.Test
{
    public enum CauterizeEnumTestSmall
    {
        Cets01 = 0,
        Cets02 = 2
    }

    public enum CauterizeEnumTestMedium
    {
        Cetm01 = 0,
        Cetm02 = 512
    }

    public enum CauterizeEnumTestLarge
    {
        Cetl01 = 0,
        Cetl02 = 131072
    }

    [TestFixture]
    public class CauterizeEnumFormatterTest
    {
        [Test]
        public void TestDeserialize_Small()
        {
            var bytes = new byte[1];
            bytes[0] = 2;
            var stream = new MemoryStream(bytes);
            var formatter = new CauterizeEnumFormatter();
            Assert.AreEqual(CauterizeEnumTestSmall.Cets02, formatter.Deserialize(stream, typeof (CauterizeEnumTestSmall)));
        }

        [Test]
        public void TestDeserialize_Medium()
        {
            var bytes = new byte[2];
            bytes[0] = 0;
            bytes[1] = 2;
            var stream = new MemoryStream(bytes);
            var formatter = new CauterizeEnumFormatter();
            Assert.AreEqual(CauterizeEnumTestMedium.Cetm02, formatter.Deserialize(stream, typeof (CauterizeEnumTestMedium)));
        }

        [Test]
        public void TestDeserialize_Large()
        {
            var bytes = new byte[4];
            bytes[0] = 0;
            bytes[1] = 0;
            bytes[2] = 2;
            bytes[3] = 0;
            var stream = new MemoryStream(bytes);
            var formatter = new CauterizeEnumFormatter();
            Assert.AreEqual(CauterizeEnumTestLarge.Cetl02, formatter.Deserialize(stream, typeof (CauterizeEnumTestLarge)));
        }

        [Test]
        public void TestSerialize_Small()
        {
            var bytes = new byte[1];
            var stream = new MemoryStream(bytes);
            var formatter = new CauterizeEnumFormatter();
            formatter.Serialize(stream, CauterizeEnumTestSmall.Cets02);
            Assert.AreEqual(2, bytes[0]);
        }

        [Test]
        public void TestSerialize_Medium()
        {
            var bytes = new byte[2];
            var stream = new MemoryStream(bytes);
            var formatter = new CauterizeEnumFormatter();
            formatter.Serialize(stream, CauterizeEnumTestMedium.Cetm02);
            Assert.AreEqual(0, bytes[0]);
            Assert.AreEqual(2, bytes[1]);
        }

        [Test]
        public void TestSerialize_Large()
        {
            var bytes = new byte[4];
            var stream = new MemoryStream(bytes);
            var formatter = new CauterizeEnumFormatter();
            formatter.Serialize(stream, CauterizeEnumTestLarge.Cetl02);
            Assert.AreEqual(0, bytes[0]);
            Assert.AreEqual(0, bytes[1]);
            Assert.AreEqual(2, bytes[2]);
            Assert.AreEqual(0, bytes[3]);
        }
    }
}
