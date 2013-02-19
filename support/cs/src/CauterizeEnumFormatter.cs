using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace Cauterize
{
    public class CauterizeEnumFormatter : ICauterizeTypeFormatter
    {
        public object Deserialize(Stream serializationStream, Type t)
        {
            var bytes = new byte[4];
            serializationStream.Read(bytes, 0, 4);
            if (!BitConverter.IsLittleEndian)
            {
                Array.Reverse(bytes);
            }
            var intValue = BitConverter.ToInt32(bytes, 0);
            return Enum.ToObject(t, intValue);
        }

        public void Serialize(Stream serializationStream, object obj)
        {
            var intValue = (int) obj;
            var bytes = BitConverter.GetBytes(intValue);
            if (!BitConverter.IsLittleEndian)
            {
                Array.Reverse(bytes);
            }
            serializationStream.Write(bytes, 0, 4);
        }
    }
}
