-- Casa Gama — migração Firebase → Supabase
-- Adiciona a coluna de código interno (SKU), usada como identificador visível
-- no site, na etiqueta e na mensagem de WhatsApp (ex: CG-VA-001).
-- Rodar uma vez no SQL Editor do Supabase, no projeto do GAMA Hub.

alter table casagama_produtos
  add column if not exists codigo text unique;

create index if not exists casagama_produtos_codigo_idx on casagama_produtos (codigo);
