using Serilog;
using Serilog.Events;
using Microsoft.Extensions.Hosting;

namespace Rental.Logging
{
    /// <summary>
    /// Cấu hình Serilog cho hệ thống.
    /// </summary>
    public static class SerilogConfiguration
    {
        public static void Configure(HostBuilderContext context, LoggerConfiguration loggerConfiguration)
        {
            loggerConfiguration
                .MinimumLevel.Information()
                .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
                .Enrich.FromLogContext()
                .WriteTo.Console()
                .WriteTo.File("logs/rental-.txt", rollingInterval: RollingInterval.Day);
        }
    }
}
