using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace Cauterize
{
    public interface ICauterizeTypeFormatter
    {
        object Deserialize(Stream serializationStream, Type t);
        void Serialize(Stream serializationStream, object obj);
    }
}
