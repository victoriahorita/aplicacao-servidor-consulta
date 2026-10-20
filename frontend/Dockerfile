# Google maldito não coloca a versão oficial no Docker Hub
FROM debian:bookworm-slim AS build

# 1. Instala ferramentas essenciais do sistema
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    && rm -rf /var/lib/apt/lists/*

# 2. Baixa a versão estável oficial direto do repositório do Google 
RUN git clone --depth 1 -b stable https://github.com/flutter/flutter.git /flutter

# 3. Adiciona o Flutter e o Dart ao PATH do Linux
ENV PATH="/flutter/bin:${PATH}"

# 4. Configuração de segurança do Git e pré-carregamento dos binários da Web
RUN git config --global --add safe.directory /flutter \
    && flutter precache --web

WORKDIR /app

# 5. Copia as dependências e resolve os pacotes
COPY pubspec.yaml ./
RUN flutter pub get

# 6. Copia todo o código-fonte da aplicação
COPY . .

# 7. Compila para Web com a URL da API 
ARG API_BASE_URL=http://localhost:3000
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

# Servidor Nginx de Produção ( Otimização para a versão web compilada do Flutter )
FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]