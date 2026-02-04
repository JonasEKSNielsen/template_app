using Models;

namespace Services.Interfaces;

/// <summary>
/// Service interface for managing chats in system.
/// </summary>
public interface IChatService
{
    /// <summary>
    /// Gets an chat by its unique identifier.
    /// </summary>
    /// <param name="id">The unique identifier of the chat.</param>
    /// <returns>The chat if found, otherwise null.</returns>
    Task<Chat?> GetChatAsync(string id);

    /// <summary>
    /// Gets all chats with a specific user.
    /// </summary>
    /// <param name="userId">The unique identifier of the user.</param>
    /// <returns>A list of chats matching with the specified user.</returns>
    Task<List<Chat>> GetChatsByUserAsync(string userId);

    /// <summary>
    /// Creates a new chat.
    /// </summary>
    /// <param name="chat">The chat data to create.</param>
    /// <returns>The newly created chat if successful, otherwise null.</returns>
    Task<Chat?> CreateChatAsync(Chat chat);

    /// <summary>
    /// Updates an existing chat.
    /// </summary>
    /// <param name="id">The unique identifier of the chat to update.</param>
    /// <param name="chat">The updated chat data.</param>
    /// <returns>The updated chat if found, otherwise null.</returns>
    Task<Chat?> UpdateChatAsync(string id, Chat chat);

    /// <summary>
    /// Deletes a chat.
    /// </summary>
    /// <param name="id">The unique identifier of the chat to delete.</param>
    /// <returns>True if the chat was deleted successfully, otherwise false.</returns>
    Task<bool> DeleteChatAsync(string id);
}
