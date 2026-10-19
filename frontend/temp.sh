#!/bin/bash

# ==============================================================================
# SCRIPT DE CRIAÇÃO DA ARQUITETURA FLUTTER (CLEAN ARCHITECTURE)
# ==============================================================================

# Nome da nossa feature principal
FEATURE="consulta_servidores"

echo "🚀 Iniciando a criação da estrutura de pastas do Padrão Ouro..."

# 1. CRIANDO A CAMADA CORE (Global do App)
echo "📁 Criando pastas Core..."
mkdir -p lib/core/theme
mkdir -p lib/core/network
mkdir -p lib/core/widgets

# 2. CRIANDO A CAMADA DOMAIN (Regras de negócio puras)
echo "📁 Criando pastas Domain da feature: $FEATURE..."
mkdir -p lib/features/$FEATURE/domain/entities
mkdir -p lib/features/$FEATURE/domain/repositories

# 3. CRIANDO A CAMADA DATA (Comunicação com API/Banco de Dados)
echo "📁 Criando pastas Data da feature: $FEATURE..."
mkdir -p lib/features/$FEATURE/data/models
mkdir -p lib/features/$FEATURE/data/datasources
mkdir -p lib/features/$FEATURE/data/repositories

# 4. CRIANDO A CAMADA PRESENTATION (Interface Visual / UI / Flutter)
echo "📁 Criando pastas Presentation da feature: $FEATURE..."
mkdir -p lib/features/$FEATURE/presentation/controllers
mkdir -p lib/features/$FEATURE/presentation/pages
mkdir -p lib/features/$FEATURE/presentation/widgets

# 5. DICA DE MESTRE: ADICIONANDO .gitkeep
# O comando abaixo encontra todas as pastas vazias dentro de 'lib/' 
# e cria um arquivo .gitkeep para garantir que o GitHub rastreie a pasta.
echo "🔒 Adicionando .gitkeep nas pastas vazias para versionamento no GitHub..."
find lib -type d -empty -exec touch {}/.gitkeep \;

echo "✅ Sucesso! Estrutura criada com excelência. Pode começar a codar!"
