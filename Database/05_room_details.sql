-- Thông tin chi tiết phòng. Nâng cấp Source; chạy được nhiều lần, không xóa dữ liệu.
-- Phòng cũ giữ NULL/rỗng = chưa cập nhật; không mặc định tiện nghi/điều kiện thành Có/Không.
BEGIN;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "Area" numeric(18,3);
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "Floor" varchar(2000) NOT NULL DEFAULT '';
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "RoomType" varchar(2000) NOT NULL DEFAULT '';
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "Amenities" text[] NOT NULL DEFAULT ARRAY[]::text[];
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "AmenitiesConfirmed" boolean NOT NULL DEFAULT false;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "ToiletType" varchar(2000) NOT NULL DEFAULT '';
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "AccessHours" varchar(2000) NOT NULL DEFAULT '';
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "LaundryType" varchar(2000) NOT NULL DEFAULT '';
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "ParkingType" varchar(2000) NOT NULL DEFAULT '';
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "MaxVehicles" integer;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "PetsAllowed" boolean;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "ElectricVehiclesAllowed" boolean;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "HasWindow" boolean;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "HasBalcony" boolean;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "SuggestedDeposit" bigint;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "MinimumLeaseMonths" integer;
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "Neighborhood" varchar(2000) NOT NULL DEFAULT '';
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "RentalConditions" varchar(2000) NOT NULL DEFAULT '';
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "ContactName" varchar(2000) NOT NULL DEFAULT '';
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS "ContactPhone" varchar(2000) NOT NULL DEFAULT '';
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='ck_room_details' AND conrelid='rooms'::regclass) THEN
        ALTER TABLE rooms ADD CONSTRAINT ck_room_details CHECK (("Area" IS NULL OR "Area" > 0 AND "Area" <= 5000) AND ("MaxVehicles" IS NULL OR "MaxVehicles" BETWEEN 0 AND 50) AND ("SuggestedDeposit" IS NULL OR "SuggestedDeposit" BETWEEN 0 AND 1000000000) AND ("MinimumLeaseMonths" IS NULL OR "MinimumLeaseMonths" BETWEEN 1 AND 120));
    END IF;
END $$;
COMMIT;
