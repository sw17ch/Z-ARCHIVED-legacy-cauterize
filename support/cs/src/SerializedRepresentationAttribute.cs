using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Reflection;
using System.Text;

namespace Cauterize
{
    [AttributeUsage(AttributeTargets.Enum, Inherited = true, AllowMultiple = false)]
    [ImmutableObject(true)]
    public sealed class SerializedRepresentationAttribute : Attribute {
        public Type Type { get; private set; }
        public SerializedRepresentationAttribute(Type type) 
        {
            Type = type;
        }
        public static Type GetRepresentation(Type t)
        {
            var attrs = t.GetCustomAttributes(typeof(SerializedRepresentationAttribute), false);
            return ((SerializedRepresentationAttribute)attrs[0]).Type;
        }
    }
}

