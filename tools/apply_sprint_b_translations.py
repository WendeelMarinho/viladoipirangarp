# -*- coding: utf-8 -*-
"""Apply HU -> pt-BR string replacements for Sprint B. Run: python3 tools/apply_sprint_b_translations.py"""
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

CLIENT_REPLACEMENTS = [
    ("Csak a bankban tudod kezelni a frakció számlát!", "Só é possível gerir a conta da facção no banco!"),
    ("Nem lehetséges az adatok lekérése!", "Não foi possível carregar os dados!"),
    ("Nincs egyetlen járműved sem!", "Você não possui nenhum veículo!"),
    ("Nincs egyetlen ingatlanod sem!", "Você não possui nenhum imóvel!"),
    ("Jármű slot vásárlása", "Comprar slot de veículo"),
    ("Ingatlan slot vásárlása", "Comprar slot de imóvel"),
    ("Ingatlan Slot Vásárlás", "Compra de slot de imóvel"),
    ("Jármű Slot Vásárlás", "Compra de slot de veículo"),
    ("Slot Vásárlás: #497ff5", "Compra de slot: #497ff5"),
    ("Karakter Statisztikák", "Estatísticas do personagem"),
    ("Felhasználói információk", "Informações da conta"),
    ("Járműveid", "Seus veículos"),
    ("Járműved adatai", "Dados do veículo"),
    ("Ingatlanjaid", "Seus imóveis"),
    ("Rendszám:#e97619", "Placa:#e97619"),
    ("Elhelyezkedés:#e97619", "Localização:#e97619"),
    ("Vagyon tárgyaid", "Itens do patrimônio"),
    ("Ideiglenes AdminSegéd", "Ajudante admin temporário"),
    ("Adminsegéd Lista", "Lista de ajudantes"),
    ("Adminisztrátor Lista", "Lista de administradores"),
    ("Nincs szolgálatban!", "Fora de plantão!"),
    ("Vezetőségi Tagok", "Equipe de gestão"),
    ("Szervezet áttekintése", "Visão geral da organização"),
    ("Szervezet leírása", "Descrição da organização"),
    ("Elsődleges frakció beállítása", "Definir facção principal"),
    ("Leader opciók megnyitása", "Abrir opções de líder"),
    ("Frakció leírása", "Descrição da facção"),
    ("Frakció számla kezelése", "Conta bancária da facção"),
    ("Bankszámla egyenlege:", "Saldo da conta:"),
    ("Pénz kivétele", "Sacar dinheiro"),
    ("Pénz berakása", "Depositar dinheiro"),
    ("Információk #ffffff-", "Informações #ffffff-"),
    ("A felvétele óta nem állt szolgálatba", "Desde a entrada não entrou em serviço"),
    ("#bd3131Tag kezelése #ffffff-", "#bd3131Gerenciar membro #ffffff-"),
    ("Biztosan el szeretnéd venni a játékos leader jogosultságát?", "Remover permissão de líder deste jogador?"),
    ("Biztosan leader jogosultságot szeretnél adni a játékosnak?", "Conceder permissão de líder a este jogador?"),
    ("Leader jog elvétele", "Remover líder"),
    ("Leader jog adása", "Dar líder"),
    ("Biztosan ki szeretnéd rúgni a frakcióból?", "Expulsar da facção?"),
    ("Elhelyezkedés:", "Localização:"),
    ("Ajtók állapota:", "Portas:"),
    (" Lámpák állapota: ", "\n Faróis: "),
    ("Állapot:", "Estado:"),
    ("Rang Információk #ffffff-", "Informações do posto #ffffff-"),
    ("#bd3131Rang kezelése #ffffff-", "#bd3131Gerenciar posto #ffffff-"),
    ("Ez a funkció nem érhető el", "Função indisponível"),
    ("Rang fizetése: ", "Salário do posto: "),
    ("Ranghoz hozzárendelt duty: ", "Plantão vinculado ao posto: "),
    ("Nincs hozzárendelt duty", "Nenhum plantão vinculado"),
    ("Biztosan ki szeretnéd törölni ezt a rangot?", "Excluir este posto?"),
    ("Rang Törlése", "Excluir posto"),
    ("Rang Mentése", "Salvar posto"),
    ("Rang létrehozása: ", "Criar posto: "),
    ("Ez a funkció nem érhető el!", "Esta função não está disponível!"),
    ("Duty létrehozása: ", "Criar plantão: "),
    ("#bd3131Duty kezelése #ffffff-", "#bd3131Gerenciar plantão #ffffff-"),
    ("Biztosan ki szeretnéd törölni ezt a dutyt?", "Excluir este plantão?"),
    ("Duty Törlése", "Excluir plantão"),
    ("Duty Mentése", "Salvar plantão"),
    ("Duty Skinek", "Skins de plantão"),
    ("Skin előnézet", "Pré-visualização"),
    ("Duty Itemek", "Itens de plantão"),
    ("Nincs jogosultságod az oldal megtekintéséhez!", "Sem permissão para ver esta página!"),
    ("Nem vagy egyetlen szervezet tagja sem! :(", "Você não é membro de nenhuma organização :("),
    ("Prémium Item Shop", "Loja premium"),
    ("Prémium Információk", "Informações premium"),
    ("Prémium egyenleged:", "Seu saldo premium:"),
    ("Eventek, prémium fegyverek, itemek. Ingyen vagy prémium pontért.", "Eventos, armas e itens premium. Grátis ou por pontos premium."),
    (" nap ", " dia(s) "),
    (" óra", " h"),
    (" ÓRA", " H"),
    ("INGYENES", "GRÁTIS"),
    ("Nem elérhető!", "Indisponível!"),
    ("nap múlva", "dia(s)"),
    ("Jármű eladás", "Venda de veículo"),
    ("Jármű vásárlás", "Compra de veículo"),
    ("Ingatlan eladás", "Venda de imóvel"),
    ("Ingatlan vásárlás", "Compra de imóvel"),
    ("Személy ID: ", "ID do jogador: "),
    ("Jármű ára: ", "Preço do veículo: "),
    ("Ingatlan ára: ", "Preço do imóvel: "),
    ("Elutasítás", "Recusar"),
    ("típusú járművet", "tipo de veículo"),
    ("nevű ingatlant", "imóvel chamado"),
    ("Szerkeszthető", "Editável"),
    ("Önkormányzati ingatlan", "Imóvel público"),
    ("Bérház", "Prédio alugado"),
    ("Biznisz", "Negócio"),
]


def apply(path: Path, pairs):
    text = path.read_text(encoding="utf-8")
    orig = text
    for a, b in pairs:
        text = text.replace(a, b)
    if text != orig:
        path.write_text(text, encoding="utf-8")
        print("updated", path.relative_to(ROOT))
    else:
        print("no changes", path.relative_to(ROOT))


def main():
    apply(ROOT / "oDashboard" / "client.lua", CLIENT_REPLACEMENTS)


if __name__ == "__main__":
    main()
