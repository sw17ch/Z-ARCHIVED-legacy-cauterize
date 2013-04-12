using System;

namespace Cauterize
{
    public class CauterizeInfo {
        public static string Name;
        public static string GeneratedVersion;
        public static string GeneratedDate;
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
            var index = (int) value + 1;
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

        public override string ToString()
        {
            var result = "[";
            for (var i = 0; i < _data.Length; i++)
            {
                result += String.Format("{0},", _data[i]);
            }
            result += "]";
            return result;
        }

        // implicit conversion won't cover slicing
        public T this[int i]
        {
            get { return _data[i]; }
            set { _data[i] = value; }
        }
    }
}

