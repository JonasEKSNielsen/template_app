using Repositories.Context;
using Repositories.Interfaces;

namespace Repositories;

using Microsoft.EntityFrameworkCore;
using Models;


public class ChatRepo : IChatRepo
{
    private readonly AppDBContext _dbContext;

    public ChatRepo(AppDBContext dBContext)
    {
        _dbContext = dBContext;
    }

    /// <inheritdoc/>
    public async Task<List<Chat>> GetAllChats(string userId)
    {
        return await _dbContext.Chats.Where(chat => chat.ChatUsers != null && chat.ChatUsers.Any(users => users.UserId == userId)).ToListAsync();
    }

    /// <inheritdoc/>
    public async Task<Chat?> GetChat(string id)
    {
        var chat = await _dbContext.Chats.FindAsync(id);
        if (chat is null)
        {
            return null;
        }

        return chat;
    }

    /// <inheritdoc/>
    public async Task<Chat?> PostChat(Chat newChat)
    {
        _dbContext.Chats.Add(newChat);
        try
        {
            await _dbContext.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            if (_dbContext.Chats.Any(e => e.Id == newChat.Id))
            {
                return null;
            }
            else
            {
                throw;
            }
        }

        return newChat;
    }

    /// <inheritdoc/>
    public async Task<Chat?> UpdateChat(Chat newChat)
    {
        _dbContext.Entry(newChat).State = EntityState.Modified;

        try
        {
            await _dbContext.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!_dbContext.Chats.Any(e => e.Id == newChat.Id))
            {
                return null;
            }
            else
            {
                throw;
            }
        }

        return newChat;
    }

    /// <inheritdoc/>
    public async Task<bool> DeleteChat(string ChatId)
    {
        Chat? chat = await _dbContext.Chats.FindAsync(ChatId);
        if (chat == null)
        {
            return false;
        }

        _dbContext.Chats.Remove(chat);
        await _dbContext.SaveChangesAsync();

        return true;
    }
}