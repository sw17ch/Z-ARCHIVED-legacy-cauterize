using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Cauterize
{
    public class CauterizeTypeFormatterFactory
    {
        public virtual ICauterizeTypeFormatter GetFormatter(Type t)
        {
            ICauterizeTypeFormatter formatter;
            if (t.IsSubclassOf(typeof (CauterizeComposite)))
            {
                formatter = new CauterizeCompositeFormatter(this);
            }
            else if (t.IsSubclassOf(typeof (CauterizeGroup)))
            {
                formatter = new CauterizeGroupFormatter(this);
            }
            else if (t.IsSubclassOf(typeof (CauterizeFixedArray)))
            {
                formatter = new CauterizeFixedArrayFormatter(this);
            }
            else if (t.IsSubclassOf(typeof (CauterizeVariableArray)))
            {
                formatter = new CauterizeVariableArrayFormatter(this);
            }
            else if (t.IsSubclassOf(typeof (Enum)))
            {
                formatter = new CauterizeEnumFormatter();
            }
            else 
            {
                formatter = new CauterizePrimitiveFormatter();
            }
            return formatter;
        }
    }
}
