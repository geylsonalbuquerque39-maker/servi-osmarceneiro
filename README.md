# Controle do Marceneiro — PWA

Sistema responsivo para registrar serviços e acompanhar a produção diária, semanal e mensal nas categorias **Serviços Paraíba** e **Pessoais**. Esta versão possui login, banco de dados Supabase e sincronização entre aparelhos.

## Preparar o Supabase

1. Abra o projeto no Supabase.
2. Entre em **SQL Editor**.
3. Clique em **New query**.
4. Abra o arquivo `SUPABASE_SETUP.sql`, copie todo o conteúdo e cole no editor.
5. Clique em **Run**.
6. Em **Authentication > URL Configuration**, use como **Site URL**:
   `https://geylsonalbuquerque39-maker.github.io/servi-osmarceneiro/`
7. Depois de publicar os arquivos, abra o aplicativo e clique em **Criar primeira conta**.

O banco usa Row Level Security. Cada conta acessa somente os próprios serviços.

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
- `SUPABASE_SETUP.sql`: cria a tabela, as regras de segurança e a sincronização no Supabase.
- `manifest.webmanifest`: configurações de instalação do PWA.
- `sw.js`: funcionamento offline e cache do aplicativo.
- `icon-192.png`, `icon-512.png` e `apple-touch-icon.png`: ícones do aplicativo.

## Dados e segurança

Os dados principais ficam no Supabase. O navegador mantém uma cópia local dos últimos serviços para consulta quando a conexão cair. A chave presente no `index.html` é a chave pública do projeto; nunca coloque uma chave `secret` ou `service_role` no GitHub.
