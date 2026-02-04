namespace Repositories.Interfaces;
using Models;

public interface IUserRepo
{
    /// <summary>
    /// Gets User with given Id from table
    /// </summary>
    /// <param name="id">The id of the wanted User</param>
    /// <returns>User with given id, if not found returns null</returns>
    public Task<User?> GetUser(string id);

    /// <summary>
    /// Posts a new User to the table
    /// </summary>
    /// <param name="newUser">The new User that needs to be created</param>
    /// <returns>User that was added, null if it already exists, and throws exception if error occurs under creation</returns>
    public Task<User?> PostUser(User newUser);

    /// <summary>
    /// Gets all User in the table
    /// </summary>
    /// <returns>List of Users, empty list if none is found</returns>
    public Task<List<User>> GetAllUsers();

    /// <summary>
    /// Updates given User
    /// </summary>
    /// <param name="User">The new version of the User</param>
    /// <returns>The User that was updated, returns null if not succesfull</returns>
    public Task<User?> UpdateUser(User User);

    /// <summary>
    /// Delets User from table
    /// </summary>
    /// <param name="UserId">Id of the User needed to be deleted</param>
    /// <returns>Boolean, true if succesful and false if not</returns>
    public Task<bool> DeleteUser(string UserId);
}