namespace Models.DTOs;

public class OAuthLoginDTO
{
    public required string Provider { get; set; }
    public required string AccessToken { get; set; }
    public string? RedirectUri { get; set; }
}
