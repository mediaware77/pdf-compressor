# Exemplos de Uso do PDF Compressor

Este documento contém exemplos práticos de como usar o script `compress_pdfs.sh`.

## Cenário 1: Primeira Execução - Teste Seguro

```bash
# Sempre comece com dry-run para entender o que será feito
./compress_pdfs.sh --dry-run
```

**Output esperado:**
```
=== COMPRESSOR DE PDFs ===
Diretório base:     /var/www/html/data/mediaware77/files_versions/SFTP/SAD
DPI mínimo:         200
Qualidade:          ebook
Modo dry-run:       true

Modo DRY-RUN ativado - nenhum arquivo será modificado
Buscando arquivos PDF...

Processando [1]: documento1.pdf
  DPI detectado: 300
  DPI 300 > 200 - Iniciando compressão...
DRY-RUN: Comprimiria documento1.pdf (2MB -> 456KB, -77%)

=== RELATÓRIO FINAL ===
Arquivos encontrados:    15
Arquivos processados:    12
Arquivos comprimidos:    0 (modo dry-run)
Arquivos pulados:        3
```

## Cenário 2: Configuração Personalizada

```bash
# Comprimir apenas PDFs com DPI muito alto, usando qualidade screen
./compress_pdfs.sh --dry-run --min-dpi 400 --quality screen
```

## Cenário 3: Execução Real após Teste

```bash
# 1. Testar primeiro
./compress_pdfs.sh --dry-run --min-dpi 250

# 2. Se satisfeito, executar a compressão real
./compress_pdfs.sh --min-dpi 250
```

**Confirmação interativa:**
```
ATENÇÃO: Este script irá modificar arquivos PDF!
Backups serão criados em: /caminho/PDF_BACKUPS_20250628_143052
Deseja continuar? (s/N): s
```

## Cenário 4: Diferentes Níveis de Qualidade

### Para documentos de visualização (máxima compressão)
```bash
./compress_pdfs.sh --quality screen --min-dpi 150
```

### Para documentos de arquivo (balanceado)
```bash
./compress_pdfs.sh --quality ebook --min-dpi 200
```

### Para documentos de impressão
```bash
./compress_pdfs.sh --quality printer --min-dpi 300
```

## Interpretando os Resultados

### Saída do Log
```
[2025-06-28 14:30:52] Iniciando compressão de PDFs
[2025-06-28 14:30:52] Parâmetros: MIN_DPI=200, QUALITY=ebook, DRY_RUN=false
[2025-06-28 14:30:55] Backup criado para: /caminho/documento.pdf
[2025-06-28 14:30:58] Comprimido: /caminho/documento.pdf (2MB -> 456KB, -77%)
[2025-06-28 14:31:02] Pulado (DPI baixo): /caminho/outro.pdf (DPI: 150)
[2025-06-28 14:31:05] Script finalizado
```

### Estrutura de Arquivos Após Execução
```
projeto/
├── compress_pdfs.sh
├── documento.pdf (comprimido)
├── outro.pdf (inalterado)
├── pdf_compression_20250628_143052.log
└── PDF_BACKUPS_20250628_143052/
    └── documento.pdf (backup original)
```

## Casos de Uso Comuns

### 1. Preparar PDFs para Email
```bash
# Máxima compressão para envio por email
./compress_pdfs.sh --quality screen --min-dpi 100
```

### 2. Otimizar Arquivo Digital
```bash
# Balanceado para armazenamento digital
./compress_pdfs.sh --quality ebook --min-dpi 150
```

### 3. Processar apenas PDFs de Alta Resolução
```bash
# Focar apenas em PDFs realmente grandes
./compress_pdfs.sh --min-dpi 400 --quality ebook
```

## Recuperação de Backups

Se precisar restaurar um arquivo original:

```bash
# Localizar o backup
ls PDF_BACKUPS_*/

# Restaurar arquivo específico
cp PDF_BACKUPS_20250628_143052/caminho/documento.pdf ./documento.pdf
```

## Automatização

### Script para Execução Diária
```bash
#!/bin/bash
# auto_compress.sh

LOG_DIR="/var/log/pdf-compressor"
mkdir -p "$LOG_DIR"

# Executar compressão automática
./compress_pdfs.sh --min-dpi 300 --quality ebook > "$LOG_DIR/daily_$(date +%Y%m%d).log" 2>&1

# Limpar backups antigos (opcional - manter apenas 7 dias)
find . -name "PDF_BACKUPS_*" -type d -mtime +7 -exec rm -rf {} \;
```

### Cron Job
```bash
# Adicionar ao crontab para execução semanal às 2h da manhã de domingo
0 2 * * 0 /caminho/para/auto_compress.sh
```

## Monitoramento

### Verificar Economia de Espaço
```bash
# Comparar tamanhos antes e depois
du -sh PDF_BACKUPS_*/  # Tamanho original
du -sh *.pdf          # Tamanho atual
```

### Análise de Logs
```bash
# Ver estatísticas de uma execução
grep "RELATÓRIO FINAL" pdf_compression_*.log -A 10

# Ver todos os arquivos comprimidos
grep "Comprimido:" pdf_compression_*.log
```

## Dicas de Performance

1. **Execute dry-run primeiro** - sempre!
2. **Monitore o espaço em disco** - backups ocupam espaço
3. **Ajuste o DPI mínimo** - conforme suas necessidades
4. **Use quality screen** - para máxima economia
5. **Limpe backups antigos** - regularmente

## Solução de Problemas Comuns

### Erro de Permissão
```bash
chmod +x compress_pdfs.sh
```

### Falta de Dependências
```bash
# Verificar se Ghostscript está instalado
gs --version

# Verificar ImageMagick
identify --version
```

### PDFs Corrompidos
O script automaticamente pula arquivos que não podem ser processados e registra no log.