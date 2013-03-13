using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace Cauterize
{
    public class CauterizeEnumFormatter : ICauterizeTypeFormatter
    {
        public object Deserialize(Stream serializationStream, Type t)
        {
            var numBytes = GetNumBytesForEnum(t);
            var bytes = new byte[numBytes];
            serializationStream.Read(bytes, 0, numBytes);
            if (!BitConverter.IsLittleEndian)
            {
                Array.Reverse(bytes);
            }
            Int64 intValue = 0;
            switch (numBytes)
            {
                case 8: intValue = BitConverter.ToInt64(bytes, 0);
                        break;
                case 4: intValue = BitConverter.ToInt32(bytes, 0);
                        break;
                case 2: intValue = BitConverter.ToInt16(bytes, 0);
                        break;
                case 1: intValue = (Int32)bytes[0];
                        break;
            }
            return Enum.ToObject(t, intValue);
        }

        public void Serialize(Stream serializationStream, object obj)
        {
            var longValue = Convert.ToInt64(obj);
            var bytes = BitConverter.GetBytes(longValue);
            if (!BitConverter.IsLittleEndian)
            {
                Array.Reverse(bytes);
            }
            serializationStream.Write(bytes, 0, GetNumBytesForEnum(obj.GetType()));
        }

        private int GetNumBytesForEnum(Type t)
        {
            var type = SerializedRepresentationAttribute.GetRepresentation(t);
            if (type == typeof(SByte) || type == typeof(Byte))
            {
                return 1;
            }
            else if (type == typeof(Int16) || type == typeof(UInt16))
            {
                return 2;
            }
            else if (type == typeof(Int32) || type == typeof(UInt32))
            {
                return 4;
            }
            else if (type == typeof(Int64) || type == typeof(UInt64))
            {
                return 8;
            }
            return 0;
        }
    }
}
