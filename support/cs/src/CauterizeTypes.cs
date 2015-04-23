﻿using System;
using System.Diagnostics;
using System.Linq;
using Cauterize.Common;

namespace Cauterize
{
    public class CauterizeInfo
    {
        public string Name;
        public string GeneratedVersion;
        public string GeneratedDate;

        public int ModelHashLength;
        public byte[] ModelHash;
    }

    public class CauterizeComposite
    {
        public override string ToString()
        {
            var result = "{";
            foreach (var prop in OrderAttribute.GetSortedProperties(GetType()))
            {
                result += String.Format("{0}: {1}, ", prop.Name, prop.GetValue(this, null));
            }
            result = result.TrimEnd(',', ' ');
            result += "}";
            return result;
        }
    }

    public class CauterizeGroup
    {
        public override string ToString()
        {
            var enumProp = OrderAttribute.GetPropertyByOrder(GetType(), 0);
            var value = enumProp.GetValue(this, null);
            var index = (int)value + 1;
            var prop = OrderAttribute.GetPropertyByOrder(GetType(), index);
            if (prop != null)
            {
                return String.Format("({0}: {1})", prop.Name, prop.GetValue(this, null));
            }
            else
            {
                return String.Format("({0})", value);
            }
        }
    }

    public abstract class CauterizeFixedArray
    {
        public abstract object[] ObjectArray();
    }

    public abstract class CauterizeFixedArrayTyped<T> : CauterizeFixedArray
    {
        private T[] _data;

        protected abstract ulong Size { get; }

        protected void Allocate(T[] data)
        {
            Allocate((ulong)data.Length);
            Array.Copy(data, _data, data.Length);
        }

        protected void Allocate(ulong size)
        {
            if (size != Size)
            {
                throw new CauterizeException("arrays for " + GetType() + " must be size " + Size);
            }
            _data = new T[size];
        }

        public static implicit operator T[](CauterizeFixedArrayTyped<T> array)
        {
            return array._data;
        }

        public override string ToString()
        {
            var result = "[";
            result += String.Join(", ", _data);
            result += "]";
            return result;
        }

        // implicit conversion won't cover slicing
        public T this[int i]
        {
            get { return _data[i]; }
            set { _data[i] = value; }
        }

        public T[] GetArray()
        {
            return _data;
        }

        public override object[] ObjectArray()
        {
            var objArr = new object[_data.Length];
            Array.Copy(_data, objArr, objArr.Length);
            return objArr;
        }
    }

    public abstract class CauterizeVariableArray
    {
        public abstract object[] ObjectArray();
    }

    [DebuggerDisplay("{DebuggerDisplay}")]
    public abstract class CauterizeVariableArrayTyped<T> : CauterizeVariableArray
    {
        private T[] _data;

        protected abstract ulong MaxSize { get; }

        protected void Allocate(T[] data)
        {
            Allocate((ulong)data.Length);
            Array.Copy(data, _data, data.Length);
        }

        protected void Allocate(ulong size)
        {
            if (size > MaxSize)
            {
                throw new CauterizeException("arrays for " + GetType() + " must be smaller than " + MaxSize);
            }
            _data = new T[size];
        }

        public static implicit operator T[](CauterizeVariableArrayTyped<T> array)
        {
            return array._data;
        }

        public string DebuggerDisplay
        {
            get
            {
                var result = this.ToString();
                var bytes = _data as byte[];
                if (bytes != null)
                    result = StringExtensions.BytesToString(bytes) + " " + result;
                return result;
            }
        }

        public override string ToString()
        {
            var result = "[";
            result += String.Join(", ", _data);
            result += "]";
            return result;
        }

        // implicit conversion won't cover slicing
        public T this[int i]
        {
            get { return _data[i]; }
            set { _data[i] = value; }
        }

        public T[] GetArray()
        {
            return _data;
        }

        public override object[] ObjectArray()
        {
            var objArr = new object[_data.Length];
            Array.Copy(_data, objArr, objArr.Length);
            return objArr;
        }
    }
}

