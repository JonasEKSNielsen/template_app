namespace Repositories.Interfaces;
using Models;

public interface IMessageRepo
{
    /// <summary>
    /// Gets Message with given Id from table
    /// </summary>
    /// <param name="id">The id of the wanted Message</param>
    /// <returns>Message with given id, if not found returns null</returns>
    public Task<Message?> GetMessage(string id);

    /// <summary>
    /// Posts a new Message to the table
    /// </summary>
    /// <param name="newMessage">The new Message that needs to be created</param>
    /// <returns>Message that was added, null if it already exists, and throws exception if error occurs under creation</returns>
    public Task<Message?> PostMessage(Message newMessage);

    /// <summary>
    /// Gets all Messages in the table related to given chat
    /// </summary>
    /// <param name="chatId">The id of the chat where Messages need to be pulled from</param>
    /// <returns>List of Messages, empty list if none is found</returns>
    public Task<List<Message>> GetAllMessagesInChat(string chatId);

    /// <summary>
    /// Updates given Message
    /// </summary>
    /// <param name="Message">The new version of the Message</param>
    /// <returns>The Message that was updated, returns null if not succesfull</returns>
    public Task<Message?> UpdateMessage(Message Message);

    /// <summary>
    /// Delets Message from table
    /// </summary>
    /// <param name="MessageId">Id of the Message needed to be deleted</param>
    /// <returns>Boolean, true if succesful and false if not</returns>
    public Task<bool> DeleteMessage(string MessageId);
}