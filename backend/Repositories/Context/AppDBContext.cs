using Microsoft.EntityFrameworkCore;
using Models;

namespace Repositories.Context
{
    public class AppDBContext : DbContext
    {
        public AppDBContext(DbContextOptions<AppDBContext> options)
            : base(options)
        {
        }
        public DbSet<Chat> Chats { get; set; } = default!;
        public DbSet<Message> Messages { get; set; } = default!;
        public DbSet<Post> Posts { get; set; } = default!;
        public DbSet<User> Users { get; set; } = default!;
        public DbSet<UserChatConvo> UserChatConvos { get; set; } = default!;
        public DbSet<UserPostLiked> UserPostLikeds { get; set; } = default!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<UserChatConvo>()
                .HasKey(x => new { x.UserId, x.ChatId });

            modelBuilder.Entity<UserChatConvo>()
                .HasOne(x => x.User)
                .WithMany(u => u.Chats)
                .HasForeignKey(x => x.UserId);

            modelBuilder.Entity<UserChatConvo>()
                .HasOne(x => x.Chat)
                .WithMany(c => c.ChatUsers)
                .HasForeignKey(x => x.ChatId);

            modelBuilder.Entity<UserPostLiked>()
                .HasKey(x => new { x.UserId, x.PostId });

            modelBuilder.Entity<UserPostLiked>()
                .HasOne(x => x.User)
                .WithMany(u => u.Liked)
                .HasForeignKey(x => x.UserId);

            modelBuilder.Entity<UserPostLiked>()
                .HasOne(x => x.Post)
                .WithMany(c => c.Likes)
                .HasForeignKey(x => x.PostId);
        }

        public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            foreach (var entry in ChangeTracker.Entries<Common>())
            {
                if (entry.State == EntityState.Added)
                {
                    entry.Entity.CreatedAt = DateTime.UtcNow;
                    entry.Entity.UpdatedAt = DateTime.UtcNow;
                }

                if (entry.State == EntityState.Modified)
                {
                    entry.Property(x => x.CreatedAt).IsModified = false;
                    entry.Entity.UpdatedAt = DateTime.UtcNow;
                }
            }

            return base.SaveChangesAsync(cancellationToken);
        }
    }
}
