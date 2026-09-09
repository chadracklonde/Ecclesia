# Ecclesia — Design tokens (Étape 2)

Source : charte graphique officielle UMC (resourceumc.org/content/brand-colors).

## Couleur primaire — Rouge UMC
| Rôle | Hex | Pantone |
|---|---|---|
| Primaire (actions, accents) | `#E4002B` | PMS 185 |
| Primaire foncé (hover, texte sur fond clair) | `#AF292E` | PMS 1805 |
| Primaire très foncé (texte sur fond très clair) | `#7A2426` | PMS 1815 |

## Neutres
| Rôle | Hex |
|---|---|
| Noir (texte principal) | `#000000` |
| Gris foncé (texte secondaire) | `#575A5D` |
| Gris clair (bordures, fonds) | `#B5B7B4` |

## Typographie
- `Oswald` — police officielle des logos/titres UMC (Google Fonts, gratuite).
- Corps de texte : police système lisible (Oswald n'est pas conçue pour de longs paragraphes) — à confirmer en Étape 2bis si un choix de police de corps distinct est souhaité.

## Couleurs fonctionnelles (statuts — inchangées, non liées à la marque)
- Pleine communion / Présent : vert (`#EAF3DE` fond / `#173404` texte)
- Probation : ambre (`#FAEEDA` fond / `#412402` texte)
- Absent / Erreur : rouge fonctionnel distinct **`#C0392B`** (brique, plus orangé que le rouge de marque)

**Décision validée** : le rouge UMC (`#E4002B`) est réservé exclusivement à l'identité de marque (boutons primaires, en-têtes, éléments de navigation). Les états "Absent"/"Erreur" utilisent `#C0392B`, une teinte visiblement distincte, toujours accompagnée d'une icône et d'un texte (jamais la couleur seule comme signal).

## Logo

Validé le 09/09/2026 : silhouette d'église rouge (clocher + croix + porte
en négatif) sur fond crème, avec wordmark "Ecclesia" en dessous.
Fichiers sources : `assets/logo/ecclesia_icon.svg` (icône seule) et
`assets/logo/ecclesia_logo_full.svg` (icône + nom).

**Prochaine étape pour en faire de vraies icônes d'app** (favicon,
icône de lanceur iOS/Android/macOS/Windows) : utiliser un générateur
comme le paquet `flutter_launcher_icons`, en lui donnant
`ecclesia_icon.svg` (converti en PNG haute résolution au préalable, ex.
1024×1024) comme source. Non fait ici — paquet non vérifiable dans ce
sandbox.
