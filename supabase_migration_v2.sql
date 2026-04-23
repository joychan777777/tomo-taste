-- ============================================================
-- TOMO v2 迁移：三套题组 + 设备指纹
-- 在 Supabase Dashboard → SQL Editor 中执行
-- ============================================================

-- 1. 新增经验等级列
ALTER TABLE test_results ADD COLUMN IF NOT EXISTS tier TEXT CHECK (tier IN ('fresh', 'craft', 'nerd'));

-- 2. 新增灵活答案存储（JSONB，支持不同题数/题目ID）
ALTER TABLE test_results ADD COLUMN IF NOT EXISTS q_answers JSONB;

-- 3. 新增设备指纹（cookie-based，8位随机码）
ALTER TABLE test_results ADD COLUMN IF NOT EXISTS tomo_uid TEXT;

-- 4. 新增裂变来源（谁带来的，对方的 tomo_uid）
ALTER TABLE test_results ADD COLUMN IF NOT EXISTS ref_from TEXT;

-- 5. 索引：按设备指纹查询（追踪同一用户多次测试）
CREATE INDEX IF NOT EXISTS idx_test_results_tomo_uid ON test_results(tomo_uid);

-- 6. 索引：按裂变来源统计（谁带来了多少人）
CREATE INDEX IF NOT EXISTS idx_test_results_ref_from ON test_results(ref_from);

-- 7. 索引：按经验等级筛选
CREATE INDEX IF NOT EXISTS idx_test_results_tier ON test_results(tier);

-- 验证
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = 'test_results'
ORDER BY ordinal_position;
