using System.ComponentModel.DataAnnotations;

namespace Models
{
    public class User : Common
    {
        [Required(ErrorMessage = "Brugernavn er påkrævet.")]
        [Display(Name = "Navn")]
        public required string Name { get; set; }

        [Required(ErrorMessage = "Email er påkrævet.")]
        [EmailAddress(ErrorMessage = "Email er ikke gyldig")]
        [Display(Name = "Email")]
        public required string Email { get; set; }

        [Required(ErrorMessage = "Adgangskode er påkrævet.")]
        [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$",
            ErrorMessage = "Der skal være mindst 8 karaktere, mindst et stort bogstav, et lillebogstav og et tal")]
        [Display(Name = "Adgangskode")]
        public required string Password { get; set; }

        public required string Salt { get; set; }
        public string? RealPassword { get; set; }
        public string? RefreshToken { get; set; }
        public DateTime? RefreshTokenExpiresAt { get; set; }

        [Required(ErrorMessage = "Der skal tilføjes et billede")]
        [Base64String(ErrorMessage = "Billede er ikke et gyldigt base64 billede")]
        public required string Base64Pfp { get; set; }
        public List<UserChatConvo>? Chats { get; set; }
        public List<UserPostLiked>? Liked { get; set; }
        public List<Post>? CreatedPosts { get; set; } 
    }
}
