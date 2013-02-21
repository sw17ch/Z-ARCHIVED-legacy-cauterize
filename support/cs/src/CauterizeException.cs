using System;

namespace Cauterize 
{
    public class CauterizeException : Exception
    {
        public CauterizeException(string message) : base(message)
        {
        }

        public CauterizeException(string message, Exception innerException) : base(message, innerException)
        {
        }
    }
}
