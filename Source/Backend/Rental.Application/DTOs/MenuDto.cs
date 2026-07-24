using System.Collections.Generic;

namespace Rental.Application.DTOs
{
    public class MenuItemDto
    {
        public string Code { get; set; }
        public string Name { get; set; }
        public string Icon { get; set; }
        public string Route { get; set; }
        public int SortOrder { get; set; }
    }
}
