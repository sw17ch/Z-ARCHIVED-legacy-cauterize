using System;
using System.ComponentModel;
using System.IO;
using System.Runtime.Serialization;
using System.Text;

namespace Cauterize
{
    public class CauterizePrimitiveFormatter : ICauterizeTypeFormatter
    {
        public object Deserialize(Stream serializationStream, Type t)
        {
            var numBytes = PrimitiveSupport.TypeToByteSize(t);
            var bytes = new byte[numBytes];
            serializationStream.Read(bytes, 0, numBytes);
            if (!BitConverter.IsLittleEndian)
            {
                Array.Reverse(bytes);
            }
            return PrimitiveSupport.TypeFromBytes(t, bytes);
        }

        public void Serialize(Stream serializationStream, object obj)
        {
            var bytes = PrimitiveSupport.BytesFromValue(obj);
            if (!BitConverter.IsLittleEndian)
            {
                Array.Reverse(bytes);
            }
            serializationStream.Write(bytes, 0, bytes.Length);
        }
    }
}
