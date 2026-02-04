using System.ComponentModel.DataAnnotations;

namespace Models
{
    public class Message : Common
    {
        public required string Content { get; set; }
        public required string OwnerId { get; set; }
        public User? Owner { get; set; }
        public required string ChatId { get; set; }
        public Chat? Chat { get; set; }
    }
}
