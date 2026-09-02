# Controle do Marceneiro — PWA

Sistema responsivo para registrar serviços e acompanhar a produção diária, semanal e mensal nas categorias **Serviços Paraíba** e **Pessoais**.

## Publicar no GitHub Pages

1. Envie todos os arquivos deste pacote para a raiz do repositório.
2. No GitHub, abra **Settings**.
3. Entre em **Pages**.
4. Em **Build and deployment**, escolha **Deploy from a branch**.
5. Selecione a branch **main** e a pasta **/(root)**.
6. Clique em **Save**.
7. Aguarde o GitHub gerar o endereço do site.

## Instalar no iPhone

1. Abra o endereço publicado no Safari.
2. Toque em **Compartilhar**.
3. Escolha **Adicionar à Tela de Início**.
4. Toque em **Adicionar**.

## Arquivos principais

- `index.html`: sistema completo com frontend e versão mobile.
- `manifest.webmanifest`: configurações de instalação do PWA.
- `sw.js`: funcionamento offline e cache do aplicativo.
- `icon-192.png`, `icon-512.png` e `apple-touch-icon.png`: ícones do aplicativo.

## Estado atual dos dados

Esta versão salva os serviços no navegador usando armazenamento local. A próxima etapa é conectar o projeto ao Supabase para permitir login, backup e sincronização entre celular e computador.
