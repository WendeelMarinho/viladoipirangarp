-- Exemplos para popular a tabela `factions` (orp_main) no Vale do Ipiranga RP.
-- Tipos (coluna `type`) — ver oDashboard/faction/factionGlobal.lua:
--   1 = Forças de segurança
--   2 = Saúde
--   3 = Organização legal
--   4 = Gangue
--   5 = Máfia
--
-- Depois de importar: no servidor MTA executa `restart oDashboard` (ou reinicia o servidor)
-- para o `loadFactions()` recarregar as linhas.
--
-- Campos JSON devem ser JSON válido (o servidor usa fromJSON). Evita o valor literal 'false'
-- em ranks/members/dutys — isso partia o load.

USE orp_main;

INSERT INTO factions (
  name,
  type,
  money,
  ranks,
  vehicles,
  members,
  dutys,
  allowedDutyItems,
  allowedDutySkins,
  editDate,
  dutyPos,
  description
) VALUES
(
  'Polícia Civil - 17ª DP',
  1,
  0,
  '[["Posto padrao",0,1]]',
  'false',
  '[]',
  '["Plantao padrao",[],[]]',
  '[]',
  '[]',
  '2026.01.01 0:0',
  '[[]]',
  'Exemplo forcas de seguranca — ajusta nome e duty no painel F1 depois.'
),
(
  'Hospital Central',
  2,
  0,
  '[["Posto padrao",0,1]]',
  'false',
  '[]',
  '["Plantao padrao",[],[]]',
  '[]',
  '[]',
  '2026.01.01 0:0',
  '[[]]',
  'Exemplo saude.'
),
(
  'Governo Municipal',
  3,
  0,
  '[["Posto padrao",0,1]]',
  'false',
  '[]',
  '["Plantao padrao",[],[]]',
  '[]',
  '[]',
  '2026.01.01 0:0',
  '[[]]',
  'Exemplo organizacao legal.'
),
(
  'Gangue Exemplo',
  4,
  0,
  '[["Posto padrao",0,1]]',
  'false',
  '[]',
  '["Plantao padrao",[],[]]',
  '[]',
  '[]',
  '2026.01.01 0:0',
  '[[]]',
  'Exemplo gangue — renomeia e configura ranks no painel.'
),
(
  'Mafia Exemplo',
  5,
  0,
  '[["Posto padrao",0,1]]',
  'false',
  '[]',
  '["Plantao padrao",[],[]]',
  '[]',
  '[]',
  '2026.01.01 0:0',
  '[[]]',
  'Exemplo mafia.'
);

-- Ver IDs gerados:
-- SELECT id, name, type FROM factions ORDER BY id;
