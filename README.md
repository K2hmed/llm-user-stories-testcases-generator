# Requirements → User Stories → Test Cases  
### LLM-Powered Python Pipeline

## Overview

This repository contains a Python-based, end-to-end pipeline that ingests requirement documents and automatically generates structured EPICs, user stories, and QA-grade test cases using a Large Language Model (LLM).

The system supports `.txt`, `.docx`, and `.pdf` inputs, enforces strict JSON outputs from the LLM for reliability, and exports the final results into a clean, reviewer-ready Excel file.

This project is published as a generalized portfolio example. Any employer-specific context or instructions have been removed.

---

## Pipeline Summary

The tool implements a clear and reproducible workflow:

### 1. Document Ingestion

Requirement text is extracted and normalized from:

- `.txt`
- `.docx`
- `.pdf`

Standard Python libraries are used (`open()`, `python-docx`, `pdfplumber`) to ensure transparency and debuggability.

### 2. EPIC and User Story Generation (LLM)

A dedicated prompt template (`USER_STORIES_PROMPT_TEMPLATE`) instructs the LLM to:

- Identify EPICs
- Generate agile-style user stories
- Produce testable acceptance criteria

The prompt enforces **strict JSON output**, enabling predictable downstream parsing and validation.

### 3. Test Case Generation (LLM)

A second prompt template (`TEST_CASES_PROMPT_TEMPLATE`) takes the generated user stories and produces detailed test cases.

Each test case includes:

- Test Case Name  
- Description  
- Ordered Execution Steps  

The model is again constrained to return JSON conforming to a predefined schema.

### 4. Tabular Output and Excel Export

The validated JSON output is flattened into a pandas DataFrame with the following columns:

- EPIC  
- User Story  
- Test Case Name  
- Test Case Description  
- Execution Steps  

The final output is written to:
`./outputs/userstories_testcases_output.xlsx`


Each row corresponds to a single test case.

---

## Technology Stack

- Python 3.10+
- OpenAI API (model configurable; GPT-4.1-mini used by default)
- pandas for tabular processing
- python-docx, pdfplumber for document ingestion
- Jupyter Notebook for demonstration and inspection
- Docker (optional) for reproducibility

---

## Architecture and Design

### Document Loading Layer

Helper functions handle file-type-specific ingestion:

- `load_txt()`
- `load_docx()`
- `load_pdf()`
- `load_requirement_file()` (auto-detecting wrapper)

All inputs are converted into a unified plain-text format before LLM processing.

### Prompt Engineering Layer

Prompt design is intentionally strict and explicit.

Each prompt:

- Assigns a clear expert role to the model
- Defines an exact JSON schema
- Forbids commentary outside JSON
- Guards against extra keys, trailing commas, or formatting deviations
- Includes example structures to reinforce output shape

This approach prioritizes **deterministic, machine-parsable outputs** over free-form text generation.

### JSON Validation Layer

Every LLM response undergoes:

- Strict `json.loads()` parsing
- Explicit error handling for malformed output
- Structural validation before downstream use
- Debug logging when schema violations occur

This ensures later pipeline stages never operate on unreliable data.

### Tabular Flattening and Export

A dedicated `build_dataframe()` function converts structured test case JSON into a flat table.

It:

- Formats user stories consistently (e.g., `US-1: Verify student eligibility`)
- Numbers execution steps (`1.`, `2.`, `3.`)
- Enforces column order and naming
- Produces Excel-ready output without manual cleanup

---

## Output Inspection

The notebook surfaces intermediate outputs to support inspection and debugging, including:

- Number of EPICs identified
- Sample raw JSON from the LLM
- Test case counts per user story
- Preview of the final DataFrame

This makes LLM behavior observable rather than opaque.

---

## Why LangChain Is Not Used

LangChain was evaluated but intentionally not included.

The design favors:

- **Transparency**: Raw API calls expose exact prompts and responses.
- **Determinism**: Avoids abstraction layers that may alter structured output.
- **Simplicity**: The pipeline consists of two controlled LLM calls, which do not benefit from additional orchestration layers.

The architecture remains extensible, and LangChain or other frameworks could be integrated if model routing or multi-step chaining becomes a requirement.

---

## How to Run

### Install Dependencies

```bash
pip install openai pandas python-docx pdfplumber
```

### Set API Key

```bash
export OPENAI_API_KEY="your-key-here"
```

### Run the Notebook

1. Update requirement_path to point to a `.txt`, `.docx`, or `.pdf` file

2. Run the notebook top-to-bottom

3. Retrieve output from:

```bash
./outputs/userstories_testcases_output.xlsx
```

---

## Optional: Docker Execution

A Dockerfile is included for reproducible execution.

### Build Image

```bash
docker build -t llm-requirements-tool .
```

### Run Container

```bash
docker run -it -p 8888:8888 \
  -e OPENAI_API_KEY="your-key-here" \
  llm-requirements-tool
```

Open the printed Jupyter URL and run:

```bash
notebooks/requirements_to_tests.ipynb
```

---

## Summary

This project demonstrates:

- Clean, modular Python design

- Production-grade prompt engineering

- Safe handling of LLM-generated structured data

- Automated transformation of real-world requirements into testable artifacts

- Professional-quality Excel exports suitable for review or handoff

The pipeline is reliable, explainable, and designed for extension.
