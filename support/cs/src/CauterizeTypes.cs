using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Cauterize
{
    public class CauterizeInfo {
        public static string Name;
        public static string GeneratedVersion;
        public static string GeneratedDate;
    }

    public class CauterizeComposite
    {
    }

    public class CauterizeGroup
    {
    }

    public abstract class CauterizeFixedArray
    {
    }

    public abstract class CauterizeFixedArrayTyped<T> : CauterizeFixedArray
    {
        private T[] _data;

        protected abstract int Size { get; }
        
        protected void Allocate(T[] data)
        {
            Allocate(data.Length);
            Array.Copy(data, _data, data.Length);
        }

        protected void Allocate(int size)
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

        // implicit conversion won't cover slicing
        public T this[int i]
        {
            get { return _data[i]; }
            set { _data[i] = value; }
        }
    }

    public abstract class CauterizeVariableArray
    {
    }

    public abstract class CauterizeVariableArrayTyped<T> : CauterizeVariableArray
    {
        private T[] _data;

        protected abstract int MaxSize { get; }
        
        protected void Allocate(T[] data)
        {
            Allocate(data.Length);
            Array.Copy(data, _data, data.Length);
        }

        protected void Allocate(int size)
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

        // implicit conversion won't cover slicing
        public T this[int i]
        {
            get { return _data[i]; }
            set { _data[i] = value; }
        }
    }
}

