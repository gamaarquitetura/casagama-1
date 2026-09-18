# Migração Firebase → Supabase

O banco do Hub não é um projeto Supabase com login próprio em supabase.com — é o **Lovable Cloud** (backend nativo do Lovable, construído sobre Supabase), gerenciado inteiramente dentro do painel do projeto no Lovable. O Lovable Cloud já tem seu próprio SQL Editor, então todo o passo a passo abaixo é feito ali, sem precisar de nenhuma chave sensível (`service_role`).

Passo a passo, na ordem, dentro do Lovable Cloud → aba **SQL editor**:

1. Rodar `001_add_codigo_column.sql` — adiciona a coluna `codigo` (SKU) em `casagama_produtos`.
2. Rodar `002_decrementar_estoque_function.sql` — cria a função que o site público usa pra baixar 1 unidade de estoque no checkout, sem precisar de escrita direta na tabela.
3. Rodar `003_load_data.sql` — carrega as 11 categorias e os 92 produtos reais, extraídos do Firestore de produção em 2026-09-18, já com a correção do bug histórico de categoria com "/" (`Colares-Esculturas` → nome `Colares/Esculturas`, slug `colares-esculturas`). Os `on conflict ... do nothing` fazem o script ser seguro de rodar mais de uma vez sem duplicar nada.
4. Pegar `VITE_SUPABASE_URL` e `VITE_SUPABASE_PUBLISHABLE_KEY` na aba **Secrets** do Lovable Cloud e preencher no bloco de configuração de `index.html` e `admin.html` (procurar por `COLOQUE_AQUI_...`).
5. **Login do admin**: `admin.html` agora autentica com email/senha reais via Supabase Auth (usuário do Hub) — confirmar que a Mariane/Gabriela têm uma conta de usuário cadastrada antes de testar.

`casagama_categorias.json` / `casagama_produtos.json` / `firestore-export.json` são os dados brutos e transformados, mantidos só para conferência/rollback caso algo precise ser reprocessado. `migrate-to-supabase.ps1` era uma alternativa via API REST (precisava da `service_role` key) para o caso de a Casa Gama migrar no futuro para um projeto Supabase independente do Lovable Cloud — não é necessário no caminho atual, mas fica guardado caso essa mudança estrutural aconteça.
