using Microsoft.AspNetCore.Mvc;
using Services.Interfaces;
using Models;

namespace API.Controllers;

/// <summary>
/// Controller for managing posts in system.
/// </summary>
[Route("api/[controller]")]
[ApiController]
public class PostController : ControllerBase
{
    private readonly IPostService _postService;

    public PostController(IPostService postService)
    {
        _postService = postService;
    }

    /// <summary>
    /// Gets a post by ID.
    /// </summary>
    /// <param name="id">The unique identifier of the post.</param>
    /// <returns>The post with the specified ID.</returns>
    /// <response code="200">Returns the post.</response>
    /// <response code="404">If the post is not found.</response>
    [HttpGet("{id}")]
    public async Task<ActionResult<Post>> GetPost(string id)
    {
        var post = await _postService.GetPostAsync(id);
        if (post == null)
        {
            return NotFound();
        }
        return Ok(post);
    }

    /// <summary>
    /// Gets all posts belonging to a specific user.
    /// </summary>
    /// <param name="userId">The unique identifier of the user.</param>
    /// <returns>A list of posts owned by the specified user.</returns>
    /// <response code="200">Returns the list of posts.</response>
    [HttpGet("user/{userId}")]
    public async Task<ActionResult<List<Post>>> GetPostsByUser(string userId)
    {
        var posts = await _postService.GetPostsByUserAsync(userId);
        return Ok(posts);
    }

    /// <summary>
    /// Creates a new posts.
    /// </summary>
    /// <param name="post">The post data to create.</param>
    /// <returns>The newly created post.</returns>
    /// <response code="201">Returns the newly created post.</response>
    /// <response code="400">If the post data is invalid.</response>
    [HttpPost]
    public async Task<ActionResult<Post>> CreatePost([FromBody] Post post)
    {
        var created = await _postService.CreatePostAsync(post);
        if (created == null)
        {
            return BadRequest();
        }
        return CreatedAtAction(nameof(GetPost), new { id = created.Id }, created);
    }

    /// <summary>
    /// Updates an existing post.
    /// </summary>
    /// <param name="id">The unique identifier of the post to update.</param>
    /// <param name="userId">The unique identifier for the owner of the post.</param>
    /// <param name="post">The updated post data.</param>
    /// <returns>The updated post.</returns>
    /// <response code="200">Returns the updated post.</response>
    /// <response code="404">If the post is not found.</response>
    [HttpPut("{id}")]
    public async Task<ActionResult<Post>> UpdatePost(string id, [FromBody] string userId, [FromBody] Post post)
    {
        var updated = await _postService.UpdatePostAsync(id, userId, post);
        if (updated == null)
        {
            return NotFound();
        }
        return Ok(updated);
    }

    /// <summary>
    /// Deletes a post.
    /// </summary>
    /// <param name="id">The unique identifier of the post to delete.</param>
    /// <param name="userId">The unique identifier for the owner of the post.</param>
    /// <response code="204">If the post was successfully deleted.</response>
    /// <response code="404">If the post is not found.</response>
    [HttpDelete("{id}")]
    public async Task<ActionResult> DeletePost(string id, [FromBody] string userId)
    {
        var deleted = await _postService.DeletePostAsync(id, userId);
        if (!deleted)
        {
            return NotFound();
        }
        return NoContent();
    }
}
