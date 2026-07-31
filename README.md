# Hengus

Gra inspirowana *Among Us*, zbudowana w **Godot 4.7**.

## Graj w przeglądarce

https://henrykdomzala.github.io/hengus/

## Uruchomienie lokalne

1. Uruchom Godot z pulpitu: `Godot_v4.7.1-stable_win64.exe`
2. **Import** → wskaż folder projektu
3. Naciśnij **F5**

## Sterowanie

| Klawisz | Akcja |
|---------|--------|
| `W` / `↑` | Góra |
| `S` / `↓` | Dół |
| `A` / `←` | Lewo |
| `D` / `→` | Prawo |

## Funkcje

- Menu główne ze Start Game
- Poruszanie po mapie stacji
- Kolizje ze ścianami / chodnikiem
- Okrągłe pole widzenia (300 px)

## Deploy

Push na `main` uruchamia workflow `.github/workflows/deploy-pages.yml`, który eksportuje grę do Web i publikuje na GitHub Pages.
