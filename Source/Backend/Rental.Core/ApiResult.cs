using System.Collections.Generic;

namespace Rental.Core
{
    public interface IPagedResult
    {
        int TotalCount { get; }
        int PageNumber { get; }
        int PageSize { get; }
        int TotalPages { get; }
        bool HasPreviousPage { get; }
        bool HasNextPage { get; }
        int FirstItemIndex { get; }
        int LastItemIndex { get; }
    }

    public class ApiResult<T>
    {
        /// <summary>
        /// Trạng thái thành công hay thất bại.
        /// </summary>
        public bool IsSuccess { get; set; }

        /// <summary>
        /// Thông báo đi kèm.
        /// </summary>
        public string Message { get; set; }

        /// <summary>
        /// Dữ liệu trả về.
        /// </summary>
        public T Data { get; set; }

        /// <summary>
        /// Danh sách các lỗi (nếu có).
        /// </summary>
        public List<string> Errors { get; set; } = new List<string>();

        /// <summary>
        /// Mã trạng thái HTTP hoặc mã lỗi nội bộ.
        /// </summary>
        public int StatusCode { get; set; }

        public static ApiResult<T> Success(T data, string message = "Success")
        {
            return new ApiResult<T> { IsSuccess = true, Data = data, Message = message, StatusCode = 200 };
        }

        public static ApiResult<T> Failure(string message, List<string> errors = null, int statusCode = 400)
        {
            return new ApiResult<T> { IsSuccess = false, Message = message, Errors = errors ?? new List<string>(), StatusCode = statusCode };
        }
    }

    /// <summary>
    /// Kết quả trả về cho các truy vấn phân trang.
    /// </summary>
    public class PagedResult<T> : IPagedResult
    {
        public List<T> Items { get; set; } = new();
        public int TotalCount { get; set; }
        public int PageNumber { get; set; }
        public int PageSize { get; set; }
        public int TotalPages => (int)System.Math.Ceiling((double)TotalCount / PageSize);
        public bool HasPreviousPage => PageNumber > 1;
        public bool HasNextPage => PageNumber < TotalPages;
        public int FirstItemIndex => (PageNumber - 1) * PageSize + 1;
        public int LastItemIndex => Math.Min(PageNumber * PageSize, TotalCount);
    }
}
