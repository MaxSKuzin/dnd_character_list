"""Собирает ассеты пиксельного аватара из Universal LPC Spritesheet Character Generator.

Из каждого листа ходьбы берётся один кадр 64×64 — персонаж стоит лицом к зрителю (строка 2, кадр 0); у листов
с увеличенными кадрами 128×128 — центр такого кадра. Пустые кадры (оружие, целиком скрытое телом) не сохраняются. Кадры остаются
в исходных цветах LPC: приложение перекрашивает их палитрами из `palettes.json`. Авторы использованных слоёв
пишутся в `credits.json` — их показывает экран авторов (лицензии CC-BY-SA, GPL, OGA-BY требуют указать авторов).

Запуск (нужен Pillow):

    git clone --depth 1 --filter=blob:none --sparse \
        https://github.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator.git <lpc>
    git -C <lpc> sparse-checkout set --no-cone /sheet_definitions/ /palette_definitions/
    python3 tool/avatar/build_avatar_assets.py <lpc> assets/avatar

Листы скачиваются с GitHub по одному и кэшируются в `<lpc>/.avatar_cache`.
"""
import glob
import json
import os
import sys
import urllib.request

from PIL import Image

RAW = 'https://raw.githubusercontent.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator/HEAD/spritesheets/'

# Слои: имя файла в assets/avatar/layers → лист LPC. {sex} — male/female, {thin} — male/thin (женские ноги и руки).
LAYERS = {
    'body_{sex}': 'body/bodies/{sex}/walk.png',
    'head_{sex}': 'head/heads/human/{sex}/walk.png',
    'face_{sex}': 'head/faces/{sex}/neutral/walk.png',
    'ears_elven': 'head/ears/elven/adult/walk.png',
    'horns': 'head/horns/curled/adult/walk.png',
    # Спереди хвост виден только из-за ног: передний слой хвоста в этом кадре пустой.
    'tail': 'body/tail/lizard/alt/adult/bg/walk/red.png',
    'hair_plain': 'hair/plain/adult/walk.png',
    'hair_spiked': 'hair/spiked/adult/walk.png',
    'hair_long_messy': 'hair/long_messy/adult/walk.png',
    'beard': 'beards/beard/basic/walk.png',
    'hair_bob': 'hair/bob/adult/walk.png',
    'hair_braid': 'hair/braid/adult/fg/walk.png',
    'hair_curly_long': 'hair/curly_long/adult/walk.png',
    # Одежда (`TopStyle`, `BottomStyle`, `Footwear`). Платья и длинная юбка есть только у женского тела;
    # платье — белый вариант LPC, его перекрашивает палитра `cloth`. Плащ спереди не виден.
    'top_longsleeve_{sex}': 'torso/clothes/longsleeve/longsleeve/{sex}/walk.png',
    'top_vneck_{sex}': 'torso/clothes/longsleeve/longsleeve2_vneck/{sex}/walk.png',
    'top_shortsleeve_{sex}': 'torso/clothes/shortsleeve/shortsleeve/{sex}/walk.png',
    'top_sleeveless_{sex}': 'torso/clothes/sleeveless/sleeveless2/{sex}/walk.png',
    'top_dress_female': 'dress/sash/female/walk/white.png',
    'top_long_dress_female': 'dress/slit/female/walk/white.png',
    'pants_{sex}': 'legs/pants/{thin}/walk.png',
    'skirt_{sex}': 'legs/skirts/plain/{thin}/walk.png',
    'long_skirt_female': 'legs/skirts/belle/thin/walk.png',
    'boots_{sex}': 'feet/boots/basic/{thin}/walk.png',
    'folded_boots_{sex}': 'feet/boots/fold/{thin}/walk.png',
    'shoes_{sex}': 'feet/shoes/basic/{thin}/walk.png',
    'sandals_{sex}': 'feet/sandals/{thin}/walk.png',
    'leather_{sex}': 'torso/armour/leather/{sex}/walk.png',
    'chainmail_{sex}': 'torso/chainmail/{sex}/walk.png',
    'legion_{sex}': 'torso/armour/legion/{sex}/walk.png',
    'plate_{sex}': 'torso/armour/plate/{sex}/walk.png',
    'plate_arms_{sex}': 'arms/armour/plate/{thin}/walk.png',
    'plate_legs_{sex}': 'legs/armour/plate/{thin}/walk.png',
    'plate_feet_{sex}': 'feet/armour/plate/{thin}/walk.png',
    'shield_{sex}': 'shield/kite/{sex}/walk/kite_red_gray.png',
    'dagger_fg': 'weapon/sword/dagger/walk/dagger.png',
    'dagger_bg': 'weapon/sword/dagger/behind/walk/dagger.png',
    'sword_fg': 'weapon/sword/arming/universal/fg/walk/steel.png',
    'sword_bg': 'weapon/sword/arming/universal/bg/walk/steel.png',
    'longsword_fg': 'weapon/sword/longsword/walk/longsword.png',
    'longsword_bg': 'weapon/sword/longsword/universal_behind/walk/longsword.png',
    'rapier_fg': 'weapon/sword/rapier/walk/rapier.png',
    'rapier_bg': 'weapon/sword/rapier/universal_behind/walk/rapier.png',
    'saber_fg': 'weapon/sword/saber/walk/saber.png',
    'saber_bg': 'weapon/sword/saber/universal_behind/walk/saber.png',
    'mace_fg': 'weapon/blunt/mace/walk/mace.png',
    'mace_bg': 'weapon/blunt/mace/universal_behind/walk/mace.png',
    'flail_fg': 'weapon/blunt/flail/walk/flail.png',
    'flail_bg': 'weapon/blunt/flail/behind/walk/flail.png',
    'axe_fg': 'weapon/blunt/waraxe/walk/waraxe.png',
    'axe_bg': 'weapon/blunt/waraxe/behind/walk/waraxe.png',
    'spear_fg': 'weapon/polearm/spear/foreground/walk/spear.png',
    'spear_bg': 'weapon/polearm/spear/background/walk/spear.png',
    'halberd_fg': 'weapon/polearm/halberd/walk/halberd.png',
    'halberd_bg': 'weapon/polearm/halberd/behind/walk/halberd.png',
    'staff_fg': 'weapon/magic/simple/foreground/walk/simple.png',
    'staff_bg': 'weapon/magic/simple/background/walk/simple.png',
    # Луки — увеличенные кадры 128×128, но целиком помещаются в центральные 64×64. Длинное копьё и трезубец
    # в них не помещаются, поэтому их нет.
    'bow_fg': 'weapon/ranged/bow/normal/walk/foreground/medium.png',
    'bow_bg': 'weapon/ranged/bow/normal/walk/background/medium.png',
    'longbow_fg': 'weapon/ranged/bow/recurve/walk/foreground/medium.png',
    'longbow_bg': 'weapon/ranged/bow/recurve/walk/background/medium.png',
    'crossbow_fg': 'weapon/ranged/crossbow/foreground/walk/crossbow.png',
    'crossbow_bg': 'weapon/ranged/crossbow/background/walk/crossbow.png',
    'sling_fg': 'weapon/ranged/slingshot/foreground/walk/slingshot.png',
    'sling_bg': 'weapon/ranged/slingshot/background/walk/slingshot.png',
}

# Палитры: материал → файлы LPC. Палитры all_lpcr годятся для любого материала и лежат под ключом `all`.
PALETTES = {
    'body': ['body/body_ulpc.json', 'body/body_lpcr.json'],
    'hair': ['hair/hair_ulpc.json'],
    'eye': ['eye/eye_ulpc.json'],
    'cloth': ['cloth/cloth_ulpc.json'],
    'metal': ['metal/metal_ulpc.json'],
    'all': ['all/all_lpcr.json'],
}


def expand():
    for key, path in LAYERS.items():
        if '{sex}' not in key:
            yield key, path
            continue
        for sex, thin in (('male', 'male'), ('female', 'thin')):
            yield key.format(sex=sex), path.format(sex=sex, thin=thin)


def fetch(cache, path):
    local = os.path.join(cache, path.replace('/', '__'))
    if not os.path.exists(local):
        urllib.request.urlretrieve(RAW + path, local)
    return local


def credits_for(definitions, path):
    """Авторы из описаний слоёв LPC: запись, чей `file` — самый длинный префикс пути листа."""
    best = None
    for credit in definitions:
        file = credit['file'].rstrip('/')
        if path.startswith(file + '/') or path == file:
            if best is None or len(file) > len(best['file'].rstrip('/')):
                best = credit
    return best


def main(lpc, out):
    cache = os.path.join(lpc, '.avatar_cache')
    os.makedirs(cache, exist_ok=True)
    os.makedirs(os.path.join(out, 'layers'), exist_ok=True)

    definitions = []
    for file in glob.glob(os.path.join(lpc, 'sheet_definitions', '**', '*.json'), recursive=True):
        definitions += json.load(open(file)).get('credits', [])

    credits = {}
    for key, path in expand():
        sheet = Image.open(fetch(cache, path)).convert('RGBA')
        if sheet.height == 512:
            frame = sheet.crop((32, 288, 96, 352))
        else:
            frame = sheet.crop((0, 128, 64, 192))
        if frame.getbbox() is None:
            continue
        frame.save(os.path.join(out, 'layers', f'{key}.png'), optimize=True)
        credit = credits_for(definitions, path)
        if credit is None:
            raise SystemExit(f'Нет авторов для {path}')
        credits[credit['file']] = {
            'authors': credit.get('authors', []),
            'licenses': credit.get('licenses', []),
            'urls': credit.get('urls', []),
        }

    palettes = {}
    for material, files in PALETTES.items():
        palettes[material] = {}
        for file in files:
            palettes[material].update(json.load(open(os.path.join(lpc, 'palette_definitions', file))))
    with open(os.path.join(out, 'palettes.json'), 'w') as f:
        json.dump(palettes, f, separators=(',', ':'))

    with open(os.path.join(out, 'credits.json'), 'w') as f:
        json.dump([{'file': k, **v} for k, v in sorted(credits.items())], f, ensure_ascii=False, indent=1)
    print(f'{len(os.listdir(os.path.join(out, "layers")))} слоёв, {len(credits)} записей об авторах')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
