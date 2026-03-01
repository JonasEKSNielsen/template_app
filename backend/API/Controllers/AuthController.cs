using Microsoft.AspNetCore.Mvc;
using Models.DTOs;
using Services.Interfaces;

namespace API.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("oauth-login")]
    public async Task<ActionResult<AuthResponseDTO>> OAuthLogin([FromBody] OAuthLoginDTO dto)
    {
        var result = await _authService.OAuthLoginAsync(dto);
        if (result == null)
        {
            return Unauthorized();
        }

        return Ok(result);
    }

    [HttpGet("me")]
    public ActionResult<object> Me()
    {
        var token = GetBearerToken();
        if (string.IsNullOrWhiteSpace(token))
        {
            return Unauthorized();
        }

        var session = _authService.GetSession(token);
        if (session == null)
        {
            return Unauthorized();
        }

        return Ok(new
        {
            id = session.User.Id.ToString(),
            email = session.User.Email,
            displayName = session.User.Username,
            avatarUrl = session.User.Picture,
            provider = "google"
        });
    }

    [HttpPost("logout")]
    public IActionResult Logout()
    {
        var token = GetBearerToken();
        if (string.IsNullOrWhiteSpace(token))
        {
            return NoContent();
        }

        _authService.Logout(token);
        return NoContent();
    }

    private string? GetBearerToken()
    {
        var header = Request.Headers.Authorization.ToString();
        if (string.IsNullOrWhiteSpace(header))
        {
            return null;
        }

        const string prefix = "Bearer ";
        if (!header.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

        return header[prefix.Length..].Trim();
    }
}
