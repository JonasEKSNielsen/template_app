using Microsoft.AspNetCore.Mvc;
using Services.Interfaces;
using Models;

namespace API.Controllers;

/// <summary>
/// Controller for managing messages in system.
/// </summary>
[Route("api/[controller]")]
[ApiController]
public class MessageController : ControllerBase
{
    private readonly IMessageService _messageService;

    public MessageController(IMessageService messageService)
    {
        _messageService = messageService;
    }

    /// <summary>
    /// Gets a message by ID.
    /// </summary>
    /// <param name="id">The unique identifier of the message.</param>
    /// <returns>The message with the specified ID.</returns>
    /// <response code="200">Returns the message.</response>
    /// <response code="404">If the message is not found.</response>
    [HttpGet("{id}")]
    public async Task<ActionResult<Message>> GetMessage(string id)
    {
        var message = await _messageService.GetMessageAsync(id);
        if (message == null)
        {
            return NotFound();
        }
        return Ok(message);
    }

    /// <summary>
    /// Gets all messages belonging to a specific chat.
    /// </summary>
    /// <param name="chatId">The unique identifier of the chat.</param>
    /// <returns>A list of messages in the specified chat.</returns>
    /// <response code="200">Returns the list of message.</response>
    [HttpGet("user/{userId}")]
    public async Task<ActionResult<List<Message>>> GetMessagesByChat(string chatId)
    {
        var messages = await _messageService.GetMessagesByChatAsync(chatId);
        return Ok(messages);
    }

    /// <summary>
    /// Sends a new message.
    /// </summary>
    /// <param name="message">The message to send.</param>
    /// <param name="userId">The sender of the message.</param>
    /// <param name="chatId">The chat to send the message in.</param>
    /// <returns>The newly created message.</returns>
    /// <response code="201">Returns the newly created message.</response>
    /// <response code="400">If the messagedata is invalid.</response>
    [HttpPost]
    public async Task<ActionResult<Chat>> CreateChat([FromBody] string message, [FromBody] string userId, [FromBody] string chatId)
    {
        var created = await _messageService.SendMessageAsync(message, userId, chatId);
        if (created == null)
        {
            return BadRequest();
        }
        return CreatedAtAction(nameof(GetMessage), new { id = created.Id }, created);
    }

    /// <summary>
    /// Updates an existing message.
    /// </summary>
    /// <param name="id">The unique identifier of the message to update.</param>
    /// <param name="message">The updated message data.</param>
    /// <returns>The updated message.</returns>
    /// <response code="200">Returns the updated message.</response>
    /// <response code="404">If the message is not found.</response>
    [HttpPut("{id}")]
    public async Task<ActionResult<Message>> UpdateMessage(string id, [FromBody] string userId, [FromBody] Message message)
    {
        var updated = await _messageService.UpdateMessageAsync(id, userId, message);
        if (updated == null)
        {
            return NotFound();
        }
        return Ok(updated);
    }

    /// <summary>
    /// Deletes a message.
    /// </summary>
    /// <param name="id">The unique identifier of the message to delete.</param>
    /// <response code="204">If the message was successfully deleted.</response>
    /// <response code="404">If the message is not found.</response>
    [HttpDelete("{id}")]
    public async Task<ActionResult> DeleteMessage(string id, string userId)
    {
        var deleted = await _messageService.DeleteMessageAsync(id, userId);
        if (!deleted)
        {
            return NotFound();
        }
        return NoContent();
    }
}
