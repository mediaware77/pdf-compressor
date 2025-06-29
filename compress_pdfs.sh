#!/bin/bash

# Script para compressao de PDFs com DPI > 200
# Autor: Sistema automatizado

# Configuracoes
BASE_DIR="$(pwd)"  # Padrao: diretorio atual
BACKUP_DIR="${BASE_DIR}/PDF_BACKUPS_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="${BASE_DIR}/pdf_compression_$(date +%Y%m%d_%H%M%S).log"
MIN_DPI=200
DRY_RUN=false
COMPRESS_QUALITY="ebook"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Contadores
TOTAL_FILES=0
PROCESSED_FILES=0
COMPRESSED_FILES=0
SKIPPED_FILES=0
TOTAL_SIZE_BEFORE=0
TOTAL_SIZE_AFTER=0
DIRECTORIES_WITH_PDFS=0

# Funcao de logging
log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" | tee -a "$LOG_FILE"
}

# Funcao para exibir uso
show_usage() {
    echo "Uso: $0 [opcoes]"
    echo ""
    echo "Opcoes:"
    echo "  --path <diretorio> Diretorio base para buscar PDFs (padrao: diretorio atual)"
    echo "  --dry-run          Simular sem modificar arquivos"
    echo "  --min-dpi <valor>  DPI minimo para compressao (padrao: 200)"
    echo "  --quality <valor>  Qualidade: screen, ebook, printer, prepress (padrao: ebook)"
    echo "  --help             Mostrar esta ajuda"
    echo ""
    echo "Exemplo:"
    echo "  $0 --path /caminho/documentos --dry-run --min-dpi 300 --quality screen"
}

# Funcao para obter DPI de um PDF
get_pdf_dpi() {
    local file="$1"
    local dpi_info
    
    # Usar ImageMagick para obter DPI
    dpi_info=$(identify -ping -format "%x" "$file[0]" 2>/dev/null | grep -o '^[0-9]*')
    
    if [[ -n "$dpi_info" && "$dpi_info" =~ ^[0-9]+$ ]]; then
        echo "$dpi_info"
    else
        echo "0"
    fi
}

# Funcao para obter tamanho do arquivo em bytes
get_file_size() {
    local file="$1"
    stat -c%s "$file" 2>/dev/null || echo "0"
}

# Funcao para formatar tamanho em formato legivel
format_size() {
    local size=$1
    if [ $size -gt 1073741824 ]; then
        echo "$(( size / 1073741824 ))GB"
    elif [ $size -gt 1048576 ]; then
        echo "$(( size / 1048576 ))MB"
    elif [ $size -gt 1024 ]; then
        echo "$(( size / 1024 ))KB"
    else
        echo "${size}B"
    fi
}

# Funcao para criar backup
create_backup() {
    local file="$1"
    local backup_file="$BACKUP_DIR/${file#$BASE_DIR/}"
    local backup_dir=$(dirname "$backup_file")
    
    mkdir -p "$backup_dir"
    cp "$file" "$backup_file"
    return $?
}

# Funcao para comprimir PDF
compress_pdf() {
    local input_file="$1"
    local output_file="${input_file}.compressed"
    local original_size=$(get_file_size "$input_file")
    
    # Comprimir usando Ghostscript
    gs -sDEVICE=pdfwrite \
       -dCompatibilityLevel=1.4 \
       -dPDFSETTINGS=/$COMPRESS_QUALITY \
       -dNOPAUSE \
       -dQUIET \
       -dBATCH \
       -sOutputFile="$output_file" \
       "$input_file" 2>/dev/null
    
    if [ $? -eq 0 ] && [ -f "$output_file" ]; then
        local compressed_size=$(get_file_size "$output_file")
        
        # Verificar se houve reducao significativa (pelo menos 5%)
        local reduction_percent=$(( (original_size - compressed_size) * 100 / original_size ))
        
        if [ $reduction_percent -ge 5 ]; then
            if [ "$DRY_RUN" = false ]; then
                # Substituir arquivo original
                mv "$output_file" "$input_file"
                log_message "Comprimido: ${input_file} ($(format_size $original_size) -> $(format_size $compressed_size), -${reduction_percent}%)"
                TOTAL_SIZE_BEFORE=$((TOTAL_SIZE_BEFORE + original_size))
                TOTAL_SIZE_AFTER=$((TOTAL_SIZE_AFTER + compressed_size))
                ((COMPRESSED_FILES++))
            else
                rm -f "$output_file"
                log_message "DRY-RUN: Comprimiria ${input_file} ($(format_size $original_size) -> $(format_size $compressed_size), -${reduction_percent}%)"
            fi
        else
            rm -f "$output_file"
            log_message "Pulado (reducao insuficiente): ${input_file} (reducao: ${reduction_percent}%)"
            ((SKIPPED_FILES++))
        fi
    else
        rm -f "$output_file"
        log_message "ERRO: Falha ao comprimir ${input_file}"
        ((SKIPPED_FILES++))
    fi
}

# Funcao para processar um arquivo PDF
process_pdf() {
    local file="$1"
    ((TOTAL_FILES++))
    
    echo -e "${BLUE}Processando [$TOTAL_FILES]: $(basename "$file")${NC}"
    
    # Verificar se o arquivo existe e e legivel
    if [ ! -r "$file" ]; then
        log_message "ERRO: Arquivo nao legivel: $file"
        ((SKIPPED_FILES++))
        return
    fi
    
    # Obter DPI do arquivo
    local dpi=$(get_pdf_dpi "$file")
    
    if [ "$dpi" -eq 0 ]; then
        log_message "AVISO: Nao foi possivel determinar DPI de: $file"
        ((SKIPPED_FILES++))
        return
    fi
    
    echo -e "  DPI detectado: ${dpi}"
    
    # Verificar se DPI e maior que o minimo
    if [ "$dpi" -gt "$MIN_DPI" ]; then
        echo -e "  ${YELLOW}DPI $dpi > $MIN_DPI - Iniciando compressao...${NC}"
        
        if [ "$DRY_RUN" = false ]; then
            # Criar backup antes de comprimir
            if create_backup "$file"; then
                log_message "Backup criado para: $file"
            else
                log_message "ERRO: Falha ao criar backup para: $file"
                ((SKIPPED_FILES++))
                return
            fi
        fi
        
        # Comprimir arquivo
        compress_pdf "$file"
        ((PROCESSED_FILES++))
    else
        echo -e "  ${GREEN}DPI $dpi <= $MIN_DPI - Pulando arquivo${NC}"
        log_message "Pulado (DPI baixo): $file (DPI: $dpi)"
        ((SKIPPED_FILES++))
    fi
}

# Funcao para exibir relatorio final
show_report() {
    echo ""
    echo -e "${GREEN}=== RELATORIO FINAL ===${NC}"
    echo -e "Diretorios analisados:   ${TOTAL_DIRS_WITH_PDFS:-0}"  
    echo -e "Arquivos encontrados:    ${TOTAL_FILES}"
    echo -e "Arquivos processados:    ${PROCESSED_FILES}"
    echo -e "Arquivos comprimidos:    ${COMPRESSED_FILES}"
    echo -e "Arquivos pulados:        ${SKIPPED_FILES}"
    
    if [ $COMPRESSED_FILES -gt 0 ] && [ "$DRY_RUN" = false ]; then
        local total_saved=$((TOTAL_SIZE_BEFORE - TOTAL_SIZE_AFTER))
        local percent_saved=$(( total_saved * 100 / TOTAL_SIZE_BEFORE ))
        echo -e "Espaco economizado:      $(format_size $total_saved) (${percent_saved}%)"
        echo -e "Tamanho antes:           $(format_size $TOTAL_SIZE_BEFORE)"
        echo -e "Tamanho depois:          $(format_size $TOTAL_SIZE_AFTER)"
    fi
    
    echo -e "Log salvo em:            ${LOG_FILE}"
    if [ "$DRY_RUN" = false ] && [ $COMPRESSED_FILES -gt 0 ]; then
        echo -e "Backups salvos em:       ${BACKUP_DIR}"
    fi
    echo ""
}

# Funcao para limpeza em caso de interrupcao
cleanup() {
    echo ""
    echo -e "${RED}Script interrompido pelo usuario${NC}"
    show_report
    exit 1
}

# Configurar trap para Ctrl+C
trap cleanup SIGINT SIGTERM

# Processar argumentos da linha de comando
while [[ $# -gt 0 ]]; do
    case $1 in
        --path)
            BASE_DIR="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --min-dpi)
            MIN_DPI="$2"
            shift 2
            ;;
        --quality)
            COMPRESS_QUALITY="$2"
            shift 2
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            echo "Opcao desconhecida: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validar parametros
if ! [[ "$MIN_DPI" =~ ^[0-9]+$ ]] || [ "$MIN_DPI" -lt 50 ] || [ "$MIN_DPI" -gt 1200 ]; then
    echo -e "${RED}ERRO: MIN_DPI deve ser um numero entre 50 e 1200${NC}"
    exit 1
fi

if [[ ! "$COMPRESS_QUALITY" =~ ^(screen|ebook|printer|prepress)$ ]]; then
    echo -e "${RED}ERRO: Qualidade deve ser: screen, ebook, printer ou prepress${NC}"
    exit 1
fi

# Validar e normalizar BASE_DIR
if [ ! -d "$BASE_DIR" ]; then
    echo -e "${RED}ERRO: Diretorio nao encontrado: $BASE_DIR${NC}"
    exit 1
fi

# Converter para caminho absoluto
BASE_DIR="$(cd "$BASE_DIR" && pwd)"

# Reconfigurar caminhos de backup e log baseados no BASE_DIR final
BACKUP_DIR="${BASE_DIR}/PDF_BACKUPS_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="${BASE_DIR}/pdf_compression_$(date +%Y%m%d_%H%M%S).log"

# Inicializar
echo -e "${BLUE}=== COMPRESSOR DE PDFs ===${NC}"
echo -e "Diretorio base:     $BASE_DIR"
echo -e "DPI minimo:         $MIN_DPI"
echo -e "Qualidade:          $COMPRESS_QUALITY"
echo -e "Modo dry-run:       $DRY_RUN"
echo ""

if [ "$DRY_RUN" = false ]; then
    echo -e "${YELLOW}ATENCAO: Este script ira modificar arquivos PDF!${NC}"
    echo -e "${YELLOW}Backups serao criados em: $BACKUP_DIR${NC}"
    echo ""
    read -p "Deseja continuar? (s/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "Operacao cancelada pelo usuario."
        exit 0
    fi
else
    echo -e "${GREEN}Modo DRY-RUN ativado - nenhum arquivo sera modificado${NC}"
fi

# Criar diretorio de backup se necessario
if [ "$DRY_RUN" = false ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Inicializar log
log_message "Iniciando compressao de PDFs"
log_message "Parametros: MIN_DPI=$MIN_DPI, QUALITY=$COMPRESS_QUALITY, DRY_RUN=$DRY_RUN"

echo -e "${BLUE}Analisando estrutura de diretorios...${NC}"

# Contar diretorios com PDFs (compativel com BSD e GNU find)
# Redirecionar stderr para capturar erros de permissao
FIND_ERRORS=$(mktemp)
TOTAL_DIRS_WITH_PDFS=$(find "$BASE_DIR" -iname "*.pdf" -type f -exec dirname {} \; 2>"$FIND_ERRORS" | sort -u | wc -l)

# Verificar se houve erros de permissao
if [ -s "$FIND_ERRORS" ]; then
    echo -e "${YELLOW}AVISO: Alguns diretorios nao puderam ser acessados (permissoes)${NC}"
    log_message "Avisos de permissao durante busca: $(cat "$FIND_ERRORS" | wc -l) diretorios inacessiveis"
fi
rm -f "$FIND_ERRORS"

if [ "$TOTAL_DIRS_WITH_PDFS" -gt 0 ]; then
    echo -e "Encontrados PDFs em $TOTAL_DIRS_WITH_PDFS diretorios"
    log_message "Estrutura: $TOTAL_DIRS_WITH_PDFS diretorios contem arquivos PDF"
else
    echo -e "${YELLOW}Nenhum arquivo PDF encontrado no diretorio especificado${NC}"
    log_message "Nenhum PDF encontrado em: $BASE_DIR"
    show_report
    exit 0
fi

echo -e "${BLUE}Processando arquivos PDF...${NC}"

# Processar todos os arquivos PDF
CURRENT_DIR=""
FIND_ERRORS_MAIN=$(mktemp)

while IFS= read -r -d '' file; do
    # Verificar se o arquivo ainda existe e e legivel
    if [ ! -r "$file" ]; then
        log_message "AVISO: Arquivo nao legivel ignorado: $file"
        continue
    fi
    
    # Mostrar progresso por diretorio
    FILE_DIR=$(dirname "$file")
    if [ "$FILE_DIR" != "$CURRENT_DIR" ]; then
        CURRENT_DIR="$FILE_DIR"
        ((DIRECTORIES_WITH_PDFS++))
        # Mostrar caminho relativo se possivel
        RELATIVE_DIR="${FILE_DIR#$BASE_DIR}"
        [ "$RELATIVE_DIR" = "$FILE_DIR" ] && RELATIVE_DIR="$FILE_DIR" || RELATIVE_DIR="${RELATIVE_DIR#/}"
        [ -z "$RELATIVE_DIR" ] && RELATIVE_DIR="." 
        echo -e "${BLUE}Processando diretorio [$DIRECTORIES_WITH_PDFS/$TOTAL_DIRS_WITH_PDFS]: $RELATIVE_DIR${NC}"
        log_message "Processando diretorio: $FILE_DIR"
    fi
    process_pdf "$file"
done < <(find "$BASE_DIR" -iname "*.pdf" -type f -print0 2>"$FIND_ERRORS_MAIN" | sort -z)

# Verificar erros do find principal
if [ -s "$FIND_ERRORS_MAIN" ]; then
    log_message "Erros durante processamento: $(cat "$FIND_ERRORS_MAIN")"
fi
rm -f "$FIND_ERRORS_MAIN"

# Exibir relatorio final
show_report

log_message "Script finalizado"

echo -e "${GREEN}Processamento concluido!${NC}"