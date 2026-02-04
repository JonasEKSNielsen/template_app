using System;
using System.Collections.Generic;
using System.Text;

namespace Models
{
    public class Chat : Common
    {
        public required string Title { get; set; }
        public List<UserChatConvo>? ChatUsers { get; set; }
        public List<Message>? Messages { get; set; }
    }
}
