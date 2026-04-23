-- ============================================================
-- TOMO 味觉测试 · Supabase 数据库初始化
-- 在 Supabase Dashboard → SQL Editor 中执行此脚本
-- ============================================================

-- 1. 测试结果表 (v2: 三套题组 + 设备指纹)
CREATE TABLE test_results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT now(),

  -- 用户信息
  tomo_uid TEXT,             -- 设备指纹 (8位随机码, cookie 365天)
  gender TEXT CHECK (gender IN ('m', 'f')),
  tier TEXT CHECK (tier IN ('fresh', 'craft', 'nerd')),  -- 经验等级

  -- 灵活答案存储 (JSONB, 支持 5/8/10 题)
  q_answers JSONB,

  -- 兼容旧版 CRAFT 8题字段
  q1 TEXT,
  q2 TEXT,   -- 多选题，逗号分隔
  q3 TEXT,
  q4 TEXT,
  q5 TEXT,
  q6 TEXT,
  q7 TEXT,
  q8 TEXT,

  -- 计算结果
  persona_id INT,           -- 1-12
  persona_bio TEXT,          -- 黑锋、铁饮...
  persona_pro TEXT,          -- 深渊客、鉴味师...
  persona_quad TEXT,         -- edge/bloom/easy
  persona_suit TEXT,         -- ♠♥ etc

  -- 评分明细
  score_edge INT DEFAULT 0,
  score_bloom INT DEFAULT 0,
  score_easy INT DEFAULT 0,

  -- 裂变追踪
  ref_from TEXT,             -- 谁带来的 (对方的 tomo_uid)

  -- 设备信息
  user_agent TEXT,
  referrer TEXT
);

-- 2. 投票记录表
CREATE TABLE votes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at TIMESTAMPTZ DEFAULT now(),
  test_result_id UUID REFERENCES test_results(id),
  beer_name TEXT,
  beer_index INT
);

-- 3. 开启 Row Level Security
ALTER TABLE test_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE votes ENABLE ROW LEVEL SECURITY;

-- 4. 允许匿名用户插入（anon key 可写入）
CREATE POLICY "Allow anonymous insert" ON test_results
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow anonymous insert" ON votes
  FOR INSERT WITH CHECK (true);

-- 5. 允许匿名用户读取（后续做数据看板用）
CREATE POLICY "Allow anonymous read" ON test_results
  FOR SELECT USING (true);

CREATE POLICY "Allow anonymous read" ON votes
  FOR SELECT USING (true);

-- 6. 创建索引加速查询
CREATE INDEX idx_test_results_persona ON test_results(persona_bio);
CREATE INDEX idx_test_results_created ON test_results(created_at);
CREATE INDEX idx_test_results_quad ON test_results(persona_quad);
CREATE INDEX idx_test_results_tomo_uid ON test_results(tomo_uid);
CREATE INDEX idx_test_results_ref_from ON test_results(ref_from);
CREATE INDEX idx_test_results_tier ON test_results(tier);
