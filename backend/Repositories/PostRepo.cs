using Repositories.Context;
using Repositories.Interfaces;

namespace Repositories;

using Microsoft.EntityFrameworkCore;
using Models;


public class PostRepo : IPostRepo
{
    private readonly AppDBContext _dbContext;

    public PostRepo(AppDBContext dBContext)
    {
        _dbContext = dBContext;
    }

    /// <inheritdoc/>
    public async Task<List<Post>> GetAllPosts(string userId)
    {
        return await _dbContext.Posts.Where(post => post.OwnerId == userId).ToListAsync();
    }

    /// <inheritdoc/>
    public async Task<Post?> GetPost(string id)
    {
        var post = await _dbContext.Posts.FindAsync(id);
        if (post is null)
        {
            return null;
        }

        return post;
    }

    /// <inheritdoc/>
    public async Task<Post?> PostPost(Post newPost)
    {
        _dbContext.Posts.Add(newPost);
        try
        {
            await _dbContext.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            if (_dbContext.Users.Any(e => e.Id == newPost.Id))
            {
                return null;
            }
            else
            {
                throw;
            }
        }

        return newPost;
    }

    /// <inheritdoc/>
    public async Task<Post?> UpdatePost(Post newPost)
    {
        _dbContext.Entry(newPost).State = EntityState.Modified;

        try
        {
            await _dbContext.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!_dbContext.Posts.Any(e => e.Id == newPost.Id))
            {
                return null;
            }
            else
            {
                throw;
            }
        }

        return newPost;
    }

    /// <inheritdoc/>
    public async Task<bool> DeletePost(string PostId)
    {
        Post? post = await _dbContext.Posts.FindAsync(PostId);
        if (post == null)
        {
            return false;
        }

        _dbContext.Posts.Remove(post);
        await _dbContext.SaveChangesAsync();

        return true;
    }
}