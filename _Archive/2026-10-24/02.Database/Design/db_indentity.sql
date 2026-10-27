-- =========================
-- DATABASE: rental_management
-- =========================

-- USERS & AUTH
CREATE TABLE Users (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Username VARCHAR(100) UNIQUE NOT NULL,
    PasswordHash TEXT NOT NULL,
    TenantId INT,
    IsActive BOOLEAN DEFAULT TRUE
);

CREATE TABLE Roles (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name VARCHAR(50) NOT NULL
);

CREATE TABLE UserRoles (
    UserId INT,
    RoleId INT,
    PRIMARY KEY (UserId, RoleId)
);

CREATE TABLE Permissions (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Code VARCHAR(100) UNIQUE NOT NULL,
    Name VARCHAR(255)
);

CREATE TABLE RolePermissions (
    RoleId INT,
    PermissionId INT,
    PRIMARY KEY (RoleId, PermissionId)
);

-- MENU
CREATE TABLE Menus (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name VARCHAR(100),
    Path VARCHAR(255),
    Icon VARCHAR(100),
    ParentId INT,
    OrderIndex INT
);

CREATE TABLE MenuPermissions (
    MenuId INT,
    PermissionId INT,
    PRIMARY KEY (MenuId, PermissionId)
);

-- COMMON DATA
CREATE TABLE CommonCategories (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Code VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE CommonValues (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CategoryId INT,
    Code VARCHAR(100),
    Value VARCHAR(255),
    OrderIndex INT
);

CREATE TABLE CommonTranslations (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CommonValueId INT,
    LanguageCode VARCHAR(10),
    Value VARCHAR(255)
);

-- LANGUAGES
CREATE TABLE Languages (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Code VARCHAR(10),
    Name VARCHAR(50)
);

CREATE TABLE Translations (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Key VARCHAR(255),
    LanguageCode VARCHAR(10),
    Value TEXT
);

-- RENTAL DOMAIN

-- ROOMS
CREATE TABLE Rooms (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    RoomNumber VARCHAR(50),
    Price NUMERIC(12,2),
    MaxOccupants INT,
    StatusCode VARCHAR(50),
    Description TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE RoomImages (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    RoomId INT,
    ImageUrl TEXT
);

-- TENANTS
CREATE TABLE Tenants (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    FullName VARCHAR(255),
    Email VARCHAR(255),
    Phone VARCHAR(50),
    CCCD VARCHAR(50),
    GenderCode VARCHAR(50),
    DateOfBirth DATE,
    Address TEXT,
    AvatarUrl TEXT,
    CCCDImageUrl TEXT,
    StatusCode VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- CONTRACTS
CREATE TABLE Contracts (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    RoomId INT,
    TenantId INT,
    StartDate DATE,
    EndDate DATE,
    Deposit NUMERIC(12,2),
    RentPrice NUMERIC(12,2),
    StatusCode VARCHAR(50)
);

-- UTILITY
CREATE TABLE UtilityRecords (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    RoomId INT,
    Month VARCHAR(7),
    ElectricOld INT,
    ElectricNew INT,
    WaterOld INT,
    WaterNew INT
);

-- FEES
CREATE TABLE FeeTypes (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Code VARCHAR(50),
    Name VARCHAR(100),
    CalculationType VARCHAR(50),
    UnitPrice NUMERIC(12,2)
);

-- INVOICES
CREATE TABLE Invoices (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    RoomId INT,
    ContractId INT,
    Month VARCHAR(7),
    TotalAmount NUMERIC(12,2),
    Status VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PaidAt TIMESTAMP
);

CREATE TABLE InvoiceDetails (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    InvoiceId INT,
    FeeTypeId INT,
    Quantity NUMERIC(12,2),
    UnitPrice NUMERIC(12,2),
    Amount NUMERIC(12,2)
);

-- PAYMENTS
CREATE TABLE Payments (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    InvoiceId INT,
    Amount NUMERIC(12,2),
    PaymentDate TIMESTAMP,
    Method VARCHAR(50)
);

-- MAINTENANCE
CREATE TABLE Maintenances (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    RoomId INT,
    Description TEXT,
    StatusCode VARCHAR(50),
    Cost NUMERIC(12,2),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ResolvedAt TIMESTAMP
);

-- NOTIFICATIONS
CREATE TABLE Notifications (
    Id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Title VARCHAR(255),
    Content TEXT,
    UserId INT,
    IsRead BOOLEAN DEFAULT FALSE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- FOREIGN KEYS
-- =========================

ALTER TABLE Users ADD FOREIGN KEY (TenantId) REFERENCES Tenants(Id);

ALTER TABLE UserRoles ADD FOREIGN KEY (UserId) REFERENCES Users(Id);
ALTER TABLE UserRoles ADD FOREIGN KEY (RoleId) REFERENCES Roles(Id);

ALTER TABLE RolePermissions ADD FOREIGN KEY (RoleId) REFERENCES Roles(Id);
ALTER TABLE RolePermissions ADD FOREIGN KEY (PermissionId) REFERENCES Permissions(Id);

ALTER TABLE MenuPermissions ADD FOREIGN KEY (MenuId) REFERENCES Menus(Id);
ALTER TABLE MenuPermissions ADD FOREIGN KEY (PermissionId) REFERENCES Permissions(Id);

ALTER TABLE CommonValues ADD FOREIGN KEY (CategoryId) REFERENCES CommonCategories(Id);
ALTER TABLE CommonTranslations ADD FOREIGN KEY (CommonValueId) REFERENCES CommonValues(Id);

ALTER TABLE RoomImages ADD FOREIGN KEY (RoomId) REFERENCES Rooms(Id);

ALTER TABLE Contracts ADD FOREIGN KEY (RoomId) REFERENCES Rooms(Id);
ALTER TABLE Contracts ADD FOREIGN KEY (TenantId) REFERENCES Tenants(Id);

ALTER TABLE UtilityRecords ADD FOREIGN KEY (RoomId) REFERENCES Rooms(Id);

ALTER TABLE Invoices ADD FOREIGN KEY (RoomId) REFERENCES Rooms(Id);
ALTER TABLE Invoices ADD FOREIGN KEY (ContractId) REFERENCES Contracts(Id);

ALTER TABLE InvoiceDetails ADD FOREIGN KEY (InvoiceId) REFERENCES Invoices(Id);
ALTER TABLE InvoiceDetails ADD FOREIGN KEY (FeeTypeId) REFERENCES FeeTypes(Id);

ALTER TABLE Payments ADD FOREIGN KEY (InvoiceId) REFERENCES Invoices(Id);

ALTER TABLE Maintenances ADD FOREIGN KEY (RoomId) REFERENCES Rooms(Id);

ALTER TABLE Notifications ADD FOREIGN KEY (UserId) REFERENCES Users(Id);