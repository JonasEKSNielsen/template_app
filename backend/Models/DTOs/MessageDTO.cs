using System;
using System.Collections.Generic;
using System.Text;

namespace Models.DTOs
{
    public class MessageDTO
    {
        public required string Message { get; set; }
        public required string UserId { get; set; }
        public required string ChatId { get; set; }
    }
}
