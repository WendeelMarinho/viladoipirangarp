--[[ oWelcome — conteúdo estático PT-BR ]]

WELCOME_SHORTCUTS = {
	{ "F1", "Painel principal (stats, facção, configurações)" },
	{ "F2", "Inventário" },
	{ "F4", "Telefone" },
	{ "Tab", "Jogadores online" },
	{ "T", "Chat IC normal" },
	{ "Y", "Twitter IC (feed de posts)" },
	{ "U", "Deep Web IC (anónimo, terminal 404.onion)" },
	{ "Escape", "Fechar Twitter / Deep Web / feed (IpirangaTweets)" },
	{ "Backspace", "Fechar outros painéis (conforme recurso)" },
}

WELCOME_COMMANDS = {
	{ "/duty", "Entrar/sair de serviço na facção" },
	{ "/rank", "Ranking do servidor" },
	{ "/seguro", "Acionar seguro do veículo roubado" },
	{ "/twitter", "Abrir/fechar feed IpirangaTweets" },
	{ "/planosvip", "Resumo dos níveis VIP (chat)" },
	{ "/planossocio", "Resumo dos níveis Sócio (chat)" },
	{ "/meuvip", "Ver estado VIP / Sócio e tempo restante" },
	{ "/cv [modelo]", "Criar veículo (VIP Ipiranga ou Sócio Patrocinador; máx. 5/dia)" },
	{ "/pskin [id]", "Mudar skin (VIP Omega+ ou Sócio Ouro+)" },
	{ "/vipheal /viparmor /viprepair", "Kits VIP (cooldowns 1 min)" },
	{ "/tunning", "Tuning cosmético no veículo (Omega+ / Sócio Ouro+; CD 2 min; precisa dude_scripts)" },
	{ "/spectar [jogador]", "Pedir espectador IC (Patrocinador / VIP Ipiranga) — alvo: /aceitarspectar" },
	{ "/parspectar", "Sair do modo espectador VIP" },
	{ "/tpp [jogador]", "Pedir teleporte até alguém — alvo: /aceitartpp" },
	{ "/tppa [jogador]", "Pedir que venham até ti — alvo: /aceitarpull" },
	{ "/ajuda", "Reabrir este guia" },
	{ "/welcome", "Reabrir este guia" },
	{ "/me", "Ação em terceira pessoa (proximidade)" },
	{ "/do", "Descrição de ambiente" },
	{ "/b", "OOC local (20 m)" },
	{ "/w", "Sussurro (5 m)" },
}

--[[ Texto da aba Informações (estático); notícias vêm da DB no payload ]]
WELCOME_ABOUT_TEXT = [[
Bem-vindo ao Ipiranga Roleplay — ambiente narrativo focado em São Paulo.

• Respeita a hierarquia IC e as regras do servidor.
• Usa o Twitter IC (Y) e o chat normal (T) para comunicação coerente.
• Facções legais e ilegais têm mecânicas próprias; explora o painel (F1).

Dúvidas? Usa /ajuda para voltar a este painel.
]]

--[[ name, url, r,g,b — URL copiado ao clicar ]]
WELCOME_SOCIAL_LINKS = {
	{ name = "Discord", url = "https://discord.gg/ipiranga-rp", r = 88, g = 101, b = 242 },
	{ name = "Instagram", url = "https://instagram.com/", r = 225, g = 48, b = 108 },
	{ name = "YouTube", url = "https://youtube.com/", r = 255, g = 0, b = 0 },
	{ name = "TikTok", url = "https://tiktok.com/", r = 105, g = 201, b = 208 },
}
