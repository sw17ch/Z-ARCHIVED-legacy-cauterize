using System;
using System.IO;

namespace Cauterize
{
    public class CauterizeCompositeFormatter : CauterizeContainerFormatter
    {
        public CauterizeCompositeFormatter(CauterizeTypeFormatterFactory factory) : base(factory)
        {
        }
        public override object Deserialize(Stream serializationStream, Type t)
        {
            var ret = t.GetConstructor(new Type[] {}).Invoke(new object[] {});
            foreach (var prop in OrderAttribute.GetSortedProperties(t))
            {
                var subType = prop.PropertyType;
                var subFormatter = _typeFormatterFactory.GetFormatter(subType);
                var subObj = subFormatter.Deserialize(serializationStream, subType);
                prop.SetValue(ret, subObj, null);
            }
            return ret;
        }

        public override void Serialize(Stream serializationStream, object obj)
        {
            foreach (var prop in OrderAttribute.GetSortedProperties(obj.GetType()))
            {
                var subType = prop.PropertyType;
                var subFormatter = _typeFormatterFactory.GetFormatter(subType);
                subFormatter.Serialize(serializationStream, prop.GetValue(obj, null));
            }
        }
    }
}
