-- =============================================================================
-- DATABASE UPDATE: ADDING JWT REFRESH TOKEN COLUMNS
-- AUTHOR: GEMINI AI EXPERT
-- DESCRIPTION: Thêm các cột phục vụ cơ chế Refresh Token cho bảng sy_users.
-- =============================================================================

ALTER TABLE public.sy_users 
ADD COLUMN IF NOT EXISTS refresh_token TEXT,
ADD COLUMN IF NOT EXISTS refresh_token_expiry TIMESTAMP;

-- Đảm bảo người dùng admin hiện tại có thể login bình thường
UPDATE public.sy_users SET is_active = true WHERE username = 'admin';
