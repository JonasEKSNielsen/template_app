namespace Repositories.Interfaces;
using Models;

public interface IChatRepo
{
    /// <summary>
    /// Gets Chat with given Id from table
    /// </summary>
    /// <param name="id">The id of the wanted Chat</param>
    /// <returns>Chat with given id, if not found returns null</returns>
    public Task<Chat?> GetChat(string id);

    /// <summary>
    /// Posts a new Chat to the table
    /// </summary>
    /// <param name="newChat">The new Chatthat needs to be created</param>
    /// <returns>Chat that was added, null if it already exists, and throws exception if error occurs under creation</returns>
    public Task<Chat?> PostChat(Chat newChat);

    /// <summary>
    /// Gets all Chat in the table related to user
    /// </summary>
    /// <param name="userId">The id of the user whos chats are needed</param>
    /// <returns>List of Chats, empty list if none is found</returns>
    public Task<List<Chat>> GetAllChats(string userId);

    /// <summary>
    /// Updates given Chat
    /// </summary>
    /// <param name="Chat">The new version of the Chat</param>
    /// <returns>The Chat that was updated, returns null if not succesfull</returns>
    public Task<Chat?> UpdateChat(Chat Chat);

    /// <summary>
    /// Delets Chat from table
    /// </summary>
    /// <param name="ChatId">Id of the Chat needed to be deleted</param>
    /// <returns>Boolean, true if succesful and false if not</returns>
    public Task<bool> DeleteChat(string ChatId);
}