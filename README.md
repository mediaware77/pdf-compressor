# PDF Compressor 📄⚡

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/shell_script-bash-green.svg)](https://www.gnu.org/software/bash/)
[![PDF](https://img.shields.io/badge/PDF-compression-red.svg)](https://www.adobe.com/acrobat/about-adobe-pdf.html)

Script automatizado e inteligente para compressão de arquivos PDF com DPI superior a um valor mínimo especificado.

> 🎯 **Economia de até 92% no tamanho dos arquivos** com compressão inteligente baseada em DPI

## Funcionalidades

- ✅ Varre recursivamente todos os diretórios em busca de arquivos PDF
- ✅ Detecta DPI automaticamente usando ImageMagick
- ✅ Comprime apenas PDFs com DPI acima do limite configurado
- ✅ Cria backups automáticos antes da compressão
- ✅ Substitui arquivo original apenas se houve redução significativa (≥5%)
- ✅ Logging detalhado com timestamp
- ✅ Modo dry-run para simulação
- ✅ Relatório final com estatísticas de economia

## 🚀 Instalação

### Pré-requisitos

Instale as ferramentas necessárias:

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install ghostscript imagemagick poppler-utils
```

**CentOS/RHEL:**
```bash
sudo yum install ghostscript ImageMagick poppler-utils
```

**macOS:**
```bash
brew install ghostscript imagemagick poppler
```

### Download do Script

```bash
wget https://github.com/mediaware77/pdf-compressor/raw/main/compress_pdfs.sh
chmod +x compress_pdfs.sh
```

## 📖 Uso Básico

```bash
# Executar com configurações padrão (DPI > 200)
bash compress_pdfs.sh

# Modo dry-run (simular sem modificar arquivos)
bash compress_pdfs.sh --dry-run

# Configurar DPI mínimo personalizado
bash compress_pdfs.sh --min-dpi 300

# Configurar qualidade de compressão
bash compress_pdfs.sh --quality screen

# Exemplo completo
bash compress_pdfs.sh --dry-run --min-dpi 150 --quality ebook
```

## ⚙️ Opções de Linha de Comando

| Opção | Descrição | Valores | Padrão |
|-------|-----------|---------|---------|
| `--dry-run` | Simular sem modificar arquivos | - | false |
| `--min-dpi <valor>` | DPI mínimo para compressão | 50-1200 | 200 |
| `--quality <valor>` | Nível de qualidade | screen, ebook, printer, prepress | ebook |
| `--help` | Mostrar ajuda | - | - |

## 🎚️ Níveis de Qualidade

- **screen** - Máxima compressão (72 DPI) - ideal para visualização
- **ebook** - Boa compressão (150 DPI) - equilibrio entre qualidade e tamanho
- **printer** - Qualidade média (300 DPI) - para impressão
- **prepress** - Alta qualidade (300 DPI) - para impressão profissional

## 📊 Resultados de Performance

Resultados do teste executado em 28/06/2025:

```
=== RELATÓRIO FINAL ===
Arquivos encontrados:    22
Arquivos processados:    20
Arquivos comprimidos:    0 (modo dry-run)
Arquivos pulados:        5

Exemplos de compressão detectada:
- SOLICITAÇÃO ATA 012.pdf: 1MB → 92KB (-92%)
- NEGATIVA DA CSBRASIL.pdf: 721KB → 268KB (-62%)
- PROPOSTA 01 - IBYTE.pdf: 1MB → 348KB (-74%)
```

## 🔒 Segurança

- ✅ **Backups automáticos**: Todos os arquivos originais são salvos antes da compressão
- ✅ **Validação**: Arquivos só são substituídos se a compressão foi bem-sucedida
- ✅ **Redução mínima**: Só substitui se houver pelo menos 5% de redução
- ✅ **Logs detalhados**: Registro completo de todas as operações

## 📁 Estrutura de Backup

```
PDF_BACKUPS_YYYYMMDD_HHMMSS/
├── LOGISTICA/
│   └── PASTAS 2025/
│       └── [arquivos_originais]
└── GCP/
    └── [outros_arquivos]
```

## 📝 Arquivos de Log

- **Nome**: `pdf_compression_YYYYMMDD_HHMMSS.log`
- **Localização**: Mesmo diretório do script
- **Conteúdo**: Timestamp, operações, erros, estatísticas

## 🔧 Solução de Problemas

### Erro: "Não foi possível determinar DPI"
- PDF pode estar corrompido ou ter formato não suportado
- Arquivo será pulado automaticamente

### Erro: "Redução insuficiente"
- PDF já está otimizado
- Arquivo será mantido sem alterações

### Interrupção do Script
- Use Ctrl+C para interromper
- Relatório parcial será exibido
- Backups já criados serão preservados

## 🎯 Exemplo de Execução Real

Para executar a compressão real (CUIDADO - irá modificar arquivos):

```bash
# 1. Primeiro, sempre teste em dry-run
bash compress_pdfs.sh --dry-run

# 2. Se satisfeito com os resultados, execute a compressão
bash compress_pdfs.sh

# O script pedirá confirmação antes de prosseguir
```

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Distribuído sob a licença MIT. Veja `LICENSE` para mais informações.

## 🆘 Suporte

Se você encontrar problemas ou tiver sugestões:

- Abra uma [issue](https://github.com/seu-usuario/pdf-compressor/issues)
- Contribua com melhorias via Pull Request

---

**⚠️ IMPORTANTE**: Sempre execute em modo `--dry-run` primeiro para verificar quais arquivos serão afetados antes de executar a compressão real.

**Made with ❤️ for efficient PDF management**
