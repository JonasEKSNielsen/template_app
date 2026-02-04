using Models;
using Models.DTOs;

namespace Services.Interfaces;

public interface IUserService
{
    /// <summary>
    /// Gets an user by its unique identifier.
    /// </summary>
    /// <param name="id">The unique identifier of the user.</param>
    /// <returns>The user if found, otherwise null.</returns>
    public Task<UserDTO?> GetUser(string id);
}