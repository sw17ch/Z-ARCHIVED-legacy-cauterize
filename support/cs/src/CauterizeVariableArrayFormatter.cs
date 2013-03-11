using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;

namespace Cauterize
{
    public class CauterizeVariableArrayFormatter : CauterizeContainerFormatter 
    {
        public CauterizeVariableArrayFormatter(CauterizeTypeFormatterFactory factory) : base(factory)
        {
        }


        public override object Deserialize(Stream serializationStream, Type t)
        {
            var sizeType = (Type) t.GetField("SizeType").GetValue(null);
            var sizeFormatter = _typeFormatterFactory.GetFormatter(sizeType);
            var rawSize = sizeFormatter.Deserialize(serializationStream, sizeType);
            var arraySize = PrimitiveSupport.TypeToInt(rawSize);
            var ret = t.GetConstructor(new Type[] {typeof (int)}).Invoke(new object[] {arraySize});
            var arrayField = t.BaseType.GetField("_data", BindingFlags.NonPublic | BindingFlags.Instance);
            var array = (Array)arrayField.GetValue(ret);
            var arrayType = arrayField.FieldType.GetElementType();
            var subFormatter = _typeFormatterFactory.GetFormatter(arrayType);
            for (var i = 0; i < arraySize; i++)
            {
                array.SetValue(subFormatter.Deserialize(serializationStream, arrayType), i);
            }
            return ret;
        }

        public override void Serialize(Stream serializationStream, object obj)
        {
            var t = obj.GetType();
            var arrayField = t.BaseType.GetField("_data", BindingFlags.NonPublic | BindingFlags.Instance);
            var array = (Array)arrayField.GetValue(obj);
            var sizeType = (Type) t.GetField("SizeType").GetValue(null);
            var sizeFormatter = _typeFormatterFactory.GetFormatter(sizeType);
            sizeFormatter.Serialize(serializationStream, PrimitiveSupport.IntToType(sizeType, array.Length));
            var arrayType = arrayField.FieldType.GetElementType();
            var subFormatter = _typeFormatterFactory.GetFormatter(arrayType);
            for (var i = 0; i < array.Length; i++)
            {
                subFormatter.Serialize(serializationStream, array.GetValue(i));
            }
        }
    }
}
