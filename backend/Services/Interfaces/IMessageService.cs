using Models;

namespace Services.Interfaces;

/// <summary>
/// Service interface for managing messages in system.
/// </summary>
public interface IMessageService
{
    /// <summary>
    /// Gets a message by its unique identifier.
    /// </summary>
    /// <param name="id">The unique identifier of the message.</param>
    /// <returns>The message if found, otherwise null.</returns>
    Task<Message?> GetMessageAsync(string id);

    /// <summary>
    /// Gets all message from a specific chat.
    /// </summary>
    /// <param name="chatId">The unique identifier of the chat.</param>
    /// <returns>A list of message matching with the specified user.</returns>
    Task<List<Message>> GetMessagesByChatAsync(string chatId);

    /// <summary>
    /// Creates a new message.
    /// </summary>
    /// <param name="message">The message data needed to be sent.</param>
    /// <param name="userId">The unique identifier for sender of the message.</param>
    /// <param name="chatId">The unique identifier for the chat where message is to be sent.</param>
    /// <returns>The newly created message if successful, otherwise null.</returns>
    Task<Message?> SendMessageAsync(string message, string userId, string chatId);

    /// <summary>
    /// Updates an existing message.
    /// </summary>
    /// <param name="id">The unique identifier of the message to update.</param>
    /// <param name="message">The updated message data.</param>
    /// <returns>The updated message if found, otherwise null.</returns>
    Task<Message?> UpdateMessageAsync(string id, string userId, Message message);

    /// <summary>
    /// Deletes a message.
    /// </summary>
    /// <param name="id">The unique identifier of the message to delete.</param>
    /// <param name="userId">The unique identifier of the owner of the message.</param>
    /// <returns>True if the message was deleted successfully, otherwise false.</returns>
    Task<bool> DeleteMessageAsync(string id, string userId);
}
