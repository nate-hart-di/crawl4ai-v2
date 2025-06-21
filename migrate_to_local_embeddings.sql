-- Migration script to switch from OpenAI embeddings (1536 dimensions) to local embeddings (768 dimensions)
-- Run this script to update your Supabase database for local embeddings

-- 1. Drop the existing vector column and recreate with 768 dimensions
ALTER TABLE crawled_pages DROP COLUMN IF EXISTS embedding;
ALTER TABLE crawled_pages ADD COLUMN embedding vector(768);

-- 2. Drop the existing vector column for code examples and recreate with 768 dimensions
ALTER TABLE code_examples DROP COLUMN IF EXISTS embedding;
ALTER TABLE code_examples ADD COLUMN embedding vector(768);

-- 3. Recreate the vector similarity function for 768 dimensions
DROP FUNCTION IF EXISTS match_documents(vector(1536), int, jsonb);
CREATE OR REPLACE FUNCTION match_documents(
  query_embedding vector(768),
  match_count int DEFAULT 5,
  filter jsonb DEFAULT '{}'
)
RETURNS TABLE (
  id bigint,
  url text,
  chunk_number int,
  content text,
  metadata jsonb,
  source_id text,
  similarity float
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
BEGIN
  RETURN QUERY
  SELECT
    crawled_pages.id,
    crawled_pages.url,
    crawled_pages.chunk_number,
    crawled_pages.content,
    crawled_pages.metadata,
    crawled_pages.source_id,
    (crawled_pages.embedding <#> query_embedding) * -1 AS similarity
  FROM crawled_pages
  WHERE crawled_pages.metadata @> filter
  ORDER BY crawled_pages.embedding <#> query_embedding
  LIMIT match_count;
END;
$$;

-- 4. Recreate the code examples similarity function for 768 dimensions
DROP FUNCTION IF EXISTS match_code_examples(vector(1536), int, jsonb);
CREATE OR REPLACE FUNCTION match_code_examples(
  query_embedding vector(768),
  match_count int DEFAULT 5,
  filter jsonb DEFAULT '{}'
)
RETURNS TABLE (
  id bigint,
  url text,
  chunk_number int,
  code_example text,
  summary text,
  metadata jsonb,
  similarity float
)
LANGUAGE plpgsql
AS $$
#variable_conflict use_column
BEGIN
  RETURN QUERY
  SELECT
    code_examples.id,
    code_examples.url,
    code_examples.chunk_number,
    code_examples.code_example,
    code_examples.summary,
    code_examples.metadata,
    (code_examples.embedding <#> query_embedding) * -1 AS similarity
  FROM code_examples
  WHERE code_examples.metadata @> filter
  ORDER BY code_examples.embedding <#> query_embedding
  LIMIT match_count;
END;
$$;

-- 5. Clear existing data (it has wrong dimensions and cannot be converted)
TRUNCATE TABLE crawled_pages CASCADE;
TRUNCATE TABLE code_examples CASCADE;
-- Note: sources table doesn't have embeddings, so it's preserved

-- 6. Create index for better performance
CREATE INDEX IF NOT EXISTS crawled_pages_embedding_idx ON crawled_pages USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX IF NOT EXISTS code_examples_embedding_idx ON code_examples USING ivfflat (embedding vector_cosine_ops);

-- Migration complete!
-- Your database is now ready for 768-dimensional local embeddings 
