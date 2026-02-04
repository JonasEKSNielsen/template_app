using Microsoft.AspNetCore.Mvc;
using Services.Interfaces;
using Models;

namespace API.Controllers;

/// <summary>
/// Controller for managing chats in system.
/// </summary>
[Route("api/[controller]")]
[ApiController]
public class ChatController : ControllerBase
{
    private readonly IChatService _chatService;

    public ChatController(IChatService chatService)
    {
        _chatService = chatService;
    }

    /// <summary>
    /// Gets a Chat by ID.
    /// </summary>
    /// <param name="id">The unique identifier of the chat.</param>
    /// <returns>The chat with the specified ID.</returns>
    /// <response code="200">Returns the chat.</response>
    /// <response code="404">If the chat is not found.</response>
    [HttpGet("{id}")]
    public async Task<ActionResult<Chat>> GetChat(string id)
    {
        var chat = await _chatService.GetChatAsync(id);
        if (chat == null)
        {
            return NotFound();
        }
        return Ok(chat);
    }

    /// <summary>
    /// Gets all chats belonging to a specific user.
    /// </summary>
    /// <param name="userId">The unique identifier of the user.</param>
    /// <returns>A list of chats owned by the specified user.</returns>
    /// <response code="200">Returns the list of chats.</response>
    [HttpGet("user/{userId}")]
    public async Task<ActionResult<List<Chat>>> GetChatsByUser(string userId)
    {
        var chats = await _chatService.GetChatsByUserAsync(userId);
        return Ok(chats);
    }

    /// <summary>
    /// Creates a new chat.
    /// </summary>
    /// <param name="chat">The chat data to create.</param>
    /// <returns>The newly created chat.</returns>
    /// <response code="201">Returns the newly created chat.</response>
    /// <response code="400">If the chat data is invalid.</response>
    [HttpPost]
    public async Task<ActionResult<Chat>> CreateChat([FromBody] Chat chat)
    {
        var created = await _chatService.CreateChatAsync(chat);
        if (created == null)
        {
            return BadRequest();
        }
        return CreatedAtAction(nameof(GetChat), new { id = created.Id }, created);
    }

    /// <summary>
    /// Updates an existing chat.
    /// </summary>
    /// <param name="id">The unique identifier of the chat to update.</param>
    /// <param name="chat">The updated chat data.</param>
    /// <returns>The updated chat.</returns>
    /// <response code="200">Returns the updated chat.</response>
    /// <response code="404">If the chat is not found.</response>
    [HttpPut("{id}")]
    public async Task<ActionResult<Chat>> UpdateChat(string id, [FromBody] Chat chat)
    {
        var updated = await _chatService.UpdateChatAsync(id, chat);
        if (updated == null)
        {
            return NotFound();
        }
        return Ok(updated);
    }

    /// <summary>
    /// Deletes a chat.
    /// </summary>
    /// <param name="id">The unique identifier of the chat to delete.</param>
    /// <response code="204">If the chat was successfully deleted.</response>
    /// <response code="404">If the chat is not found.</response>
    [HttpDelete("{id}")]
    public async Task<ActionResult> DeleteChat(string id)
    {
        var deleted = await _chatService.DeleteChatAsync(id);
        if (!deleted)
        {
            return NotFound();
        }
        return NoContent();
    }
}
