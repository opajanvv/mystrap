---
name: document-analysis
description: Analyze and summarize documents in a folder (PDF, DOCX, XLSX)
---

# Document Analysis Skill

This skill provides a workflow for analyzing all documents in a folder and creating a comprehensive Markdown overview.

## When to Use

Use this skill when the user wants:
- An overview of documents in a folder
- Summaries of multiple PDF, DOCX, or XLSX files
- A structured analysis of project documentation

## Supported File Formats

| Format | Extraction Method |
|--------|-------------------|
| **DOCX** | Unzip as archive, read `word/document.xml`, strip XML tags |
| **XLSX** | Unzip as archive, read `xl/sharedStrings.xml` and `xl/worksheets/sheet*.xml` |
| **PDF** | Use `pdftotext` command (from poppler-utils) |

## Workflow

### Step 1: Create temporary extraction folder

```bash
mkdir -p /tmp/doc-extract
```

### Step 2: Extract DOCX files

```bash
for f in *.docx; do
  dir="/tmp/doc-extract/$(basename "$f" .docx)"
  mkdir -p "$dir"
  unzip -o -q "$f" -d "$dir" 2>/dev/null
done
```

### Step 3: Extract XLSX files

```bash
for f in *.xlsx; do
  dir="/tmp/doc-extract/$(basename "$f" .xlsx)"
  mkdir -p "$dir"
  unzip -o -q "$f" -d "$dir" 2>/dev/null
done
```

### Step 4: Convert PDF files to text

```bash
for f in *.pdf; do
  txt="/tmp/doc-extract/$(basename "$f" .pdf).txt"
  pdftotext "$f" "$txt" 2>/dev/null
done
```

### Step 5: Read extracted content

- **DOCX:** Read `/tmp/doc-extract/<filename>/word/document.xml`
  - For large files, use: `cat document.xml | sed 's/<[^>]*>//g' | tr -s ' \n'`
- **XLSX:** Read `/tmp/doc-extract/<filename>/xl/sharedStrings.xml` for text content
  - Read `/tmp/doc-extract/<filename>/xl/worksheets/sheet1.xml` for cell structure
- **PDF:** Read `/tmp/doc-extract/<filename>.txt`

### Step 6: Create Markdown overview

Structure the output file as follows:

```markdown
# Document Overview

*Generated on: [date]*

---

## Summary
[High-level project summary based on all documents]

## Key Information
[Important dates, amounts, contacts extracted from documents]

## Timeline
[Chronological overview of events/dates mentioned]

## Document Summaries

### 1. [Document Name]
**Type:** [Category]
**Date:** [If applicable]

[Detailed summary of document content]

---

[Repeat for each document]

## Action Items
[Any open tasks or deadlines identified]

## Contact Information
[Relevant contacts extracted from documents]
```

### Step 7: Cleanup

```bash
rm -rf /tmp/doc-extract
```

## Tips

1. **Categorize documents** by type (contracts, invoices, correspondence, reports) before summarizing
2. **Cross-reference** information between documents to build a complete picture
3. **Extract key data** like amounts, dates, names, and deadlines
4. **Identify relationships** between documents (e.g., invoice relates to contract)
5. **Note discrepancies** if documents contain conflicting information

## Handling Large Files

When a file exceeds the token limit (typically ~25,000 tokens), use these strategies:

### Strategy 1: Strip XML tags before reading (DOCX)

```bash
cat document.xml | sed 's/<[^>]*>//g' | tr -s ' \n' > clean.txt
```

This removes all XML markup and leaves only the text content, significantly reducing file size.

### Strategy 2: Limit output with head

```bash
# Read first N characters
cat document.xml | sed 's/<[^>]*>//g' | tr -s ' \n' | head -c 15000

# Read first N lines
head -n 500 extracted.txt
```

### Strategy 3: Read file in chunks

Use the `read_file` tool with `offset` and `limit` parameters:
- First read lines 1-500
- Then read lines 501-1000
- Continue until complete

### Strategy 4: Search for specific content

If you know what you're looking for, use grep to extract relevant sections:

```bash
# Find lines containing amounts
grep -E '€|EUR|[0-9]+,-' document.txt

# Find lines with dates
grep -E '[0-9]{1,2}[-/][0-9]{1,2}[-/][0-9]{2,4}' document.txt

# Find paragraphs containing keywords
grep -B2 -A2 'subsidie\|budget\|kosten' document.txt
```

### Strategy 5: Split large PDFs

For very large PDFs, extract specific pages:

```bash
# Extract pages 1-10 only
pdftotext -f 1 -l 10 large.pdf first_pages.txt

# Extract text from specific page
pdftotext -f 5 -l 5 large.pdf page5.txt
```

### Strategy 6: Excel - read only shared strings

For large Excel files, the `sharedStrings.xml` contains all unique text values and is usually much smaller than the full worksheet data:

```bash
cat xl/sharedStrings.xml | sed 's/<[^>]*>//g' | tr -s ' \n'
```

## Error Handling

- If `pdftotext` is not installed: `sudo pacman -S poppler` (Arch) or `sudo apt install poppler-utils` (Debian/Ubuntu)
- If a file cannot be read, note this in the output and continue with other files
- For very large XML files, use grep or sed to extract relevant sections
