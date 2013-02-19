using System;
using System.IO;
using System.Reflection;

namespace Cauterize
{
    public class CauterizeFixedArrayFormatter : CauterizeContainerFormatter
    {
        public CauterizeFixedArrayFormatter(CauterizeTypeFormatterFactory factory) : base(factory)
        {
        }
        public override object Deserialize(Stream serializationStream, Type t)
        {
            var ret = t.GetConstructor(new Type[] {}).Invoke(new object[] {});
            var arrayField = t.GetField("_data", BindingFlags.NonPublic | BindingFlags.Instance);
            var array = (Array)arrayField.GetValue(ret);
            var arrayType = arrayField.FieldType.GetElementType();
            var subFormatter = _typeFormatterFactory.GetFormatter(arrayType);
            for (var i = 0; i < array.Length; i++)
            {
                array.SetValue(subFormatter.Deserialize(serializationStream, arrayType), i);
            }
            return ret;
        }

        public override void Serialize(Stream serializationStream, object obj)
        {
            var t = obj.GetType();
            var arrayField = t.GetField("_data", BindingFlags.NonPublic | BindingFlags.Instance);
            var array = (Array)arrayField.GetValue(obj);
            var arrayType = arrayField.FieldType.GetElementType();
            var subFormatter = _typeFormatterFactory.GetFormatter(arrayType);
            for (var i = 0; i < array.Length; i++)
            {
                subFormatter.Serialize(serializationStream, array.GetValue(i));
            }
        }
    }
}
