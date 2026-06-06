using System.Collections.Generic;

namespace Rental.Core
{
    /// <summary>
    /// Kết quả trả về chuẩn cho API.
    /// </summary>
    /// <typeparam name="T">Kiểu dữ liệu của nội dung trả về.</typeparam>
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
    /// <typeparam name="T">Kiểu dữ liệu của danh sách.</typeparam>
    public class PagedResult<T>
    {
        /// <summary>
        /// Danh sách dữ liệu trang hiện tại.
        /// </summary>
        public List<T> Items { get; set; } = new List<T>();

        /// <summary>
        /// Tổng số bản ghi thỏa mãn điều kiện.
        /// </summary>
        public int TotalCount { get; set; }

        /// <summary>
        /// Trang hiện tại.
        /// </summary>
        public int PageNumber { get; set; }

        /// <summary>
        /// Số bản ghi trên mỗi trang.
        /// </summary>
        public int PageSize { get; set; }

        /// <summary>
        /// Tổng số trang.
        /// </summary>
        public int TotalPages => (int)System.Math.Ceiling((double)TotalCount / PageSize);
    }
}
