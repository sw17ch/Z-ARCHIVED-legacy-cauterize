using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Runtime.Serialization;
using System.Text;

namespace Cauterize
{
    public class CauterizeFormatter
    {
        public SerializationBinder Binder { get; set; }
        public StreamingContext Context { get; set; }
        public ISurrogateSelector SurrogateSelector { get; set; }

        private readonly CauterizeTypeFormatterFactory _formatterFactory;
        public CauterizeFormatter() // only needed for deserialization
        {
            _formatterFactory = new CauterizeTypeFormatterFactory();
        }

        public CauterizeFormatter(CauterizeTypeFormatterFactory factory)
        {
            _formatterFactory = factory;
        }

        public virtual T Deserialize<T>(Stream serializationStream)
        {
            var formatter = _formatterFactory.GetFormatter(typeof(T));
            return (T)formatter.Deserialize(serializationStream, typeof(T));
        }

        public virtual void Serialize(Stream serializationStream, object obj)
        {
            var formatter = _formatterFactory.GetFormatter(obj.GetType());
            formatter.Serialize(serializationStream, obj);
        }
    }
}

