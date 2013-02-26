using System;
using System.IO;

namespace Cauterize
{
    public abstract class CauterizeContainerFormatter : ICauterizeTypeFormatter
    {
        protected CauterizeTypeFormatterFactory _typeFormatterFactory;

        public CauterizeContainerFormatter(CauterizeTypeFormatterFactory factory)
        {
            _typeFormatterFactory = factory;
        }

        public abstract object Deserialize(Stream serializationStream, Type t);
        public abstract void Serialize(Stream serializationStream, object obj);
    }
}