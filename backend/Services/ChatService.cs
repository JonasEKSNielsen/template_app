using Services.Interfaces;
using Models;
using Repositories.Interfaces;

namespace Services;

public class ChatService : IChatService
{
    private readonly IChatRepo _chatRepo;

    public ChatService(IChatRepo chatRepo)
    {
        _chatRepo = chatRepo;
    }

    public async Task<Chat?> GetChatAsync(string id)
    {
        return await _chatRepo.GetChat(id);
    }

    public async Task<List<Chat>> GetChatsByUserAsync(string userId)
    {
        return await _chatRepo.GetAllChats(userId);
    }

    public async Task<Chat?> CreateChatAsync(Chat chat)
    {
        chat.Id = Guid.NewGuid().ToString();
        chat.CreatedAt = DateTime.UtcNow;
        chat.UpdatedAt = DateTime.UtcNow;
        return await _chatRepo.PostChat(chat);
    }

    public async Task<Chat?> UpdateChatAsync(string id, Chat chat)
    {
        var existing = await _chatRepo.GetChat(id);
        if (existing == null) return null;

        existing.Title = chat.Title;
        existing.UpdatedAt = DateTime.UtcNow;

        return await _chatRepo.UpdateChat(existing);
    }

    public async Task<bool> DeleteChatAsync(string id)
    {
        return await _chatRepo.DeleteChat(id);
    }
}
