using System;
using System.Collections.Generic;
using System.Text;

namespace Models.DTOs
{
    public class UserDTO
    {
        public string Id { get; set; } = null!;
        public string Name { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string Base64Pfp { get; set; } = null!;
    }
}
