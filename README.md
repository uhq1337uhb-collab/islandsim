# Island Sim — réplique du design de la Dynamic Island

App iOS (SwiftUI) qui reproduit fidèlement le **design de la Dynamic Island** : pilule noire
flottante en haut de l'écran, avec ses états **compact / minimale / déployée** et ses
animations à ressort — musique (pochette + égaliseur), minuteur (anneau de progression),
appel entrant, charge, Face ID.

> ⚠️ À savoir : une pilule **par-dessus l'écran d'accueil** (comme le vrai système) est
> impossible sans exploit — c'est précisément ce que tentait DynamicCow, et iOS l'interdit
> aux apps normales. Ici, la réplique vit **à l'intérieur de l'app** (lancement, démo,
> personnalisation). Pour une pilule sur l'écran verrouillé, on peut ajouter un
> *Widget Extension* (Live Activities) en v2 — demande-le moi.

## Contenu du projet

```
project.yml                     # définition du projet Xcode (XcodeGen)
.github/workflows/build.yml     # fabrique l'IPA automatiquement sur un Mac GitHub
DynamicIslandSim/
  DynamicIslandSimApp.swift     # point d'entrée
  IslandModel.swift             # états et données (musique, minuteur, appel…)
  DynamicIslandView.swift       # la pilule + tous les états déployés
  HomeDemoView.swift            # écran de démo (fond, barre d'état, contrôles)
```

## Obtenir l'IPA (sans Mac, 5 minutes)

1. Crée un dépôt sur **github.com** (bouton *New repository*, laisse-le public).
2. Sur la page du dépôt vide, clique **uploading an existing file**, puis glisse le
   **contenu** du dossier `DynamicIslandSim` : `project.yml`, le dossier
   `DynamicIslandSim/` et le dossier `.github/`. Valide avec *Commit changes*.
3. Onglet **Actions** → workflow **Build IPA** → **Run workflow** → patiente 3 à 5 min.
4. En bas du run terminé, section **Artifacts** → télécharge **DynamicIslandSim-ipa** →
   extrais le zip : tu obtiens **DynamicIslandSim.ipa**.
5. Sur PC : branche l'iPhone, ouvre **Sideloadly**, glisse l'IPA, connecte ton Apple ID,
   clique **Start**. (Tu as déjà iTunes + Sideloadly : parfait.)
6. Sur l'iPhone : Réglages → Général → **VPN et gestion des appareils** → fais confiance
   au profil développeur, puis lance **Island Sim**.

### Notes de signature

- Apple ID **gratuit** : l'app reste installée **7 jours**, il faut re-signer ensuite.
- Compte développeur **99 $/an** : 1 an de validité.

## Compiler soi-même (si un Mac est dispo)

```bash
brew install xcodegen
xcodegen generate
open DynamicIslandSim.xcodeproj   # puis Cmd+R dans Xcode
```

## Personnaliser

- **Couleurs de la pochette / titres** : `IslandModel.swift` (`artColors`, `songTitle`…).
- **Tailles et arrondis de la pilule** : `DynamicIslandView.swift` (`size`, `cornerRadius`).
- **Ajouter un état** : une entrée dans `IslandContent` + une vue `Expanded…View`.

Compatible **iOS 16+** (donc ton iPhone sous iOS 27.3 beta).
