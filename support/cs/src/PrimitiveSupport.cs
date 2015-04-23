using System;
using System.Collections.Generic;
using System.Text;

namespace Cauterize
{
    public class PrimitiveSupport
    {
        static public int TypeToByteSize(Type t)
        {
            if (t == typeof(Byte) || t == typeof(SByte))
            {
                return 1;
            }
            else if (t == typeof (UInt16) || t == typeof (Int16))
            {
                return 2;
            }
            else if (t == typeof (UInt32) || t == typeof (Int32))
            {
                return 4;
            }
            else if (t == typeof (UInt64) || t == typeof (Int64))
            {
                return 8;
            }
            else if (t == typeof (Single))
            {
                return 4;
            }
            else if (t == typeof (Double))
            {
                return 8;
            }
            else if (t == typeof (Boolean))
            {
                return 1;
            }
            else
            {
                throw new Exception("Invalid type to get byte size");
            }
        }

        static public int TypeToInt(object value)
        {
            if (value is Int32)
            {
                return (int) value;
            }
            else if (value is Int16)
            {
                return (Int16)value;
            }
            else if (value is Byte)
            {
                return (Byte) value;
            }
            else if (value is UInt32)
            {
                return (int)(UInt32) value;
            }
            else if (value is UInt16)
            {
                return (UInt16) value;
            }
            else if (value is SByte)
            {
                return (SByte) value;
            }
            else if (value == null)
            {
                return 0;
            }
            else
            {
                throw new Exception("invalid array size type");
            }
        }

        static public object IntToType(Type t, int value)
        {
            if (t == typeof(Int32))
            {
                return value;
            }
            else if (t == typeof(Int16))
            {
                return (Int16)value;
            }
            else if (t == typeof(Byte))
            {
                return (Byte)value;
            }
            else if (t == typeof (UInt32))
            {
                return (UInt32) value;
            }
            else if (t == typeof (UInt16))
            {
                return (UInt16) value;
            }
            else if (t == typeof (SByte))
            {
                return (SByte) value;
            }
            else
            {
                throw new Exception("Invalid type for array size type");
            }

        }

        static public object TypeFromBytes(Type t, byte[] bytes)
        {
            if (t == typeof (Byte))
            {
                return bytes[0];
            }
            else if (t == typeof (SByte))
            {
                return (SByte) bytes[0];
            }
            else
            {
                return typeof(BitConverter)
                    .GetMethod("To" + t.Name, new Type[] {typeof(byte[]), typeof(int)})
                    .Invoke(null,new object[]{bytes, 0});
            }
        }

        static public byte[] BytesFromValue(object value)
        {
            if (value is Byte || value is SByte)
            {
                return new[] {(byte) value};
            }
            else
            {
                return (byte[]) typeof (BitConverter)
                    .GetMethod("GetBytes", new Type[] {value.GetType()})
                    .Invoke(null, new object[] {value});
            }
        }
    }
}
