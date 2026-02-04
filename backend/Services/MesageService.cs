using Services.Interfaces;
using Models;
using Repositories.Interfaces;

namespace Services;

public class MessageService : IMessageService
{
    private readonly IMessageRepo _messageRepo;

    public MessageService(IMessageRepo messageRepo)
    {
        _messageRepo = messageRepo;
    }

    public async Task<Message?> GetMessageAsync(string id)
    {
        return await _messageRepo.GetMessage(id);
    }

    public async Task<List<Message>> GetMessagesByChatAsync(string chatId)
    {
        return await _messageRepo.GetAllMessagesInChat(chatId);
    }

    public async Task<Message?> SendMessageAsync(string message, string userId, string chatId)
    {
        Message newMessage = new Message()
        {
            Id = Guid.NewGuid().ToString(),
            ChatId = chatId,
            OwnerId = userId,
            Content = message,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
        };

        return await _messageRepo.PostMessage(newMessage);
    }

    public async Task<Message?> UpdateMessageAsync(string id, string userId, Message message)
    {
        var existing = await _messageRepo.GetMessage(id);
        if (existing == null) return null;
        if (existing.OwnerId != userId) return null;

        existing.Content = message.Content;
        existing.UpdatedAt = DateTime.UtcNow;

        return await _messageRepo.UpdateMessage(existing);
    }

    public async Task<bool> DeleteMessageAsync(string id, string userId)
    {
        Message? messageToBeDeleted = await _messageRepo.GetMessage(id);
        if (messageToBeDeleted == null)
            return false;

        if (messageToBeDeleted.OwnerId != userId)
            return false;

        return await _messageRepo.DeleteMessage(id);
    }
}
