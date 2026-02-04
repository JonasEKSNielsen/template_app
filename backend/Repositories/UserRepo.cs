using Repositories.Context;
using Repositories.Interfaces;

namespace Repositories;

using Microsoft.EntityFrameworkCore;
using Models;


public class UserRepo : IUserRepo
{
    private readonly AppDBContext _dbContext;

    public UserRepo(AppDBContext dBContext)
    {
        _dbContext = dBContext;
    }

    /// <inheritdoc/>
    public async Task<List<User>> GetAllUsers()
    {
        return await _dbContext.Users.ToListAsync();
    }

    /// <inheritdoc/>
    public async Task<User?> GetUser(string id)
    {
        var user = await _dbContext.Users.FindAsync(id);
        if (user is null)
        {
            return null;
        }

        return user;
    }

    /// <inheritdoc/>
    public async Task<User?> PostUser(User newUser)
    {
        _dbContext.Users.Add(newUser);
        try
        {
            await _dbContext.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            if (_dbContext.Users.Any(e => e.Id == newUser.Id))
            {
                return null;
            }
            else
            {
                throw;
            }
        }

        return newUser;
    }

    /// <inheritdoc/>
    public async Task<User?> UpdateUser(User newUser)
    {
        _dbContext.Entry(newUser).State = EntityState.Modified;

        try
        {
            await _dbContext.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!_dbContext.Users.Any(e => e.Id == newUser.Id))
            {
                return null;
            }
            else
            {
                throw;
            }
        }

        return newUser;
    }

    /// <inheritdoc/>
    public async Task<bool> DeleteUser(string UserId)
    {
        User? user = await _dbContext.Users.FindAsync(UserId);
        if (user == null)
        {
            return false;
        }

        _dbContext.Users.Remove(user);
        await _dbContext.SaveChangesAsync();

        return true;
    }
}