-- USERS
CREATE TABLE public.users (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  email text UNIQUE,
  username text UNIQUE,
  avatar_url text,
  bio text,
  created_at timestamptz DEFAULT now()
);

-- STORIES
CREATE TABLE public.stories (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  title text,
  body jsonb, -- {paragraphs:[{text, image_url, alt}]}
  cover_url text,
  tone text,
  illustration_style text,
  length_preset text,
  visibility text DEFAULT 'public',
  like_count int DEFAULT 0,
  comment_count int DEFAULT 0,
  share_count int DEFAULT 0,
  trending_score numeric DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- FOLLOWS
CREATE TABLE public.follows (
  user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  follower_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (user_id, follower_id)
); 