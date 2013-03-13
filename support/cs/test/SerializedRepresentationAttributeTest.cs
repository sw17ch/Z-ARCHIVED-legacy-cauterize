using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;
using Cauterize;

namespace Cauterize.Test
{
    [SerializedRepresentation(typeof(Int16))]
    public enum MyEnum
    {
        Value1 = 1,
        Value2 = 2,
        Value3 = 3
    }

    [SerializedRepresentation(typeof(Int64))]
    public enum MyEnum2
    {
        Value21 = 21,
        Value22 = 22,
        Value23 = 23
    }

    [TestFixture]
    public class RepresentationAttributeTest
    {
        [Test]
        public void TestItHasARetrievalRepresentationType()
        {
            var representationType = SerializedRepresentationAttribute.GetRepresentation(typeof (MyEnum));
            Assert.That(representationType, Is.EqualTo(typeof(Int16)));

            representationType = SerializedRepresentationAttribute.GetRepresentation(typeof (MyEnum2));
            Assert.That(representationType, Is.EqualTo(typeof(Int64)));
        }
    }
}
