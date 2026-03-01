namespace Models.DTOs;

public class AuthResponseDTO
{
    public required string Token { get; set; }
    public required string RefreshToken { get; set; }
    public required DateTime Expires { get; set; }
    public required OAuthUserDTO User { get; set; }
}
