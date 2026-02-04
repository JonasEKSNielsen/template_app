namespace Repositories.Interfaces;
using Models;

public interface IPostRepo
{
    /// <summary>
    /// Gets Post with given Id from table
    /// </summary>
    /// <param name="id">The id of the wanted Post</param>
    /// <returns>Post with given id, if not found returns null</returns>
    public Task<Post?> GetPost(string id);

    /// <summary>
    /// Posts a new Post to the table
    /// </summary>
    /// <param name="newPost">The new Post that needs to be created</param>
    /// <returns>Post that was added, null if it already exists, and throws exception if error occurs under creation</returns>
    public Task<Post?> PostPost(Post newPost);

    /// <summary>
    /// Gets all Post in the table related to user
    /// </summary>
    /// <param name="userId">The id of the user whos Posts are needed</param>
    /// <returns>List of Posts, empty list if none is found</returns>
    public Task<List<Post>> GetAllPosts(string userId);

    /// <summary>
    /// Updates given Post
    /// </summary>
    /// <param name="Post">The new version of the Post</param>
    /// <returns>The Post that was updated, returns null if not succesfull</returns>
    public Task<Post?> UpdatePost(Post Post);

    /// <summary>
    /// Delets Post from table
    /// </summary>
    /// <param name="PostId">Id of the Post needed to be deleted</param>
    /// <returns>Boolean, true if succesful and false if not</returns>
    public Task<bool> DeletePost(string PostId);
}