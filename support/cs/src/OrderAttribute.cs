using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
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
        public static IOrderedEnumerable<PropertyInfo> GetSortedProperties(Type t)
        {
            return t.GetProperties().OrderBy(p => ((OrderAttribute)p.GetCustomAttributes(typeof(OrderAttribute), false)[0]).Order);
        }

    }
}

