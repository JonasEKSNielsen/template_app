using System.Collections.Concurrent;
using System.IdentityModel.Tokens.Jwt;
using System.Net.Http.Headers;
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

        if (!string.Equals(dto.Provider, "Google", StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }

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

    public AuthResponseDTO? GetSession(string token)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            return null;
        }

        if (!Sessions.TryGetValue(token, out var session))
        {
            return null;
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

}
