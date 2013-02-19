using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;

namespace Cauterize.Test
{
    [TestFixture]
    public class CauterizePrimitiveFormatterTest
    {
        [Test]
        public void TestDeserialize()
        {
            var formatter = new CauterizePrimitiveFormatter();
            var bytes = new byte[8];
            bytes[0] = 2;
            bytes[1] = 128;
            bytes[2] = 1;
            bytes[3] = 0;
            bytes[4] = 1;
            var stream = new MemoryStream(bytes);
            object value = formatter.Deserialize(stream, typeof(Byte));
            Assert.AreEqual(2,value);
            stream = new MemoryStream(bytes);
            value = formatter.Deserialize(stream, typeof(Int16));
            Assert.AreEqual(Int16.MinValue + 2, value);
            stream = new MemoryStream(bytes);
            value = formatter.Deserialize(stream, typeof(UInt16));
            Assert.AreEqual(32770, value);
            stream = new MemoryStream(bytes);
            value = formatter.Deserialize(stream, typeof(Int32));
            Assert.AreEqual(98306, value);
            stream = new MemoryStream(bytes);
            value = formatter.Deserialize(stream, typeof(Int64));
            Assert.AreEqual(4295065602, value);
        }

        [Test]
        public void TestDeserializeTwoBytesInARow()
        {
            var formatter = new CauterizePrimitiveFormatter();
            var bytes = new byte[2];
            bytes[0] = 2;
            bytes[1] = 128;
            var stream = new MemoryStream(bytes);
            object value = formatter.Deserialize(stream, typeof(Byte));
            Assert.AreEqual(2,value);
            value = formatter.Deserialize(stream, typeof(Byte));
            Assert.AreEqual(128,value);
        }

        [Test]
        public void TestSerialize()
        {
            var formatter = new CauterizePrimitiveFormatter();
            var bytes = new byte[8];
            var stream = new MemoryStream(bytes);
            formatter.Serialize(stream, (Byte)2);
            Assert.AreEqual(2, bytes[0]);
            Assert.AreEqual(0, bytes[1]);

            bytes = new byte[8];
            stream = new MemoryStream(bytes);
            formatter.Serialize(stream, (Int16)(Int16.MinValue + 2));
            Assert.AreEqual(2, bytes[0]);
            Assert.AreEqual(128, bytes[1]);
            Assert.AreEqual(0, bytes[2]);

            bytes = new byte[8];
            stream = new MemoryStream(bytes);
            formatter.Serialize(stream, (UInt16)(32770));
            Assert.AreEqual(2, bytes[0]);
            Assert.AreEqual(128, bytes[1]);
            Assert.AreEqual(0, bytes[2]);

            bytes = new byte[8];
            stream = new MemoryStream(bytes);
            formatter.Serialize(stream, 98306);
            Assert.AreEqual(2, bytes[0]);
            Assert.AreEqual(128, bytes[1]);
            Assert.AreEqual(1, bytes[2]);
            Assert.AreEqual(0, bytes[3]);
            Assert.AreEqual(0, bytes[4]);

            bytes = new byte[8];
            stream = new MemoryStream(bytes);
            formatter.Serialize(stream, 4295065602);
            Assert.AreEqual(2, bytes[0]);
            Assert.AreEqual(128, bytes[1]);
            Assert.AreEqual(1, bytes[2]);
            Assert.AreEqual(0, bytes[3]);
            Assert.AreEqual(1, bytes[4]);
            Assert.AreEqual(0, bytes[5]);
        }
    }
}
