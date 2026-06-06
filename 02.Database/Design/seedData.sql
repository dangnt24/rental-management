-- =========================
-- LANGUAGES
-- =========================
INSERT INTO Languages (Code, Name) VALUES
('en', 'English'),
('vi', 'Tiếng Việt');

-- =========================
-- COMMON: ROOM STATUS
-- =========================
INSERT INTO CommonCategories (Code) VALUES ('ROOM_STATUS');

INSERT INTO CommonValues (CategoryId, Code, Value, OrderIndex)
SELECT Id, 'AVAILABLE', 'Available', 1 FROM CommonCategories WHERE Code = 'ROOM_STATUS';

INSERT INTO CommonValues (CategoryId, Code, Value, OrderIndex)
SELECT Id, 'OCCUPIED', 'Occupied', 2 FROM CommonCategories WHERE Code = 'ROOM_STATUS';

INSERT INTO CommonValues (CategoryId, Code, Value, OrderIndex)
SELECT Id, 'MAINTENANCE', 'Maintenance', 3 FROM CommonCategories WHERE Code = 'ROOM_STATUS';

-- TRANSLATIONS
INSERT INTO CommonTranslations (CommonValueId, LanguageCode, Value)
SELECT Id, 'vi', 'Trống' FROM CommonValues WHERE Code = 'AVAILABLE';

INSERT INTO CommonTranslations (CommonValueId, LanguageCode, Value)
SELECT Id, 'vi', 'Đã thuê' FROM CommonValues WHERE Code = 'OCCUPIED';

INSERT INTO CommonTranslations (CommonValueId, LanguageCode, Value)
SELECT Id, 'vi', 'Đang sửa' FROM CommonValues WHERE Code = 'MAINTENANCE';

-- =========================
-- GENDER
-- =========================
INSERT INTO CommonCategories (Code) VALUES ('GENDER');

INSERT INTO CommonValues (CategoryId, Code, Value)
SELECT Id, 'MALE', 'Male' FROM CommonCategories WHERE Code = 'GENDER';

INSERT INTO CommonValues (CategoryId, Code, Value)
SELECT Id, 'FEMALE', 'Female' FROM CommonCategories WHERE Code = 'GENDER';

INSERT INTO CommonTranslations (CommonValueId, LanguageCode, Value)
SELECT Id, 'vi', 'Nam' FROM CommonValues WHERE Code = 'MALE';

INSERT INTO CommonTranslations (CommonValueId, LanguageCode, Value)
SELECT Id, 'vi', 'Nữ' FROM CommonValues WHERE Code = 'FEMALE';

-- =========================
-- ROLES
-- =========================
INSERT INTO Roles (Name) VALUES
('ADMIN'),
('MANAGER'),
('STAFF'),
('TENANT');

-- =========================
-- PERMISSIONS
-- =========================
INSERT INTO Permissions (Code, Name) VALUES
('ROOM_VIEW', 'View rooms'),
('ROOM_CREATE', 'Create room'),
('ROOM_UPDATE', 'Update room'),
('ROOM_DELETE', 'Delete room'),

('TENANT_VIEW', 'View tenants'),
('TENANT_CREATE', 'Create tenant'),

('INVOICE_VIEW', 'View invoice'),
('INVOICE_CREATE', 'Create invoice'),
('PAYMENT_MANAGE', 'Manage payment');

-- =========================
-- ROLE PERMISSION (ADMIN full)
-- =========================
INSERT INTO RolePermissions (RoleId, PermissionId)
SELECT r.Id, p.Id
FROM Roles r, Permissions p
WHERE r.Name = 'ADMIN';

-- =========================
-- MENU
-- =========================
INSERT INTO Menus (Name, Path, Icon, OrderIndex) VALUES
('Dashboard', '/dashboard', 'dashboard', 1),
('Rooms', '/rooms', 'home', 2),
('Tenants', '/tenants', 'users', 3),
('Invoices', '/invoices', 'file', 4);

-- =========================
-- FEE TYPES
-- =========================
INSERT INTO FeeTypes (Code, Name, CalculationType, UnitPrice) VALUES
('ROOM', 'Room Fee', 'FIXED', 1500000),
('ELECTRIC', 'Electric Fee', 'PER_UNIT', 3500),
('WATER', 'Water Fee', 'PER_UNIT', 15000),
('WIFI', 'Wifi Fee', 'FIXED', 100000);

-- =========================
-- SAMPLE ROOMS
-- =========================
INSERT INTO Rooms (RoomNumber, Price, MaxOccupants, StatusCode)
VALUES
('101', 1500000, 2, 'AVAILABLE'),
('102', 1500000, 2, 'AVAILABLE'),
('103', 1800000, 3, 'MAINTENANCE');

-- =========================
-- SAMPLE TENANT
-- =========================
INSERT INTO Tenants (FullName, Email, Phone, CCCD, GenderCode, StatusCode)
VALUES
('Nguyen Van A', 'a@gmail.com', '0900000001', '123456789', 'MALE', 'ACTIVE');

-- =========================
-- SAMPLE USER (admin)
-- password = 123456 (hash fake, bạn sẽ thay sau)
-- =========================
INSERT INTO Users (Username, PasswordHash, IsActive)
VALUES
('admin', '123456', true);