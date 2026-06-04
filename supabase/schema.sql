-- ============================================================
-- RevisionOS Database Schema
-- Run this entire file in your Supabase SQL Editor
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_cron";

-- ============================================================
-- PROFILES
-- ============================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  exam_target TEXT,
  exam_date DATE,
  theme TEXT DEFAULT 'dark' CHECK (theme IN ('light', 'dark', 'amoled')),
  accent_color TEXT DEFAULT '#FF6B35',
  daily_goal INTEGER DEFAULT 5,
  weekly_goal INTEGER DEFAULT 30,
  notification_enabled BOOLEAN DEFAULT TRUE,
  notification_time TIME DEFAULT '08:00:00',
  streak_count INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_active_date DATE,
  revision_score INTEGER DEFAULT 0,
  total_revisions INTEGER DEFAULT 0,
  total_study_hours DECIMAL(10,2) DEFAULT 0,
  onboarding_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- SUBJECTS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.subjects (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  color TEXT DEFAULT '#FF6B35',
  icon TEXT DEFAULT 'book',
  description TEXT,
  exam_weightage DECIMAL(5,2) DEFAULT 0,
  sort_order INTEGER DEFAULT 0,
  is_archived BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- CHAPTERS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.chapters (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
  difficulty TEXT DEFAULT 'medium' CHECK (difficulty IN ('easy', 'medium', 'hard', 'expert')),
  exam_weightage DECIMAL(5,2) DEFAULT 0,
  estimated_revision_time INTEGER DEFAULT 30,
  notes TEXT DEFAULT '',
  status TEXT DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed')),
  completion_percentage INTEGER DEFAULT 0,
  total_revisions INTEGER DEFAULT 0,
  last_revised_at TIMESTAMPTZ,
  first_studied_at TIMESTAMPTZ,
  sort_order INTEGER DEFAULT 0,
  tags TEXT[] DEFAULT '{}',
  is_archived BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- TOPICS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.topics (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  chapter_id UUID REFERENCES public.chapters(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  notes TEXT DEFAULT '',
  is_completed BOOLEAN DEFAULT FALSE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- STUDY LOGS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.study_logs (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  chapter_id UUID REFERENCES public.chapters(id) ON DELETE CASCADE NOT NULL,
  log_type TEXT NOT NULL CHECK (log_type IN ('studied', 'revised', 'completed', 'partial', 'quick')),
  duration INTEGER DEFAULT 0,
  quality_rating INTEGER CHECK (quality_rating BETWEEN 1 AND 5),
  notes TEXT DEFAULT '',
  logged_at TIMESTAMPTZ DEFAULT NOW(),
  date DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- REVISIONS (Spaced Repetition Engine)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.revisions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  chapter_id UUID REFERENCES public.chapters(id) ON DELETE CASCADE NOT NULL,
  scheduled_date DATE NOT NULL,
  interval_days INTEGER NOT NULL DEFAULT 1,
  interval_index INTEGER DEFAULT 0,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'missed', 'skipped', 'rescheduled')),
  completed_at TIMESTAMPTZ,
  quality_rating INTEGER CHECK (quality_rating BETWEEN 1 AND 5),
  notes TEXT DEFAULT '',
  is_auto_generated BOOLEAN DEFAULT TRUE,
  next_revision_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- GOALS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.goals (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  goal_type TEXT NOT NULL CHECK (goal_type IN ('daily', 'weekly', 'monthly', 'custom')),
  target_value INTEGER NOT NULL,
  current_value INTEGER DEFAULT 0,
  metric TEXT NOT NULL CHECK (metric IN ('revisions', 'study_hours', 'chapters', 'subjects')),
  start_date DATE NOT NULL DEFAULT CURRENT_DATE,
  end_date DATE NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- ACHIEVEMENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.achievements (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  achievement_key TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  unlocked_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, achievement_key)
);

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT DEFAULT 'info' CHECK (type IN ('info', 'warning', 'success', 'reminder', 'achievement')),
  is_read BOOLEAN DEFAULT FALSE,
  action_url TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- FOCUS SESSIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS public.focus_sessions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  chapter_id UUID REFERENCES public.chapters(id) ON DELETE SET NULL,
  duration INTEGER NOT NULL,
  target_duration INTEGER NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  notes TEXT DEFAULT '',
  started_at TIMESTAMPTZ DEFAULT NOW(),
  ended_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- DAILY STATS (Materialized for performance)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.daily_stats (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  revisions_completed INTEGER DEFAULT 0,
  study_minutes INTEGER DEFAULT 0,
  chapters_studied INTEGER DEFAULT 0,
  streak_day BOOLEAN DEFAULT FALSE,
  revision_score INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_subjects_user_id ON public.subjects(user_id);
CREATE INDEX IF NOT EXISTS idx_chapters_user_id ON public.chapters(user_id);
CREATE INDEX IF NOT EXISTS idx_chapters_subject_id ON public.chapters(subject_id);
CREATE INDEX IF NOT EXISTS idx_topics_chapter_id ON public.topics(chapter_id);
CREATE INDEX IF NOT EXISTS idx_study_logs_user_id ON public.study_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_study_logs_date ON public.study_logs(date);
CREATE INDEX IF NOT EXISTS idx_revisions_user_id ON public.revisions(user_id);
CREATE INDEX IF NOT EXISTS idx_revisions_scheduled_date ON public.revisions(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_revisions_status ON public.revisions(status);
CREATE INDEX IF NOT EXISTS idx_daily_stats_user_date ON public.daily_stats(user_id, date);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id, is_read);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.revisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.focus_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_stats ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- Subjects policies
CREATE POLICY "Users can CRUD own subjects" ON public.subjects FOR ALL USING (auth.uid() = user_id);

-- Chapters policies
CREATE POLICY "Users can CRUD own chapters" ON public.chapters FOR ALL USING (auth.uid() = user_id);

-- Topics policies
CREATE POLICY "Users can CRUD own topics" ON public.topics FOR ALL USING (auth.uid() = user_id);

-- Study logs policies
CREATE POLICY "Users can CRUD own study_logs" ON public.study_logs FOR ALL USING (auth.uid() = user_id);

-- Revisions policies
CREATE POLICY "Users can CRUD own revisions" ON public.revisions FOR ALL USING (auth.uid() = user_id);

-- Goals policies
CREATE POLICY "Users can CRUD own goals" ON public.goals FOR ALL USING (auth.uid() = user_id);

-- Achievements policies
CREATE POLICY "Users can view own achievements" ON public.achievements FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own achievements" ON public.achievements FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Notifications policies
CREATE POLICY "Users can CRUD own notifications" ON public.notifications FOR ALL USING (auth.uid() = user_id);

-- Focus sessions policies
CREATE POLICY "Users can CRUD own focus_sessions" ON public.focus_sessions FOR ALL USING (auth.uid() = user_id);

-- Daily stats policies
CREATE POLICY "Users can CRUD own daily_stats" ON public.daily_stats FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Update timestamps
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_profiles BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at_subjects BEFORE UPDATE ON public.subjects FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at_chapters BEFORE UPDATE ON public.chapters FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at_revisions BEFORE UPDATE ON public.revisions FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();
CREATE TRIGGER set_updated_at_goals BEFORE UPDATE ON public.goals FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Auto-generate spaced repetition revisions
CREATE OR REPLACE FUNCTION public.generate_spaced_revisions(
  p_user_id UUID,
  p_chapter_id UUID,
  p_start_date DATE DEFAULT CURRENT_DATE
)
RETURNS VOID AS $$
DECLARE
  intervals INTEGER[] := ARRAY[1, 3, 7, 14, 30, 60, 90];
  interval_val INTEGER;
  i INTEGER := 0;
BEGIN
  FOREACH interval_val IN ARRAY intervals LOOP
    INSERT INTO public.revisions (user_id, chapter_id, scheduled_date, interval_days, interval_index, is_auto_generated)
    VALUES (p_user_id, p_chapter_id, p_start_date + interval_val, interval_val, i, TRUE)
    ON CONFLICT DO NOTHING;
    i := i + 1;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update daily stats
CREATE OR REPLACE FUNCTION public.update_daily_stats(
  p_user_id UUID,
  p_date DATE DEFAULT CURRENT_DATE,
  p_revisions INTEGER DEFAULT 0,
  p_minutes INTEGER DEFAULT 0,
  p_chapters INTEGER DEFAULT 0
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO public.daily_stats (user_id, date, revisions_completed, study_minutes, chapters_studied, streak_day)
  VALUES (p_user_id, p_date, p_revisions, p_minutes, p_chapters, TRUE)
  ON CONFLICT (user_id, date) DO UPDATE SET
    revisions_completed = daily_stats.revisions_completed + p_revisions,
    study_minutes = daily_stats.study_minutes + p_minutes,
    chapters_studied = daily_stats.chapters_studied + p_chapters,
    streak_day = TRUE,
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Calculate streak
CREATE OR REPLACE FUNCTION public.calculate_streak(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  streak INTEGER := 0;
  check_date DATE := CURRENT_DATE - 1;
  has_activity BOOLEAN;
BEGIN
  -- Check today first
  SELECT EXISTS(
    SELECT 1 FROM public.daily_stats
    WHERE user_id = p_user_id AND date = CURRENT_DATE AND streak_day = TRUE
  ) INTO has_activity;

  IF NOT has_activity THEN
    check_date := CURRENT_DATE - 1;
  ELSE
    streak := 1;
    check_date := CURRENT_DATE - 1;
  END IF;

  LOOP
    SELECT EXISTS(
      SELECT 1 FROM public.daily_stats
      WHERE user_id = p_user_id AND date = check_date AND streak_day = TRUE
    ) INTO has_activity;

    IF NOT has_activity THEN EXIT; END IF;
    streak := streak + 1;
    check_date := check_date - 1;
  END LOOP;

  RETURN streak;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enable Realtime for key tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.revisions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.study_logs;
ALTER PUBLICATION supabase_realtime ADD TABLE public.daily_stats;
