using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using NUnit.Framework;
using Cauterize;

namespace Cauterize.Test
{
    public class HasSomeAttrs
    {
        [Order(0)]
        public int IntAttr { get; set; }

        [Order(1)]
        public string StringAttr { get; set; }

        /* something unused for #2 */

        [Order(3)]
        public float FloatAttr { get; set; }
    }

    [TestFixture]
    public class OrderAttributeTest
    {
        [Test]
        public void TestItAllowsIterationOfAttributesInOrder()
        {
            var attrs = OrderAttribute.GetSortedProperties(typeof (HasSomeAttrs));
            Assert.AreEqual("IntAttr", attrs.ElementAt(0).Name);
            Assert.AreEqual("StringAttr", attrs.ElementAt(1).Name);
            Assert.AreEqual("FloatAttr", attrs.ElementAt(2).Name);

            var thirdAttr = OrderAttribute.GetPropertyByOrder(typeof (HasSomeAttrs), 3);
            Assert.AreEqual("FloatAttr", thirdAttr.Name);
        }
    }
}
