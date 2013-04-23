using System;
using System.IO;
using System.Runtime.Serialization;

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
            return (T)Deserialize(serializationStream, typeof (T));
        }

        public virtual object Deserialize(Stream serializationStream, Type t)
        {
            var formatter = _formatterFactory.GetFormatter(t);
            return formatter.Deserialize(serializationStream, t);
        }

        public virtual void Serialize(Stream serializationStream, object obj)
        {
            var formatter = _formatterFactory.GetFormatter(obj.GetType());
            formatter.Serialize(serializationStream, obj);
        }
    }
}

