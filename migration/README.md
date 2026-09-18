# Migração Firebase → Supabase

Passo a passo, na ordem:

1. **Schema**: rodar, nesta ordem, no SQL Editor do Supabase (projeto do GAMA Hub):
   - `001_add_codigo_column.sql` — adiciona a coluna `codigo` (SKU) em `casagama_produtos`.
   - `002_decrementar_estoque_function.sql` — cria a função seguindo a qual o site público baixa 1 unidade de estoque no checkout, sem precisar de escrita direta na tabela.
2. **Dados já extraídos**: `casagama_produtos.json` (92 produtos) e `casagama_categorias.json` (11 categorias) foram gerados a partir do Firestore de produção em 2026-09-18, com a correção do bug histórico de categoria com "/" (`Colares-Esculturas` → nome `Colares/Esculturas`, slug `colares-esculturas`).
3. **Carga no Supabase**: rodar `migrate-to-supabase.ps1` com `SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` (a service_role, não a publishable) definidas como variável de ambiente. A service_role é necessária só para essa carga em massa única, porque ignora o RLS — não deve ser usada em nenhum outro lugar do site.
4. Depois de confirmar os dados no Supabase, preencher `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY` no bloco de configuração de `index.html` e `admin.html` (valores de `VITE_SUPABASE_URL` / `VITE_SUPABASE_PUBLISHABLE_KEY` do `.env`).
5. **Login do admin**: `admin.html` agora autentica com email/senha reais via Supabase Auth (usuário do Hub) — confirmar que a Mariane/Gabriela têm uma conta de usuário no projeto Supabase do Hub antes de testar.

`firestore-export.json` é o dump bruto do Firestore, mantido só para conferência/rollback caso algo precise ser reprocessado.
