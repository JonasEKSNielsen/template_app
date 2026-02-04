using System;
using System.Collections.Generic;
using System.Text;

namespace Models
{
    public class Post : Common
    {
        public required string Content { get; set; } = string.Empty;
        public required string OwnerId { get; set; }
        public User? Owner { get; set; }
        public List<UserPostLiked>? Likes { get; set; }
    }
}
