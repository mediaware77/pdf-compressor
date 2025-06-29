# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a PDF compression tool that automatically compresses PDF files with DPI above a specified threshold. The project consists of a single bash script that:

- Recursively scans directories for PDF files
- Detects DPI using ImageMagick 
- Compresses PDFs with DPI above the minimum threshold using Ghostscript
- Creates automatic backups before compression
- Only replaces original files if compression achieves ≥5% size reduction
- Provides detailed logging and progress reporting

## Key Commands

```bash
# Test run (recommended first step)
bash compress_pdfs.sh --dry-run

# Basic compression with default settings (DPI > 200) in current directory
bash compress_pdfs.sh

# Specify custom directory path
bash compress_pdfs.sh --path /path/to/documents --dry-run

# Custom DPI threshold and quality
bash compress_pdfs.sh --min-dpi 300 --quality screen

# Complete example with all options
bash compress_pdfs.sh --path /home/user/docs --dry-run --min-dpi 250 --quality ebook

# Show help
bash compress_pdfs.sh --help
```

## Dependencies

The script requires these external tools:
- **Ghostscript** (`gs`) - for PDF compression
- **ImageMagick** (`identify`) - for DPI detection  
- **Poppler** (`pdfinfo`) - for PDF metadata

Install on macOS: `brew install ghostscript imagemagick poppler`

## Architecture

### Core Script (`compress_pdfs.sh`)
- **Configuration**: Lines 7-13 define paths, DPI threshold, quality settings
- **Path Management**: `--path` option allows specifying custom base directory (defaults to current directory)
- **Directory Scanning**: Recursive search with progress feedback and statistics
- **Logging**: `log_message()` function provides timestamped logging
- **DPI Detection**: `get_pdf_dpi()` uses ImageMagick to extract DPI
- **Compression**: `compress_pdf()` uses Ghostscript with quality presets
- **Backup System**: `create_backup()` preserves originals before compression
- **Processing Pipeline**: `process_pdf()` orchestrates the full workflow
- **Error Handling**: Robust permission and file access error handling

### Quality Settings
- `screen` - 72 DPI, maximum compression
- `ebook` - 150 DPI, balanced quality/size (default)
- `printer` - 300 DPI, print quality
- `prepress` - 300 DPI, professional printing

### Safety Features
- Automatic backups in timestamped directories (`PDF_BACKUPS_YYYYMMDD_HHMMSS/`)
- Dry-run mode for safe testing
- Interactive confirmation for destructive operations
- Only replaces files with ≥5% size reduction
- Comprehensive error handling and logging

## File Structure

Generated files:
- `pdf_compression_YYYYMMDD_HHMMSS.log` - Detailed operation log
- `PDF_BACKUPS_YYYYMMDD_HHMMSS/` - Backup directory with original files

## Configuration

Key variables and options:
- `--path` - Root directory to scan (default: current directory)
- `--min-dpi` - Minimum DPI threshold (default: 200)
- `--quality` - Ghostscript quality preset (default: "ebook")
- `--dry-run` - Simulate operations without making changes

## Safety Notes

Always run with `--dry-run` first to preview changes. The script includes confirmation prompts for destructive operations and creates backups automatically.