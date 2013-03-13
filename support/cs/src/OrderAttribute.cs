using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Reflection;
using System.Text;

namespace Cauterize
{
    [AttributeUsage(AttributeTargets.Property | AttributeTargets.Field, 
        Inherited = true, AllowMultiple = false)]
    [ImmutableObject(true)]
    public sealed class OrderAttribute : Attribute {
        private readonly int _order;
        public int Order { get { return _order; } }
        public OrderAttribute(int order) {_order = order;}
        public static IEnumerable<PropertyInfo> GetSortedProperties(Type t)
        {
            var propComp = new Comparison<PropertyInfo>(CompareProps);
            var propList = new List<PropertyInfo>(t.GetProperties());

            propList.Sort(propComp);

            return propList;
        }

        public static PropertyInfo GetPropertyByOrder(Type t, int order)
        {
            foreach (var prop in t.GetProperties())
            {
                var orderAttr = ((OrderAttribute)prop.GetCustomAttributes(typeof(OrderAttribute), false)[0]);

                if (orderAttr.Order == order)
                {
                    return prop;
                }
            }

            return null;
        }

        private static int CompareProps(PropertyInfo a, PropertyInfo b)
        {
            OrderAttribute _a = (OrderAttribute)a.GetCustomAttributes(typeof(OrderAttribute), false)[0];
            OrderAttribute _b = (OrderAttribute)b.GetCustomAttributes(typeof(OrderAttribute), false)[0];

            return _a.Order - _b.Order;
        }
    }
}

