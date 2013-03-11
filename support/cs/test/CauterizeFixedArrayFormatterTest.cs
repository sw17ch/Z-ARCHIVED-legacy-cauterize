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
    class TestFixedArray : CauterizeFixedArrayTyped<long>
    {
        private long[] _data;

        public TestFixedArray()
        {
            Allocate(3);
        }
        public TestFixedArray(long[] data)
        {
            Allocate(data);
        }
        protected override int Size
        {
            get { return 3; }
        }
    }
    [TestFixture]
    public class CauterizeFixedArrayFormatterTest
    {
        [Test]
        public void TestDeserialize()
        {
            var stream = new MemoryStream();
            var factory = new Mock<CauterizeTypeFormatterFactory>();
            var sf = new Mock<ICauterizeTypeFormatter>();
            factory.Setup(f => f.GetFormatter(typeof (Int64))).Returns(sf.Object);
            var counter = 0;
            sf.Setup(f => f.Deserialize(stream, typeof(Int64))).Returns((Stream str, Type t) =>
                {
                    var ret = 0;
                    if (counter == 1)
                    {
                        ret = 101;
                    }
                    else if (counter == 2)
                    {
                        ret = 321;
                    }
                    counter++;
                    return ret;
                });
            var formatter = new CauterizeFixedArrayFormatter(factory.Object);
            var result = (TestFixedArray) formatter.Deserialize(stream, typeof (TestFixedArray));
            Assert.AreEqual(0, result[0]);
            Assert.AreEqual(101, result[1]);
            Assert.AreEqual(321, result[2]);
        }

        [Test]
        public void TestSerialize()
        {
            var stream = new MemoryStream();
            var testObj = new TestFixedArray();
            testObj[0] = 4;
            testObj[2] = 8;
            var sf = new Mock<ICauterizeTypeFormatter>();
            var factory = new Mock<CauterizeTypeFormatterFactory>();
            factory.Setup(f => f.GetFormatter(typeof (Int64))).Returns(sf.Object);
            var counter = 0;
            sf.Setup(f => f.Serialize(stream, It.IsAny<Int64>())).Callback((Stream str, object value) =>
                {
                    if (counter == 0)
                    {
                        Assert.AreEqual(4, value);
                    } 
                    else if (counter == 2)
                    {
                        Assert.AreEqual(8, value);
                    }
                    else
                    {
                        Assert.AreEqual(0, value);
                    }
                    counter++;
                });
            var formatter = new CauterizeFixedArrayFormatter(factory.Object);
            formatter.Serialize(stream, testObj);
            sf.VerifyAll();
        }
    }
}
