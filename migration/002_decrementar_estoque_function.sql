-- Casa Gama — migração Firebase → Supabase
-- Função segura para o checkout público baixar 1 unidade de estoque
-- ao finalizar o pedido via WhatsApp, sem precisar de escrita direta
-- na tabela (que é restrita a usuários autenticados do Hub pelo RLS).
-- Rodar uma vez no SQL Editor do Supabase, depois de 001_add_codigo_column.sql.

create or replace function public.decrementar_estoque(p_codigo text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update casagama_produtos
  set quantidade_estoque = quantidade_estoque - 1,
      atualizado_em = now()
  where codigo = p_codigo and quantidade_estoque > 0;
end;
$$;

grant execute on function public.decrementar_estoque(text) to anon, authenticated;
