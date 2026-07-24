namespace Rental.Domain.Constants
{
    public static class CommonTypes
    {
        public const string RoomStatus = "ROOM_STATUS";
        public const string ContractStatus = "CONTRACT_STATUS";
        public const string InvoiceStatus = "INVOICE_STATUS";
        public const string IncidentStatus = "INCIDENT_STATUS";
        public const string IncidentPriority = "INCIDENT_PRIORITY";
        public const string Gender = "GENDER";
        public const string TenantStatus = "TENANT_STATUS";
        public const string PaymentMethod = "PAYMENT_METHOD";
        public const string TransactionType = "TRANSACTION_TYPE";
    }

    public static class RoomStatus
    {
        public const string Empty = "EMPTY";
        public const string Rented = "RENTED";
        public const string Maintenance = "MAINTENANCE";
    }

    public static class ContractStatus
    {
        public const string Active = "ACTIVE";
        public const string Terminated = "TERMINATED";
        public const string Expired = "EXPIRED";
    }

    public static class InvoiceStatus
    {
        public const string Unpaid = "UNPAID";
        public const string Partial = "PARTIAL";
        public const string Paid = "PAID";
        public const string Overdue = "OVERDUE";
        public const string Cancelled = "CANCELLED";
    }

    public static class IncidentStatus
    {
        public const string Pending = "PENDING";
        public const string Resolved = "RESOLVED";
        public const string InProgress = "IN_PROGRESS";
    }

    public static class IncidentPriority
    {
        public const string Low = "LOW";
        public const string Medium = "MEDIUM";
        public const string High = "HIGH";
        public const string Critical = "CRITICAL";
    }

    public static class PaymentMethod
    {
        public const string Cash = "CASH";
        public const string BankTransfer = "BANK_TRANSFER";
        public const string Momo = "MOMO";
        public const string Vnpay = "VNPAY";
    }

    public static class TransactionTypes
    {
        public const string Contract = "CONTRACT";
        public const string Invoice = "INVOICE";
        public const string Payment = "PAYMENT";
        public const string Incident = "INCIDENT";
    }

    public static class FeeCalcMethod
    {
        public const string Fixed = "FIXED";
        public const string PerUnit = "PER_UNIT";
        public const string ByPerson = "BY_PERSON";
    }

    public static class SystemFeeNames
    {
        public const string Rent = "TIEN_PHONG";
        public const string Electricity = "TIEN_DIEN";
        public const string Water = "TIEN_NUOC";
        public const string Garbage = "PHI_RAC";
        public const string Wifi = "PHI_WIFI";
        public const string Parking = "PHI_XE";
    }

    public static class TenantStatusCodes
    {
        public const string Active = "ACTIVE";
        public const string Inactive = "INACTIVE";
        public const string Left = "LEFT";
    }
}
