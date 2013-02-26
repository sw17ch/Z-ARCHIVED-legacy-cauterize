using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.Serialization;
using System.Text;

namespace Cauterize
{
    public class CauterizeFormatter : IFormatter
    {
        public SerializationBinder Binder { get; set; }
        public StreamingContext Context { get; set; }
        public ISurrogateSelector SurrogateSelector { get; set; }

        private readonly Type _deserializeType;
        private readonly CauterizeTypeFormatterFactory _formatterFactory;
        public CauterizeFormatter(Type deserializeType) // only needed for deserialization
        {
            _deserializeType = deserializeType;
            _formatterFactory = new CauterizeTypeFormatterFactory();
        }

        public CauterizeFormatter(Type deserializeType, CauterizeTypeFormatterFactory factory)
        {
            _deserializeType = deserializeType;
            _formatterFactory = factory;
        }

        public virtual object Deserialize(Stream serializationStream)
        {
            var formatter = _formatterFactory.GetFormatter(_deserializeType);
            return formatter.Deserialize(serializationStream, _deserializeType);
        }

        public virtual void Serialize(Stream serializationStream, object obj)
        {
            var formatter = _formatterFactory.GetFormatter(obj.GetType());
            formatter.Serialize(serializationStream, obj);
        }
    }
}

