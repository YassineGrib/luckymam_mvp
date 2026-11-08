"""Generate the one-page French client delivery report for release 1.0.3."""
from pathlib import Path
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas
from reportlab.platypus import Paragraph

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'output/pdf/LuckyMam_Rapport_Client_1.0.3_2026-11-07.pdf'
OUTPUT.parent.mkdir(parents=True, exist_ok=True)
pdfmetrics.registerFont(TTFont('Segoe', 'C:/Windows/Fonts/segoeui.ttf'))
pdfmetrics.registerFont(TTFont('SegoeBold', 'C:/Windows/Fonts/segoeuib.ttf'))
pdfmetrics.registerFontFamily('Segoe', normal='Segoe', bold='SegoeBold')

W, H = 595.28, 841.89
INK = colors.HexColor('#29242B')
MUTED = colors.HexColor('#66616A')
ROSE = colors.HexColor('#A7316E')
LINE = colors.HexColor('#E9E2E7')
c = canvas.Canvas(str(OUTPUT), pagesize=(W, H))
c.setTitle('LuckyMam - Rapport de mise à jour 1.0.3')
c.setAuthor('LuckyMam')
c.setSubject('Livraison de la mise à jour Android et bilan de recette')

def paragraph(text, x, y, width, size=10, leading=15, color=INK, bold=False):
    style = ParagraphStyle('body', fontName='SegoeBold' if bold else 'Segoe',
                           fontSize=size, leading=leading, textColor=color,
                           alignment=TA_LEFT)
    p = Paragraph(text, style)
    _, height = p.wrap(width, H)
    p.drawOn(c, x, y - height)
    return y - height

logo = ImageReader(str(ROOT / 'assets/logo/herizontal_logo.png'))
c.drawImage(logo, 42, H - 83, width=151, height=45, mask='auto', preserveAspectRatio=True)
paragraph('LIVRAISON ANDROID', 352, H - 47, 200, 9, 12, MUTED, True)
paragraph('07 novembre 2026', 352, H - 64, 200, 9, 12, MUTED)
c.setStrokeColor(LINE)
c.line(42, H - 104, W - 42, H - 104)

y = paragraph('Rapport de mise à jour', 42, H - 129, W - 84, 24, 29, INK, True)
y = paragraph('Version 1.0.3  /  Build Android 4', 42, y - 9, W - 84, 12, 17, ROSE, True)
y = paragraph('Cette livraison regroupe les corrections et améliorations issues de la recette sur téléphone, avec une nouvelle version préparée pour Google Play.',
              42, y - 16, W - 84, 10, 15)

y = paragraph('Principales évolutions', 42, y - 24, W - 84, 13, 18, ROSE, True)
rows = [
    ('Profil et navigation', 'Choix de langue clarifié et explication du lien entre le statut Maman et l’ajout d’un enfant né.'),
    ('Capsules et émotions', 'Enregistrement audio corrigé ; choix de 1 à 3 émotions, avec cartes compactes sur trois colonnes et sélection visible.'),
    ('Albums et commande', 'Sélection des photos et en-têtes simplifiés, couvertures revues, interface française harmonisée, option PDF retirée et liste des wilayas actualisée.'),
    ('Vidéos et partage', 'Chargement hors connexion mieux géré, partage et sauvegarde opérationnels, arrêt en arrière-plan et marque LuckyMam à 50 % de transparence.'),
    ('Assistant et diaporama', 'Service de conversation IA rétabli ; présentation du diaporama harmonisée et lien Google Play ajouté au texte de partage.'),
]
for title, body in rows:
    y -= 12
    bottom = paragraph(title, 42, y, 135, 9.5, 14, INK, True)
    body_bottom = paragraph(body, 187, y, W - 229, 9.5, 14)
    y = min(bottom, body_bottom) - 9
    c.setStrokeColor(LINE)
    c.line(42, y, W - 42, y)

y = paragraph('Validation et clôture', 42, y - 22, W - 84, 13, 18, ROSE, True)
y = paragraph('29 scénarios de recette mobile réalisés : 26 acceptés lors de la première passe, puis corrections ciblées. La reprise de recette est clôturée : 3 contrôles confirmés par le client et le contrôle du lien de partage clôturé à sa demande.',
              42, y - 10, W - 84, 9.5, 14)
y = paragraph('Vérification technique : suite de 293 tests réussie, puis 3 tests ciblés réussis après le dernier ajustement des cartes. Aucune erreur relevée par l’analyse du projet ; des avertissements techniques existants restent présents.',
              42, y - 9, W - 84, 9.5, 14)

y = paragraph('Livrable et prochaine étape', 42, y - 20, W - 84, 13, 18, ROSE, True)
y = paragraph('Android App Bundle (.aab) signé - version 1.0.3, code 4.<br/>Prochaine étape : import et validation dans Google Play Console. La mise en ligne et la validation Google ne sont pas incluses dans cette livraison.',
              42, y - 9, W - 84, 9.5, 14)
assert y > 55, f'Report exceeds page layout: {y}'
c.setStrokeColor(LINE)
c.line(42, 43, W - 42, 43)
paragraph('LuckyMam  |  Rapport client de livraison', 42, 31, 450, 8, 10, MUTED)
paragraph('1 / 1', W - 72, 31, 40, 8, 10, MUTED)
c.save()
print(OUTPUT)
