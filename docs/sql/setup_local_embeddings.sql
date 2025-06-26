CREATE EXTENSION IF NOT EXISTS vector;

DROP TABLE IF EXISTS crawled_pages CASCADE;
DROP TABLE IF EXISTS code_examples CASCADE;
DROP TABLE IF EXISTS sources CASCADE;
CREATE TABLE sources (
    source_id text PRIMARY KEY,
    summary text,
    total_word_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);
CREATE TABLE crawled_pages (
    id bigserial PRIMARY KEY,
    url varchar NOT NULL, 
    chunk_number integer NOT NULL,
    content text NOT NULL,
    metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
    source_id text NOT NULL,
    embedding vector(768),  -- LOCAL embeddings are 768 dimensions
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Add a unique constraint to prevent duplicate chunks for the same URL
    UNIQUE(url, chunk_number),
    
    -- Add foreign key constraint to sources table
    FOREIGN KEY (source_id) REFERENCES sources(source_id) ON DELETE CASCADE
);

-- Create the code_examples table
CREATE TABLE code_examples (
    id bigserial PRIMARY KEY,
    url varchar NOT NULL,
    chunk_number integer NOT NULL,
    content text NOT NULL,  -- The code example content
    summary text NOT NULL,  -- Summary of the code example
    metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
    source_id text NOT NULL,
    embedding vector(768),  -- LOCAL embeddings are 768 dimensions
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    
    -- Add a unique constraint to prevent duplicate chunks for the same URL
    UNIQUE(url, chunk_number),
    
    -- Add foreign key constraint to sources table
    FOREIGN KEY (source_id) REFERENCES sources(source_id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX crawled_pages_embedding_idx ON crawled_pages USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX code_examples_embedding_idx ON code_examples USING ivfflat (embedding vector_cosine_ops);

-- Create indexes on metadata for faster filtering
CREATE INDEX idx_crawled_pages_metadata ON crawled_pages USING gin (metadata);
CREATE INDEX idx_code_examples_metadata ON code_examples USING gin (metadata);

-- Create indexes on source_id for faster filtering
CREATE INDEX idx_crawled_pages_source_id ON crawled_pages (source_id);
CREATE INDEX idx_code_examples_source_id ON code_examples (source_id);

-- Function to search crawled pages (documentation)
CREATE OR REPLACE FUNCTION match_crawled_pages (
  query_embedding vector(768),
  match_count int DEFAULT 10,
  filter jsonb DEFAULT '{}'::jsonb,
  source_filter text DEFAULT NULL
) RETURNS TABLE (
  id bigint,
  url varchar,
  chunk_number integer,
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
    1 - (crawled_pages.embedding <=> query_embedding) AS similarity
  FROM crawled_pages
  WHERE crawled_pages.metadata @> filter
    AND (source_filter IS NULL OR crawled_pages.source_id = source_filter)
    AND crawled_pages.embedding IS NOT NULL
  ORDER BY crawled_pages.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- Function to search code examples
CREATE OR REPLACE FUNCTION match_code_examples (
  query_embedding vector(768),
  match_count int DEFAULT 10,
  filter jsonb DEFAULT '{}'::jsonb,
  source_filter text DEFAULT NULL
) RETURNS TABLE (
  id bigint,
  url varchar,
  chunk_number integer,
  content text,
  summary text,
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
    code_examples.id,
    code_examples.url,
    code_examples.chunk_number,
    code_examples.content,
    code_examples.summary,
    code_examples.metadata,
    code_examples.source_id,
    1 - (code_examples.embedding <=> query_embedding) AS similarity
  FROM code_examples
  WHERE code_examples.metadata @> filter
    AND (source_filter IS NULL OR code_examples.source_id = source_filter)
    AND code_examples.embedding IS NOT NULL
  ORDER BY code_examples.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- Enable Row Level Security
ALTER TABLE sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE crawled_pages ENABLE ROW LEVEL SECURITY;
ALTER TABLE code_examples ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access
CREATE POLICY "Allow public read access to sources"
  ON sources FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow public read access to crawled_pages"
  ON crawled_pages FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Allow public read access to code_examples"
  ON code_examples FOR SELECT
  TO public
  USING (true);

-- Create policies for authenticated insert/update (for the MCP service)
CREATE POLICY "Allow authenticated insert to sources"
  ON sources FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated update to sources"
  ON sources FOR UPDATE
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated insert to crawled_pages"
  ON crawled_pages FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated insert to code_examples"
  ON code_examples FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Setup complete!
-- Your database is now ready for 768-dimensional local embeddings with proper security policies 
