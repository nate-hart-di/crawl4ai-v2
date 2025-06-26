"""
Ollama-powered Knowledge Graph Extractor for enhanced code understanding.

This module uses local Ollama models to extract deeper semantic relationships
from code repositories, enhancing the Neo4j knowledge graph with AI insights.
"""

import os
import requests
import json
import ast
import logging
from typing import Dict, List, Any, Optional, Tuple
from pathlib import Path
from dataclasses import dataclass

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class CodeEntity:
    name: str
    type: str
    purpose: str
    relationships: List[str]
    complexity: str
    dependencies: List[str]

class OllamaKnowledgeExtractor:
    def __init__(self, model_name: str = None, ollama_url: str = None):
        if model_name is None:
            model_name = os.getenv("MODEL_CHOICE", "codellama:7b-instruct")
        if ollama_url is None:
            ollama_url = os.getenv("OLLAMA_URL", "http://host.docker.internal:11434")
        self.model_name = model_name
        self.ollama_url = ollama_url
        self.session = requests.Session()
        
    def is_ollama_available(self) -> bool:
        """Check if Ollama is running and model is available."""
        try:
            response = self.session.get(f"{self.ollama_url}/api/tags")
            if response.status_code == 200:
                models = response.json().get("models", [])
                return any(model["name"].startswith(self.model_name.split(":")[0]) for model in models)
            return False
        except Exception as e:
            logger.warning(f"Ollama not available: {e}")
            return False
    
    def query_ollama(self, prompt: str, temperature: float = 0.1) -> str:
        """Query Ollama model with a prompt."""
        try:
            payload = {
                "model": self.model_name,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": temperature,
                    "top_p": 0.9,
                    "repeat_penalty": 1.1
                }
            }
            
            response = self.session.post(
                f"{self.ollama_url}/api/generate",
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                return response.json().get("response", "").strip()
            else:
                logger.error(f"Ollama API error: {response.status_code}")
                return ""
                
        except Exception as e:
            logger.error(f"Error querying Ollama: {e}")
            return ""
    
    def extract_code_purpose(self, code: str, entity_name: str, entity_type: str) -> str:
        """Extract the purpose/functionality of a code entity."""
        prompt = f"""
Analyze this {entity_type} and provide a concise 1-2 sentence description of its purpose:

```python
{code}
```

Entity name: {entity_name}
Type: {entity_type}

Provide only the purpose description, no additional text:
"""
        return self.query_ollama(prompt)
    
    def extract_relationships(self, code: str, entity_name: str) -> List[str]:
        """Extract relationships between code entities."""
        prompt = f"""
Analyze this code and identify what other classes, functions, or modules it depends on or interacts with:

```python
{code}
```

Entity: {entity_name}

List only the names of dependencies/relationships, one per line, no explanations:
"""
        response = self.query_ollama(prompt)
        if response:
            return [line.strip() for line in response.split('\n') if line.strip()]
        return []
    
    def assess_complexity(self, code: str) -> str:
        """Assess the complexity level of code."""
        prompt = f"""
Analyze this code and rate its complexity as one of: LOW, MEDIUM, HIGH

```python
{code}
```

Consider factors like:
- Number of branches/conditions
- Nested loops
- Function calls
- Logic complexity

Respond with only: LOW, MEDIUM, or HIGH
"""
        response = self.query_ollama(prompt)
        complexity = response.upper().strip()
        return complexity if complexity in ['LOW', 'MEDIUM', 'HIGH'] else 'MEDIUM'
    
    def extract_semantic_tags(self, code: str, entity_name: str) -> List[str]:
        """Extract semantic tags for better categorization."""
        prompt = f"""
Analyze this code and provide 3-5 semantic tags that describe its functionality:

```python
{code}
```

Entity: {entity_name}

Examples of good tags: data-processing, api-client, validation, authentication, database, utility, algorithm, etc.

Provide only the tags, comma-separated:
"""
        response = self.query_ollama(prompt)
        if response:
            return [tag.strip().lower() for tag in response.split(',') if tag.strip()]
        return []
    
    def analyze_code_file(self, file_path: str) -> List[CodeEntity]:
        """Analyze a Python file and extract enhanced code entities."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Parse AST
            tree = ast.parse(content)
            entities = []
            
            # Extract classes
            for node in ast.walk(tree):
                if isinstance(node, ast.ClassDef):
                    class_code = ast.get_source_segment(content, node)
                    if class_code:
                        entity = CodeEntity(
                            name=node.name,
                            type="class",
                            purpose=self.extract_code_purpose(class_code, node.name, "class"),
                            relationships=self.extract_relationships(class_code, node.name),
                            complexity=self.assess_complexity(class_code),
                            dependencies=[]
                        )
                        entities.append(entity)
                
                elif isinstance(node, ast.FunctionDef):
                    func_code = ast.get_source_segment(content, node)
                    if func_code:
                        entity = CodeEntity(
                            name=node.name,
                            type="function",
                            purpose=self.extract_code_purpose(func_code, node.name, "function"),
                            relationships=self.extract_relationships(func_code, node.name),
                            complexity=self.assess_complexity(func_code),
                            dependencies=[]
                        )
                        entities.append(entity)
            
            return entities
            
        except Exception as e:
            logger.error(f"Error analyzing file {file_path}: {e}")
            return []
    
    def enhance_knowledge_graph(self, repo_path: str, neo4j_session) -> Dict[str, Any]:
        """Enhance existing knowledge graph with Ollama insights."""
        if not self.is_ollama_available():
            logger.warning(f"Ollama model {self.model_name} not available. Skipping enhancement.")
            return {"status": "skipped", "reason": "ollama_unavailable"}
        
        logger.info(f"Enhancing knowledge graph with {self.model_name}")
        
        python_files = list(Path(repo_path).rglob("*.py"))
        enhanced_entities = 0
        
        for file_path in python_files:
            try:
                entities = self.analyze_code_file(str(file_path))
                
                for entity in entities:
                    # Update Neo4j with enhanced metadata
                    query = """
                    MATCH (n {name: $name})
                    WHERE n:Class OR n:Function OR n:Method
                    SET n.ai_purpose = $purpose,
                        n.ai_complexity = $complexity,
                        n.ai_tags = $tags
                    RETURN n
                    """
                    
                    tags = self.extract_semantic_tags("", entity.name)  # Could pass code here
                    
                    result = neo4j_session.run(query, {
                        "name": entity.name,
                        "purpose": entity.purpose,
                        "complexity": entity.complexity,
                        "tags": tags
                    })
                    
                    if result.single():
                        enhanced_entities += 1
                        
            except Exception as e:
                logger.error(f"Error processing {file_path}: {e}")
        
        return {
            "status": "completed",
            "enhanced_entities": enhanced_entities,
            "model_used": self.model_name
        }

def main():
    """Test the Ollama knowledge extractor."""
    extractor = OllamaKnowledgeExtractor()
    
    if not extractor.is_ollama_available():
        print(f"❌ Ollama model {extractor.model_name} not available")
        print("Install with: ollama pull codellama:7b-instruct")
        return
    
    print(f"✅ Ollama model {extractor.model_name} is available")
    
    # Test with a simple code snippet
    test_code = '''
def calculate_fibonacci(n):
    """Calculate the nth Fibonacci number."""
    if n <= 1:
        return n
    return calculate_fibonacci(n-1) + calculate_fibonacci(n-2)
'''
    
    purpose = extractor.extract_code_purpose(test_code, "calculate_fibonacci", "function")
    complexity = extractor.assess_complexity(test_code)
    
    print(f"Purpose: {purpose}")
    print(f"Complexity: {complexity}")

if __name__ == "__main__":
    main() 
