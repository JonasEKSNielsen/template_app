using System;
using System.Collections.Generic;
using System.Text;

namespace Models.DTOs
{
    public class RegisterDTO
    {
        public required string Email { get; set; }
        public required string Username { get; set; }
        public required string Password { get; set; }

        public required string Base64Pfp { get; set; }
    }
}
