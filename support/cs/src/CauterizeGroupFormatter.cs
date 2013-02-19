using System;
using System.IO;
using System.Linq;

namespace Cauterize
{
    public class CauterizeGroupFormatter : CauterizeContainerFormatter
    {
        public CauterizeGroupFormatter(CauterizeTypeFormatterFactory factory) : base(factory)
        {
        }
        public override object Deserialize(Stream serializationStream, Type t)
        {
            var ret = t.GetConstructor(new Type[] {}).Invoke(new object[] {});
            var props = OrderAttribute.GetSortedProperties(t);
            var typeProp = props.ElementAt(0);
            var enumFormatter = _typeFormatterFactory.GetFormatter(typeProp.PropertyType);
            var enumValue = enumFormatter.Deserialize(serializationStream, typeProp.PropertyType);
            typeProp.SetValue(ret, enumValue, null);
            var index = ((int) enumValue) + 1;
            var prop = props.ElementAt(index);
            var subType = prop.PropertyType;
            var subFormatter = _typeFormatterFactory.GetFormatter(subType);
            var subObj = subFormatter.Deserialize(serializationStream, subType);
            prop.SetValue(ret, subObj, null);
            return ret;
        }

        public override void Serialize(Stream serializationStream, object obj)
        {
            var props = OrderAttribute.GetSortedProperties(obj.GetType());
            var typeProp = props.ElementAt(0);
            var enumFormatter = _typeFormatterFactory.GetFormatter(typeProp.PropertyType);
            var enumValue = typeProp.GetValue(obj, null);
            enumFormatter.Serialize(serializationStream, enumValue);
            var index = ((int) enumValue) + 1;
            var subProp = props.ElementAt(index);
            var subType = subProp.PropertyType;
            var subFormatter = _typeFormatterFactory.GetFormatter(subType);
            subFormatter.Serialize(serializationStream, subProp.GetValue(obj, null));
        }
    }
}
