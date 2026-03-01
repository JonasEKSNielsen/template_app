namespace Models.DTOs;

public class OAuthUserDTO
{
    public required int Id { get; set; }
    public required string Username { get; set; }
    public required string Email { get; set; }
    public required string Role { get; set; }
    public required DateTime CreatedAt { get; set; }
    public required string Picture { get; set; }
}
