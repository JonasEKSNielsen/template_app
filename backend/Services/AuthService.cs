using System.Collections.Concurrent;
using System.IdentityModel.Tokens.Jwt;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using System.Security.Claims;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Models;
using Models.DTOs;
using Repositories.Interfaces;
using Services.Interfaces;

namespace Services;

public class AuthService : IAuthService
{
    private readonly IUserRepo _userRepo;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IConfiguration _configuration;

    private static readonly ConcurrentDictionary<string, AuthResponseDTO> Sessions = new();

    public AuthService(
        IUserRepo userRepo,
        IHttpClientFactory httpClientFactory,
        IConfiguration configuration)
    {
        _userRepo = userRepo;
        _httpClientFactory = httpClientFactory;
        _configuration = configuration;
    }

    public async Task<AuthResponseDTO?> OAuthLoginAsync(OAuthLoginDTO dto)
    {
        if (string.IsNullOrWhiteSpace(dto.AccessToken))
        {
            return null;
        }

        if (string.Equals(dto.Provider, "Google", StringComparison.OrdinalIgnoreCase))
        {
            var googleProfile = await GetGoogleProfileAsync(dto.AccessToken);
            if (googleProfile == null || string.IsNullOrWhiteSpace(googleProfile.Value.Email))
            {
                return null;
            }

            var profile = googleProfile.Value;

            var user = await GetOrCreateUserAsync(profile.Email, profile.Name);
            if (user == null) return null;

            return CreateAndStoreSession(user, profile.Picture);
        }

        if (string.Equals(dto.Provider, "GitHub", StringComparison.OrdinalIgnoreCase))
        {
            return await GitHubOAuthLoginAsync(dto.AccessToken, dto.RedirectUri);
        }

        return null;
    }

    public AuthResponseDTO? GetSession(string token)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            return null;
        }

        if (!Sessions.TryGetValue(token, out var session))
        {
            session = TryCreateSessionFromToken(token);
            if (session == null)
            {
                return null;
            }

            Sessions[token] = session;
        }

        if (session.Expires <= DateTime.UtcNow)
        {
            Sessions.TryRemove(token, out _);
            return null;
        }

        return session;
    }

    public bool Logout(string token)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            return false;
        }

        return Sessions.TryRemove(token, out _);
    }

    private async Task<AuthResponseDTO?> GitHubOAuthLoginAsync(string accessTokenOrCode, string? redirectUri)
    {
        var githubAccessToken = accessTokenOrCode;
        var githubProfile = await GetGitHubProfileAsync(githubAccessToken);
        if (githubProfile == null)
        {
            githubAccessToken = await ExchangeGitHubCodeForTokenAsync(accessTokenOrCode, redirectUri);
            if (string.IsNullOrWhiteSpace(githubAccessToken))
            {
                return null;
            }

            githubProfile = await GetGitHubProfileAsync(githubAccessToken);
            if (githubProfile == null)
            {
                return null;
            }
        }

        var profile = githubProfile.Value;
        var user = await GetOrCreateUserAsync(profile.Email, profile.Name);
        if (user == null) return null;

        return CreateAndStoreSession(user, profile.Picture);
    }

    private async Task<(string Email, string Name, string Picture)?> GetGitHubProfileAsync(string accessToken)
    {
        if (string.IsNullOrWhiteSpace(accessToken))
        {
            return null;
        }

        using var client = _httpClientFactory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        client.DefaultRequestHeaders.UserAgent.ParseAdd("template-app");
        client.DefaultRequestHeaders.Accept.ParseAdd("application/vnd.github+json");

        var userResponse = await client.GetAsync("https://api.github.com/user");
        if (!userResponse.IsSuccessStatusCode)
        {
            return null;
        }

        var userBody = await userResponse.Content.ReadAsStringAsync();
        using var userJson = JsonDocument.Parse(userBody);
        var userRoot = userJson.RootElement;

        var email = userRoot.TryGetProperty("email", out var emailNode)
            ? emailNode.GetString() ?? ""
            : "";
        var name = userRoot.TryGetProperty("name", out var nameNode)
            ? nameNode.GetString() ?? ""
            : "";
        var login = userRoot.TryGetProperty("login", out var loginNode)
            ? loginNode.GetString() ?? ""
            : "";
        var picture = userRoot.TryGetProperty("avatar_url", out var avatarNode)
            ? avatarNode.GetString() ?? ""
            : "";

        if (string.IsNullOrWhiteSpace(email))
        {
            var emailResponse = await client.GetAsync("https://api.github.com/user/emails");
            if (emailResponse.IsSuccessStatusCode)
            {
                var emailNodes = await emailResponse.Content.ReadFromJsonAsync<List<GitHubEmailResult>>();
                if (emailNodes != null && emailNodes.Count > 0)
                {
                    var selectedEmail = emailNodes
                        .FirstOrDefault(e => e.Primary && e.Verified)?.Email
                        ?? emailNodes.FirstOrDefault(e => e.Verified)?.Email
                        ?? emailNodes[0].Email;
                    email = selectedEmail ?? "";
                }
            }
        }

        if (string.IsNullOrWhiteSpace(email))
        {
            return null;
        }

        if (string.IsNullOrWhiteSpace(name))
        {
            name = !string.IsNullOrWhiteSpace(login)
                ? login
                : email.Split('@')[0];
        }

        return (email, name, picture);
    }

    private async Task<string?> ExchangeGitHubCodeForTokenAsync(string code, string? redirectUri)
    {
        var clientId = _configuration["GitHub:ClientId"];
        var clientSecret = _configuration["GitHub:ClientSecret"];
        if (string.IsNullOrWhiteSpace(clientId) || string.IsNullOrWhiteSpace(clientSecret))
        {
            return null;
        }

        using var client = _httpClientFactory.CreateClient();
        client.DefaultRequestHeaders.Accept.ParseAdd("application/json");
        client.DefaultRequestHeaders.UserAgent.ParseAdd("template-app");

        var form = new Dictionary<string, string>
        {
            ["client_id"] = clientId,
            ["client_secret"] = clientSecret,
            ["code"] = code,
        };

        if (!string.IsNullOrWhiteSpace(redirectUri))
        {
            form["redirect_uri"] = redirectUri;
        }

        using var response = await client.PostAsync(
            "https://github.com/login/oauth/access_token",
            new FormUrlEncodedContent(form));

        if (!response.IsSuccessStatusCode)
        {
            return null;
        }

        var body = await response.Content.ReadAsStringAsync();
        using var document = JsonDocument.Parse(body);
        if (!document.RootElement.TryGetProperty("access_token", out var accessTokenNode))
        {
            return null;
        }

        var accessToken = accessTokenNode.GetString();
        return string.IsNullOrWhiteSpace(accessToken) ? null : accessToken;
    }

    private AuthResponseDTO? TryCreateSessionFromToken(string token)
    {
        var handler = new JwtSecurityTokenHandler();
        if (!handler.CanReadToken(token))
        {
            return null;
        }

        var secretKey = _configuration["Jwt:SecretKey"];
        if (string.IsNullOrWhiteSpace(secretKey))
        {
            return null;
        }

        var issuer = _configuration["Jwt:Issuer"] ?? "MyProject.Api";
        var audience = _configuration["Jwt:Audience"] ?? "FlutterApp";

        try
        {
            var principal = handler.ValidateToken(token, new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateIssuerSigningKey = true,
                ValidateLifetime = true,
                ValidIssuer = issuer,
                ValidAudience = audience,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
                ClockSkew = TimeSpan.FromMinutes(1),
            }, out var validatedToken);

            if (validatedToken is not JwtSecurityToken jwtToken)
            {
                return null;
            }

            var email = principal.FindFirst(JwtRegisteredClaimNames.Email)?.Value ?? "";
            if (string.IsNullOrWhiteSpace(email))
            {
                return null;
            }

            var username = principal.FindFirst(JwtRegisteredClaimNames.UniqueName)?.Value
                ?? email.Split('@')[0];

            var sub = principal.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
            var role = principal.FindFirst(ClaimTypes.Role)?.Value ?? "User";

            var id = Math.Abs(email.GetHashCode());
            if (!string.IsNullOrWhiteSpace(sub))
            {
                id = Math.Abs(sub.GetHashCode());
            }

            return new AuthResponseDTO
            {
                Token = token,
                RefreshToken = string.Empty,
                Expires = jwtToken.ValidTo.ToUniversalTime(),
                User = new OAuthUserDTO
                {
                    Id = id,
                    Username = username,
                    Email = email,
                    Role = role,
                    CreatedAt = DateTime.UtcNow,
                    Picture = string.Empty,
                }
            };
        }
        catch
        {
            return null;
        }
    }

    private async Task<(string Email, string Name, string Picture)?> GetGoogleProfileAsync(string accessToken)
    {
        using var client = _httpClientFactory.CreateClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

        var profileUrl = "https://content-people.googleapis.com/v1/people/me?sources=READ_SOURCE_TYPE_PROFILE&personFields=photos,names,emailAddresses";
        var response = await client.GetAsync(profileUrl);
        if (!response.IsSuccessStatusCode)
        {
            return null;
        }

        var body = await response.Content.ReadAsStringAsync();
        using var document = JsonDocument.Parse(body);
        var root = document.RootElement;

        var email = "";
        var name = "";
        var picture = "";

        if (root.TryGetProperty("emailAddresses", out var emails) &&
            emails.ValueKind == JsonValueKind.Array &&
            emails.GetArrayLength() > 0)
        {
            email = emails[0].GetProperty("value").GetString() ?? "";
        }

        if (root.TryGetProperty("names", out var names) &&
            names.ValueKind == JsonValueKind.Array &&
            names.GetArrayLength() > 0)
        {
            name = names[0].GetProperty("displayName").GetString() ?? "";
        }

        if (root.TryGetProperty("photos", out var photos) &&
            photos.ValueKind == JsonValueKind.Array &&
            photos.GetArrayLength() > 0)
        {
            picture = photos[0].GetProperty("url").GetString() ?? "";
        }

        if (string.IsNullOrWhiteSpace(name) && !string.IsNullOrWhiteSpace(email))
        {
            name = email.Split('@')[0];
        }

        return (email, name, picture);
    }

    private async Task<User?> GetOrCreateUserAsync(string email, string name)
    {
        var existingUser = await _userRepo.GetUserByEmail(email);
        if (existingUser != null)
        {
            return existingUser;
        }

        return await _userRepo.PostUser(new User
        {
            Id = Guid.NewGuid().ToString(),
            Name = string.IsNullOrWhiteSpace(name) ? email.Split('@')[0] : name,
            Email = email,
            Password = "oauth",
            Salt = "oauth",
            Base64Pfp = Convert.ToBase64String(Encoding.UTF8.GetBytes("oauth-avatar")),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
        });
    }

    private AuthResponseDTO CreateAndStoreSession(User user, string picture)
    {
        var expiryMinutes = _configuration.GetValue<int?>("Jwt:ExpiryMinutes") ?? 60;
        var expiresAt = DateTime.UtcNow.AddMinutes(expiryMinutes);
        var token = CreateJwtToken(user, expiresAt);

        var response = new AuthResponseDTO
        {
            Token = token,
            RefreshToken = Guid.NewGuid().ToString("N"),
            Expires = expiresAt,
            User = new OAuthUserDTO
            {
                Id = Math.Abs(user.Email.GetHashCode()),
                Username = user.Name,
                Email = user.Email,
                Role = "User",
                CreatedAt = user.CreatedAt,
                Picture = picture,
            }
        };

        Sessions[response.Token] = response;
        return response;
    }

    private string CreateJwtToken(User user, DateTime expiresAt)
    {
        var secretKey = _configuration["Jwt:SecretKey"] ?? throw new InvalidOperationException("Missing Jwt:SecretKey.");
        var issuer = _configuration["Jwt:Issuer"] ?? "MyProject.Api";
        var audience = _configuration["Jwt:Audience"] ?? "FlutterApp";

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, user.Id),
            new(JwtRegisteredClaimNames.Email, user.Email),
            new(JwtRegisteredClaimNames.UniqueName, user.Name),
            new(ClaimTypes.Role, "User"),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString("N"))
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            notBefore: DateTime.UtcNow,
            expires: expiresAt,
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private sealed class GitHubEmailResult
    {
        public string? Email { get; set; }
        public bool Primary { get; set; }
        public bool Verified { get; set; }
    }

}
