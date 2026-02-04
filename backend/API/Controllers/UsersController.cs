using Microsoft.AspNetCore.Mvc;
using Services.Interfaces;
using Models.DTOs;

namespace API.Controllers;

[Route("api/[controller]")]
[ApiController]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;
    
    public UsersController(IUserService userService)
    {
        _userService = userService;
    }
    
    
    
    [HttpGet("{id}")]
    public async Task<ActionResult<UserDTO>> GetUser(string id)
    {
        var user = await _userService.GetUser(id);
        if (user == null) return NotFound();

        return Ok(user);
    }
}