using Services.Interfaces;
using Models;
using Repositories.Interfaces;
using Models.DTOs;

namespace Services;

public class UserService : IUserService
{
    private readonly IUserRepo _userRepo;

    public UserService(IUserRepo userRepo)
    {
        _userRepo = userRepo;
    }
    public async Task<UserDTO?> GetUser(string id)
    {
        var user = await _userRepo.GetUser(id);
        if (user == null) return null;

        return new UserDTO
        {
            Id = user.Id,
            Name = user.Name,
            Email = user.Email,
            Base64Pfp = user.Base64Pfp
        };
    }
}