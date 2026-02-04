using Repositories.Context;
using Repositories.Interfaces;

namespace Repositories;

using Microsoft.EntityFrameworkCore;
using Models;


public class MessageRepo : IMessageRepo
{
    private readonly AppDBContext _dbContext;

    public MessageRepo(AppDBContext dBContext)
    {
        _dbContext = dBContext;
    }

    /// <inheritdoc/>
    public async Task<List<Message>> GetAllMessagesInChat(string chatId)
    {
        return await _dbContext.Messages.Where(message => message.ChatId == chatId).ToListAsync();
    }

    /// <inheritdoc/>
    public async Task<Message?> GetMessage(string id)
    {
        var message = await _dbContext.Messages.FindAsync(id);
        if (message is null)
        {
            return null;
        }

        return message;
    }

    /// <inheritdoc/>
    public async Task<Message?> PostMessage(Message newMessage)
    {
        _dbContext.Messages.Add(newMessage);
        try
        {
            await _dbContext.SaveChangesAsync();
        }
        catch (DbUpdateException)
        {
            if (_dbContext.Messages.Any(e => e.Id == newMessage.Id))
            {
                return null;
            }
            else
            {
                throw;
            }
        }

        return newMessage;
    }

    /// <inheritdoc/>
    public async Task<Message?> UpdateMessage(Message newMessage)
    {
        _dbContext.Entry(newMessage).State = EntityState.Modified;

        try
        {
            await _dbContext.SaveChangesAsync();
        }
        catch (DbUpdateConcurrencyException)
        {
            if (!_dbContext.Messages.Any(e => e.Id == newMessage.Id))
            {
                return null;
            }
            else
            {
                throw;
            }
        }

        return newMessage;
    }

    /// <inheritdoc/>
    public async Task<bool> DeleteMessage(string MessageId)
    {
        Message? message = await _dbContext.Messages.FindAsync(MessageId);
        if (message == null)
        {
            return false;
        }

        _dbContext.Messages.Remove(message);
        await _dbContext.SaveChangesAsync();

        return true;
    }
}