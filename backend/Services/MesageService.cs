using Services.Interfaces;
using Models;
using Repositories.Interfaces;
using Models.DTOs;

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

    public async Task<Message?> SendMessageAsync(MessageDTO message)
    {
        Message newMessage = new Message()
        {
            Id = Guid.NewGuid().ToString(),
            ChatId = message.ChatId,
            OwnerId = message.UserId,
            Content = message.Message,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
        };

        return await _messageRepo.PostMessage(newMessage);
    }

    public async Task<Message?> UpdateMessageAsync(string id, Message message)
    {
        var existing = await _messageRepo.GetMessage(id);
        if (existing == null) return null;

        existing.Content = message.Content;
        existing.UpdatedAt = DateTime.UtcNow;

        return await _messageRepo.UpdateMessage(existing);
    }

    public async Task<bool> DeleteMessageAsync(string id)
    {
        Message? messageToBeDeleted = await _messageRepo.GetMessage(id);
        if (messageToBeDeleted == null)
            return false;

        return await _messageRepo.DeleteMessage(id);
    }
}
