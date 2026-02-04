using System;
using System.Collections.Generic;
using System.Text;

namespace Models
{
    public class Common
    {
        public required string Id { get; set; }
        public required DateTime CreatedAt { get; set; }
        public required DateTime UpdatedAt { get; set; }
    }
}
