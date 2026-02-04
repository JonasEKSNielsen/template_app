using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace Models
{
    public class UserPostLiked
    {
        [Required(ErrorMessage = "Der skal være mindst en tilkoblet bruger")]
        public required string UserId { get; set; }
        public User? User { get; set; }

        [Required(ErrorMessage = "Der skal være mindst et tilkoblet opslag")]
        public required string PostId { get; set; }
        public Post? Post { get; set; }
    }
}
