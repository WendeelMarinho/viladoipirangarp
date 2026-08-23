--[[
  Ipiranga RP — definição de produtos VIP (30 dias) e Sócios (ciclos curtos).
  Isto é a «fonte de verdade» para loja/site/discord e para futuros checks em servidor
  (ex.: elementData char:vip_tier / char:socio_tier + Unix expiração).

  Nota de desenho:
  - 3 níveis VIP: Sigma < Omega < Ipiranga (benefícios escalonados; alinhar com economia real).
  - 3 níveis Sócio: entrada / intermédio / Patrocinador (último espelha o pacote mais completo que descreveste).
  - Comandos (/cv, /spectar, …) devem validar tier + cooldown noutro recurso — aqui só listamos o «contrato» do produto.
]]

IPiranga_ECON_LABELS = {
	ppLong = "Pontos Plus",
	ppShort = "IP+",
	ccLong = "Fichas cassino",
	ccShort = "FC",
}

--[[ Campos por entrada: id, line ("vip"|"socio"), name, durationDays, activationCash, hourlySalary, benefits[] ]]

IPiranga_VIP_TIERS = {
	{
		id = "vip_sigma",
		line = "vip",
		name = "VIP Sigma",
		durationDays = 30,
		activationCash = 800000,
		hourlySalary = 15000,
		benefits = {
			"Kit de vida (cooldown 1 min).",
			"Kit de colete (cooldown 1 min).",
			"Veículos reservados: Silvia S15, Impreza STI, Tiger 800 (spawn onde permitido pelo anti-abuso).",
			"3 personagens exclusivos · 2 acessórios · 3 armas (MP5, M4, Colt 45).",
			"RGB veículo / farol · Tag exclusiva (jogo + Discord).",
			"Acesso /criarloja (quando o recurso estiver ativo e com regras IC).",
		},
	},
	{
		id = "vip_omega",
		line = "vip",
		name = "VIP Omega",
		durationDays = 30,
		activationCash = 1000000,
		hourlySalary = 30000,
		benefits = {
			"Tudo do Sigma + blindagem (cooldown 1 min).",
			"Fleet ampliada: R34, Supra MK4, BMW M4, etc. (lista completa na loja in-game).",
			"3 acessórios · 3 armas (UZI, M4, AK-47, MP5, espingarda, Colt 45 — escolha conforme regra staff).",
			"4 personagens exclusivos · 8 vagas de garagem.",
			"Sem fome/sede · RGB veículo/farol · Tag exclusiva.",
			"Acesso /criarloja.",
		},
	},
	{
		id = "vip_ipiranga",
		line = "vip",
		name = "VIP Ipiranga",
		durationDays = 30,
		activationCash = 2000000,
		hourlySalary = 40000,
		benefits = {
			"Tudo do Omega + reparar + /tunning (tuning cosmético seguro; cooldown 2 min).",
			"Helicóptero em zonas IC apropriadas + Mini Lamborghini + Mini XRE.",
			"4 acessórios · kit arma estendido + taco.",
			"8 vagas · sem fome/sede · tag VIP Ipiranga.",
			"Prioridade em filas de suporte (opcional staff).",
		},
	},
}

IPiranga_SOCIO_TIERS = {
	{
		id = "socio_semanal",
		line = "socio",
		name = "Sócio Ipiranga (semanal)",
		durationDays = 7,
		activationCash = 250000,
		hourlySalary = 8000,
		benefits = {
			"Badge «Sócio» no Discord + cor de nome leve in-game.",
			"1 veículo leve reservado da lista social (spawn RP).",
			"Desconto 10 % em itens cosméticos da loja Plus (quando existir hook).",
			"1 kit utilitário (vida/colete) com cooldown 5 min.",
		},
	},
	{
		id = "socio_mensal",
		line = "socio",
		name = "Sócio Ouro (mensal)",
		durationDays = 30,
		activationCash = 600000,
		hourlySalary = 18000,
		benefits = {
			"Inclui benefícios do nível semanal.",
			"2 veículos da lista social + 1 acessório exclusivo.",
			"Salário horário reforçado + canal exclusivo Discord staff-player.",
		},
	},
	{
		id = "socio_patrocinador",
		line = "socio",
		name = "Sócio Patrocinador",
		durationDays = 30,
		activationCash = 3000000,
		hourlySalary = 50000,
		benefits = {
			"$3.000.000 ao ativar + $50.000/h online (ajustar à economia antes de ir a produção).",
			"Comandos VIP solicitados: /cv (máx. 5/dia por personagem), /pskin, /eventovip, /spectar + /aceitarspectar, /parspectar, /tpp, /tppa (anti-abuso + pedido/aceitação).",
			"Kits vida/colete/reparo/blindagem (CD 1 min) + /tunning (CD 2 min; tuning cosmético) + placa personalizada.",
			"Fleet premium completa (Quad, Kombi, C10, R34, S15, STI, M4, Supra, Tiger 800, etc.).",
			"4 acessórios · 3 armas tier A · 4 personagens · 10 vagas garagem.",
			"Sem fome/sede · RGB carro/farol · /criarloja · tag máxima.",
		},
	},
}

--[[ Ideias extra (roadmap — não ligadas a dados ainda):
  - «Battlepass Ipiranga» mensal com missões leves (dirigir X km, trabalhar Y min).
  - «Sócio streamer»: overlay + comando /cam (se cumprires TOS Twitch).
  - «VIP solidário»: % revertido para evento beneficente IC (narrativa).
]]
