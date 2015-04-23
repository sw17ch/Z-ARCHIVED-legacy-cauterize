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
            var arrayField = t.BaseType.GetField("_data", BindingFlags.NonPublic | BindingFlags.Instance);
            var arrayType = arrayField.FieldType.GetElementType();
            if (arrayType == typeof (Byte))
            {
                var arraySize = (ulong) t.GetField("MySize").GetValue(null);
                var arrayData = new byte[arraySize];
                serializationStream.Read(arrayData, 0, (int)arraySize);
                var ret = t.GetConstructor(new Type[] {typeof (Byte[])}).Invoke(new object[] {arrayData});
                return ret;
            }
            else
            {
                var ret = t.GetConstructor(new Type[] {}).Invoke(new object[] {});
                var array = (Array)arrayField.GetValue(ret);
                var subFormatter = _typeFormatterFactory.GetFormatter(arrayType);
                for (var i = 0; i < array.Length; i++)
                {
                    array.SetValue(subFormatter.Deserialize(serializationStream, arrayType), i);
                }
                return ret;
            }
        }

        public override void Serialize(Stream serializationStream, object obj)
        {
            var t = obj.GetType();
            var arrayField = t.BaseType.GetField("_data", BindingFlags.NonPublic | BindingFlags.Instance);
            var array = (Array)arrayField.GetValue(obj);
            var arrayType = arrayField.FieldType.GetElementType();
            if (arrayType == typeof (Byte))
            {
                serializationStream.Write((byte[]) array, 0, array.Length);
            }
            else
            {
                var subFormatter = _typeFormatterFactory.GetFormatter(arrayType);
                for (var i = 0; i < array.Length; i++)
                {
                    subFormatter.Serialize(serializationStream, array.GetValue(i));
                }
            }
        }
    }
}
