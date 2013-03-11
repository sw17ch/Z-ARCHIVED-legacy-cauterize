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
    class TestVariableArray : CauterizeVariableArrayTyped<int>
    {
        public static Type SizeType = typeof (Byte);

        public TestVariableArray(int size)
        {
            Allocate(size);
        }

        public TestVariableArray(int[] data)
        {
            Allocate(data);
        }

        protected override int MaxSize
        {
            get { return Byte.MaxValue; }
        }
    }

    [TestFixture]
    public class CauterizeVariableArrayFormatterTest
    {
        [Test]
        public void TestDeserialize()
        {
            var stream = new MemoryStream();
            var factory = new Mock<CauterizeTypeFormatterFactory>();
            var sf1 = new Mock<ICauterizeTypeFormatter>();
            var sf2 = new Mock<ICauterizeTypeFormatter>();
            factory.Setup(f => f.GetFormatter(It.IsAny<Type>())).Returns((Type t) =>
                {
                    if (t == typeof (Byte))
                    {
                        return sf1.Object;
                    }
                    else if (t == typeof (Int32))
                    {
                        return sf2.Object;
                    }
                    else
                    {
                        return null;
                    }
                });
            sf1.Setup(sf => sf.Deserialize(stream, typeof (Byte))).Returns((Byte) 25);
            var counter = 0;
            sf2.Setup(sf => sf.Deserialize(stream, typeof(Int32))).Returns((Stream str, Type t) =>
                {
                    var ret = 0;
                    if (counter == 4)
                    {
                        ret = 101;
                    }
                    else if (counter == 12)
                    {
                        ret = 321;
                    }
                    counter++;
                    return ret;
                });
            var formatter = new CauterizeVariableArrayFormatter(factory.Object);
            var result = (TestVariableArray) formatter.Deserialize(stream, typeof (TestVariableArray));
            Assert.AreEqual(0, result[0]);
            Assert.AreEqual(101, result[4]);
            Assert.AreEqual(321, result[12]);
            Assert.AreEqual(0, result[13]);
        }

        [Test]
        public void TestSerialize()
        {
            var stream = new MemoryStream();
            var testObj = new TestVariableArray(4);
            testObj[1] = 15;
            testObj[3] = 16;
            var sf1 = new Mock<ICauterizeTypeFormatter>();
            var sf2 = new Mock<ICauterizeTypeFormatter>();
            var factory = new Mock<CauterizeTypeFormatterFactory>();
            factory.Setup(f => f.GetFormatter(It.IsAny<Type>())).Returns((Type t) =>
                {
                    if (t == typeof(Byte))
                    {
                        return sf1.Object;
                    }
                    else if (t == typeof (Int32))
                    {
                        return sf2.Object;
                    }
                    else
                    {
                        return null;
                    }
                });
            sf1.Setup(sf => sf.Serialize(stream, (Byte)4));
            var counter = 0;
            sf2.Setup(sf => sf.Serialize(stream, It.IsAny<Int32>())).Callback((Stream str, object value) =>
                {
                    if (counter == 1)
                    {
                        Assert.AreEqual(15, value);
                    } 
                    else if (counter == 3)
                    {
                        Assert.AreEqual(16, value);
                    }
                    else
                    {
                        Assert.AreEqual(0, value);
                    }
                    counter++;
                });
            var formatter = new CauterizeVariableArrayFormatter(factory.Object);
            formatter.Serialize(stream, testObj);
            sf1.VerifyAll();
            sf2.VerifyAll();
        }
    }
}
