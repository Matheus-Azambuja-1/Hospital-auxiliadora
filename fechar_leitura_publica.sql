-- ════════════════════════════════════════════════════════════════
-- PASSO 2 (NÃO EXECUTADO) — só rode depois de publicar no GitHub:
--   axon-guard.js, pc.html e index.html novos.
-- Faz o catálogo (preços, composições, custos) exigir login + módulo "Pacotes".
-- Não apaga nem altera nenhum dado: só troca regras de acesso.
-- Para desfazer, o final do arquivo traz o ROLLBACK (volta ao acesso público).
-- ════════════════════════════════════════════════════════════════
begin;

-- composições: de "público" para "logado com módulo Pacotes"
drop policy if exists "leitura publica" on public.composicoes;
drop policy if exists "leitura publica" on public.composicao_secoes;
drop policy if exists "leitura publica" on public.composicao_itens;
create policy "pacotes le" on public.composicoes       for select to authenticated using (public.tem_modulo('pacotes'));
create policy "pacotes le" on public.composicao_secoes for select to authenticated using (public.tem_modulo('pacotes'));
create policy "pacotes le" on public.composicao_itens  for select to authenticated using (public.tem_modulo('pacotes'));

-- tabelas por trás das views: leitura para quem tem o módulo
create policy "pacotes le" on public.pacotes        for select to authenticated using (ativo and public.tem_modulo('pacotes'));
create policy "pacotes le" on public.pacote_precos  for select to authenticated using (public.tem_modulo('pacotes'));
create policy "pacotes le" on public.tabelas_preco  for select to authenticated using (public.tem_modulo('pacotes'));

-- views passam a respeitar quem consulta (e deixam de ser públicas)
alter view public.pacotes_vigentes set (security_invoker = true);
alter view public.pacotes_versao   set (security_invoker = true);
revoke select on public.pacotes_vigentes, public.pacotes_versao from anon;
revoke select on public.composicoes, public.composicao_secoes, public.composicao_itens from anon;

commit;

-- ── ROLLBACK (só se precisar voltar ao acesso público) ──
-- begin;
-- drop policy "pacotes le" on public.composicoes;       create policy "leitura publica" on public.composicoes       for select to anon, authenticated using (true);
-- drop policy "pacotes le" on public.composicao_secoes; create policy "leitura publica" on public.composicao_secoes for select to anon, authenticated using (true);
-- drop policy "pacotes le" on public.composicao_itens;  create policy "leitura publica" on public.composicao_itens  for select to anon, authenticated using (true);
-- drop policy "pacotes le" on public.pacotes; drop policy "pacotes le" on public.pacote_precos; drop policy "pacotes le" on public.tabelas_preco;
-- alter view public.pacotes_vigentes set (security_invoker = false); alter view public.pacotes_versao set (security_invoker = false);
-- grant select on public.pacotes_vigentes, public.pacotes_versao, public.composicoes, public.composicao_secoes, public.composicao_itens to anon;
-- commit;
