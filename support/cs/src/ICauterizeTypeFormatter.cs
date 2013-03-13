using System;
using System.Collections.Generic;
using System.IO;

namespace Cauterize
{
    public interface ICauterizeTypeFormatter
    {
        object Deserialize(Stream serializationStream, Type t);
        void Serialize(Stream serializationStream, object obj);
    }
}
