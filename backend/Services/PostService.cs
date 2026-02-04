using Services.Interfaces;
using Models;
using Repositories.Interfaces;

namespace Services;

public class PostService : IPostService
{
    private readonly IPostRepo _postRepo;

    public PostService(IPostRepo postRepo)
    {
        _postRepo = postRepo;
    }

    public async Task<Post?> GetPostAsync(string id)
    {
        return await _postRepo.GetPost(id);
    }

    public async Task<List<Post>> GetPostsByUserAsync(string userId)
    {
        return await _postRepo.GetAllPosts(userId);
    }

    public async Task<Post?> CreatePostAsync(Post post)
    {
        post.Id = Guid.NewGuid().ToString();
        post.CreatedAt = DateTime.UtcNow;
        post.UpdatedAt = DateTime.UtcNow;
        return await _postRepo.PostPost(post);
    }

    public async Task<Post?> UpdatePostAsync(string id, Post post)
    {
        var existing = await _postRepo.GetPost(id);
        if (existing == null) return null;

        existing.Content = post.Content;
        existing.UpdatedAt = DateTime.UtcNow;

        return await _postRepo.UpdatePost(existing);
    }

    public async Task<bool> DeletePostAsync(string id)
    {
        Post? postToBeDeleted = await _postRepo.GetPost(id);
        if (postToBeDeleted == null)
            return false;

        return await _postRepo.DeletePost(id);
    }
}
