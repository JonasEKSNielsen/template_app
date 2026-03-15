using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
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

    [HttpGet("github/callback")]
    public async Task<IActionResult> GitHubCallback([FromQuery] string? code, [FromQuery] string? error)
    {
        if (!string.IsNullOrWhiteSpace(error))
        {
            return Content(BuildPopupResultHtml("github_oauth_error", null, $"github error {error}"), "text/html");
        }

        if (string.IsNullOrWhiteSpace(code))
        {
            return Content(BuildPopupResultHtml("github_oauth_error", null, "github no code"), "text/html");
        }

        var redirectUri = $"{Request.Scheme}://{Request.Host}/api/auth/github/callback";
        var result = await _authService.OAuthLoginAsync(new OAuthLoginDTO
        {
            Provider = "GitHub",
            AccessToken = code,
            RedirectUri = redirectUri,
        });

        if (result == null)
        {
            return Content(BuildPopupResultHtml("github_oauth_error", null, "github login failed try again"), "text/html");
        }

        return Content(BuildPopupResultHtml("github_oauth_success", result, null), "text/html");
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
            provider = "oauth"
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

    private static string BuildPopupResultHtml(string type, AuthResponseDTO? data, string? message)
    {
        var jsonOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        };

        var payloadJson = JsonSerializer.Serialize(new
        {
            type,
            data,
            message,
        }, jsonOptions);

        return "<!doctype html>\n"
            + "<html>\n"
            + "<body>\n"
            + "  <script>\n"
            + "    (function () {\n"
            + "      var payload = " + payloadJson + ";\n"
            + "      if (window.opener) {\n"
            + "        window.opener.postMessage(payload, '*');\n"
            + "      }\n"
            + "      window.close();\n"
            + "    })();\n"
            + "  </script>\n"
            + "</body>\n"
            + "</html>";
    }
}
