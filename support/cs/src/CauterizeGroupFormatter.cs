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
            var typeProp = OrderAttribute.GetPropertyByOrder(t, 0);
            var enumFormatter = _typeFormatterFactory.GetFormatter(typeProp.PropertyType);
            var enumValue = enumFormatter.Deserialize(serializationStream, typeProp.PropertyType);
            typeProp.SetValue(ret, enumValue, null);
            var index = ((int) enumValue) + 1;
            var prop = OrderAttribute.GetPropertyByOrder(t, index);
            if (prop != null)
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
            var typeProp = OrderAttribute.GetPropertyByOrder(obj.GetType(), 0);
            var enumFormatter = _typeFormatterFactory.GetFormatter(typeProp.PropertyType);
            var enumValue = typeProp.GetValue(obj, null);
            enumFormatter.Serialize(serializationStream, enumValue);
            var index = ((int) enumValue) + 1;
            var subProp = OrderAttribute.GetPropertyByOrder(obj.GetType(), index);
            if (subProp != null)
            {
                var subType = subProp.PropertyType;
                var subFormatter = _typeFormatterFactory.GetFormatter(subType);
                subFormatter.Serialize(serializationStream, subProp.GetValue(obj, null));
            }
        }
    }
}
