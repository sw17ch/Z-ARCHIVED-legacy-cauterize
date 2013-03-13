using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;
using Cauterize;

namespace Cauterize.Test
{
    class TestTopLevel : CauterizeComposite
    {
        [Order(0)]
        public TestSubComp SubComp { get; set; }

        [Order(1)]
        public TestSubFixed SubFixed { get; set; }

        [Order(2)]
        public TestSubGroup SubGroup { get; set; }

        [Order(3)]
        public Int32 SubInt { get; set; } 
    }

    class TestSubComp : CauterizeComposite
    {
        [Order(0)]
        public Byte Byte1 { get; set; }

        [Order(1)]
        public Byte Byte2 { get; set; }
    }

    class TestSubFixed : CauterizeFixedArrayTyped<Int64>
    {
        public TestSubFixed()
        {
            Allocate(4);
        }

        public TestSubFixed(Int64[] data)
        {
            Allocate(data);
        }

        protected override int Size
        {
            get { return 4; }
        }
    }
    
    [SerializedRepresentation(typeof(Byte))]
    public enum TestSubGroupType
    {
        TestSubGroupTypeVariable,
        TestSUbGroupTypeNothing,
        TestSubGroupTypeShort
    }

    class TestSubGroup : CauterizeGroup
    {
        [Order(0)]
        public TestSubGroupType Type { get; set; }

        [Order(1)]
        public TestSubVariable SubVar { get; set; }

        /* no data for nothing */
        [Order(3)]
        public Int16 SubShort { get; set; }
    }

    class TestSubVariable : CauterizeVariableArrayTyped<Byte>
    {
        public static Type SizeType = typeof (Byte);

        public TestSubVariable(int size)
        {
            Allocate(size);
        }

        public TestSubVariable(Byte[] data)
        {
            Allocate(data);
        }

        protected override int MaxSize
        {
            get { return Byte.MaxValue; }
        }

    }

    [TestFixture]
    public class CauterizeIntegrationTest
    {
        [Test]
        public void TestThereAndBackAgain()
        {
            var inputTopLevel = new TestTopLevel();
            inputTopLevel.SubComp = new TestSubComp();
            inputTopLevel.SubComp.Byte1 = 101;
            inputTopLevel.SubComp.Byte2 = 202;
            inputTopLevel.SubFixed = new TestSubFixed();
            inputTopLevel.SubFixed[2] = 1234123412341234;
            inputTopLevel.SubGroup = new TestSubGroup();
            inputTopLevel.SubGroup.Type = TestSubGroupType.TestSubGroupTypeVariable;
            inputTopLevel.SubGroup.SubVar = new TestSubVariable(3);
            inputTopLevel.SubGroup.SubVar[1] = 55;
            inputTopLevel.SubInt = 1000000;

            var formatter = new CauterizeFormatter();
            var stream = new MemoryStream(2048);
            formatter.Serialize(stream, inputTopLevel);

            stream.Position = 0;
            var outputTopLevel = formatter.Deserialize<TestTopLevel>(stream);
            Assert.AreEqual(inputTopLevel.SubComp.Byte1, outputTopLevel.SubComp.Byte1);
            Assert.AreEqual(inputTopLevel.SubComp.Byte2, outputTopLevel.SubComp.Byte2);
            Assert.AreEqual(inputTopLevel.SubFixed[0], outputTopLevel.SubFixed[0]);
            Assert.AreEqual(inputTopLevel.SubFixed[2], outputTopLevel.SubFixed[2]);
            Assert.AreEqual(inputTopLevel.SubGroup.Type, outputTopLevel.SubGroup.Type);
            Assert.AreEqual(inputTopLevel.SubGroup.SubVar[0], outputTopLevel.SubGroup.SubVar[0]);
            Assert.AreEqual(inputTopLevel.SubGroup.SubVar[1], outputTopLevel.SubGroup.SubVar[1]);
            Assert.AreEqual(inputTopLevel.SubInt, outputTopLevel.SubInt);
        }
    }
}
