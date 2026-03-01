using Models.DTOs;

namespace Services.Interfaces;

public interface IAuthService
{
    Task<AuthResponseDTO?> OAuthLoginAsync(OAuthLoginDTO dto);
    AuthResponseDTO? GetSession(string token);
    bool Logout(string token);
}
