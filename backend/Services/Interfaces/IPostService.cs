using Models;

namespace Services.Interfaces;

/// <summary>
/// Service interface for managing posts in system.
/// </summary>
public interface IPostService
{
    /// <summary>
    /// Gets an post by its unique identifier.
    /// </summary>
    /// <param name="id">The unique identifier of the post.</param>
    /// <returns>The post if found, otherwise null.</returns>
    Task<Post?> GetPostAsync(string id);

    /// <summary>
    /// Gets all posts with a specific user.
    /// </summary>
    /// <param name="userId">The unique identifier of the user type.</param>
    /// <returns>A list of posts matching with the specified user.</returns>
    Task<List<Post>> GetPostsByUserAsync(string userId);

    /// <summary>
    /// Creates a new post.
    /// </summary>
    /// <param name="post">The post data to create.</param>
    /// <returns>The newly created post if successful, otherwise null.</returns>
    Task<Post?> CreatePostAsync(Post post);

    /// <summary>
    /// Updates an existing post.
    /// </summary>
    /// <param name="id">The unique identifier of the post to update.</param>
    /// <param name="userId">The unique identifier of the post owner.</param>
    /// <param name="post">The updated post data.</param>
    /// <returns>The updated post if found, otherwise null.</returns>
    Task<Post?> UpdatePostAsync(string id, Post post);

    /// <summary>
    /// Deletes a post.
    /// </summary>
    /// <param name="id">The unique identifier of the post to update.</param>
    /// <param name="userId">The unique identifier of the post owner.</param>
    /// <returns>True if the post was deleted successfully, otherwise false.</returns>
    Task<bool> DeletePostAsync(string id);
}
