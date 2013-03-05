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
            var numBytes = GetNumBytesForEnum(t);
            var bytes = new byte[numBytes];
            serializationStream.Read(bytes, 0, numBytes);
            if (!BitConverter.IsLittleEndian)
            {
                Array.Reverse(bytes);
            }
            UInt32 intValue = 0;
            switch (numBytes)
            {
                case 4: intValue = BitConverter.ToUInt32(bytes, 0);
                        break;
                case 2: intValue = BitConverter.ToUInt16(bytes, 0);
                        break;
                case 1: intValue = (UInt32)bytes[0];
                        break;
            }
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
            serializationStream.Write(bytes, 0, GetNumBytesForEnum(obj.GetType()));
        }

        private int GetNumBytesForEnum(Type t)
        {
            var numBytes = 4;
            var max = Enum.GetValues(t).Cast<int>().Max();
            if (max < Byte.MaxValue)
            {
                numBytes = 1;
            }
            else if (max < UInt16.MaxValue)
            {
                numBytes = 2;
            }
            return numBytes;
        }
    }
}
