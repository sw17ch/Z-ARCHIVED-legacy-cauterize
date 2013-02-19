using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;
using Cauterize;

namespace Cauterize.Test
{
    class MyComposite : CauterizeComposite
    {
        public int MyInt1 { get; set; }
        public int MyInt2 { get; set; }
    }

    enum GroupType
    {
        GroupTypeInt32,
        GroupTypeInt16
    }
    class MyGroup : CauterizeGroup
    {
        public GroupType Type;

        public Int32 NormalInt { get; set; }
        public Int16 SmallInt { get; set; }
    }

    class MyFixedArray : CauterizeFixedArray
    {
        private int[] _data;
        MyFixedArray()
        {
            _data = new int[4];
        }
        int this[int i]
        {
            get { return _data[i]; }
            set { _data[i] = value; }
        }
    }

    class MyVariableArray : CauterizeVariableArray
    {
        private int[] _data;
        MyVariableArray(int size)
        {
            _data = new int[size];
        }
        int this[int i]
        {
            get { return _data[i]; }
            set { _data[i] = value; }
        }
    }

    [TestFixture]
    public class CauterizeTypeFormatterFactoryTest
    {
        [Test]
        public void TestGetFormatter()
        {
            var factory = new CauterizeTypeFormatterFactory();
            Assert.AreEqual(typeof(CauterizeCompositeFormatter), factory.GetFormatter(typeof(MyComposite)).GetType());
            Assert.AreEqual(typeof(CauterizeGroupFormatter), factory.GetFormatter(typeof(MyGroup)).GetType());
            Assert.AreEqual(typeof(CauterizeFixedArrayFormatter), factory.GetFormatter(typeof(MyFixedArray)).GetType());
            Assert.AreEqual(typeof(CauterizeVariableArrayFormatter), factory.GetFormatter(typeof(MyVariableArray)).GetType());
            Assert.AreEqual(typeof(CauterizePrimitiveFormatter), factory.GetFormatter(typeof(int)).GetType());
            Assert.AreEqual(typeof(CauterizePrimitiveFormatter), factory.GetFormatter(typeof(double)).GetType());
            Assert.AreEqual(typeof(CauterizeEnumFormatter), factory.GetFormatter(typeof(GroupType)).GetType());
        }
    }
}
