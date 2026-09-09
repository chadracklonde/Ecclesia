# Ecclesia — Étape 0 : Modélisation des données

## 1. Dictionnaire des entités

### Église (Church)
Racine multi-tenant. Une seule ligne en usage actuel, mais toutes les entités métier portent un `church_id`.
- `id`, `name`, `address`, `contact_phone`, `contact_email`, `logo_path`, `created_at`

### Membre (Member)
- `id`, `church_id`, `matricule` (unique), `first_name`, `last_name`, `sex`, `birth_date`, `phone`, `address`, `photo_path`, `qr_code_value`
- `status` (`probation` | `full_member`), `status_since` (date)
- `join_date`, `marital_status`, `profession`
- `created_at`, `updated_at`

### HistoriqueStatut (StatusHistory)
Traçabilité complète des transitions Probation ↔ Pleine communion.
- `id`, `member_id`, `old_status`, `new_status`, `change_date`, `note`, `recorded_by` (user_id)

### Classe (Class — modèle wesleyen)
- `id`, `church_id`, `name`, `leader_member_id` (nullable), `description`

### SousGroupe (Subgroup)
- `id`, `church_id`, `name`, `type` (jeunesse, chorale, femmes, hommes, etc.), `leader_member_id` (nullable)

### MembreClasse (relation N:N)
- `member_id`, `class_id`, `date_joined`

### MembreSousGroupe (relation N:N)
- `member_id`, `subgroup_id`, `date_joined`, `role_in_group` (membre | responsable)

### Culte (Service)
- `id`, `church_id`, `date`, `type` (dominical, spécial, veillée, etc.), `theme`, `status` (planifié | tenu | annulé)

### Prédicateur (Preacher)
Entité séparée pour permettre les prédicateurs externes (invités).
- `id`, `member_id` (nullable), `external_name` (nullable), `external_contact` (nullable)
- `service_id`, `role` (prédicateur principal | invité)
- Contrainte : `member_id` OU `external_name` doit être renseigné (jamais les deux vides)

### Présence (Attendance)
- `id`, `service_id`, `member_id`, `check_in_time`, `method` (qr_scan | manuel), `status` (présent | absent | retard)

### TransactionFinanciere (FinancialTransaction)
- `id`, `church_id`, `type` (dîme | offrande | quête_spécifique | dépense)
- `amount`, `currency`, `date`
- `member_id` (nullable — anonyme possible pour les offrandes de culte)
- `service_id` (nullable — une quête peut être libre ou rattachée à un culte)
- `category` (pour les dépenses), `note`, `recorded_by` (user_id)

### Reçu (Receipt)
- `id`, `transaction_id`, `receipt_number` (séquentiel, unique par église, jamais réutilisé)
- `issue_date`, `issued_by` (user_id)

### Caisse (CashRegister)
- `id`, `church_id`, `balance` (calculé ou mis en cache), `last_reconciled_at`

### Document (Secrétariat)
- `id`, `church_id`, `template_type`, `title`, `generated_date`, `related_member_id` (nullable), `file_path`

### ArticleInventaire (InventoryItem)
- `id`, `church_id`, `name`, `category`, `quantity`, `condition`, `location`, `acquired_date`

### Utilisateur (User — compte système, distinct du Membre)
- `id`, `church_id`, `username`, `password_hash`, `member_id` (nullable, lien vers la fiche membre), `role_id`, `is_active`

### Role
- `id`, `church_id`, `name` (Super Admin, Pasteur, Trésorier, Secrétaire, Responsable de classe, Lecture seule…)

### Permission
- `id`, `role_id`, `module`, `action` (create | read | update | delete | export)

### JournalSauvegarde (BackupLog)
- `id`, `date`, `file_path`, `type` (auto | manuel), `status`

---

## 2. Relations clés (ERD simplifié)

```
Church 1───N Member
Church 1───N Class, Subgroup, Service, FinancialTransaction, InventoryItem, Document, Role

Member 1───N StatusHistory
Member N───N Class        (via MembreClasse)
Member N───N Subgroup     (via MembreSousGroupe)
Member 1───N Attendance
Member 1───0..N Preacher  (optionnel, un prédicateur peut être externe)

Service 1───N Attendance
Service 1───N Preacher
Service 1───0..N FinancialTransaction  (quête liée, optionnel)

FinancialTransaction 1───0..1 Receipt

User N───1 Role
Role 1───N Permission
User 0..1───1 Member  (un utilisateur peut être un membre, ou un compte technique)
```

---

## 3. Décisions de règles métier — VALIDÉES

| # | Question | Décision |
|---|---|---|
| 1 | Un membre peut-il appartenir à plusieurs classes/sous-groupes en même temps ? | ✅ **Oui**, relations N:N |
| 2 | Un prédicateur doit-il être un membre enregistré ? | ✅ **Non**, entité `Preacher` séparée, prédicateur externe (invité) autorisé |
| 3 | Une quête spécifique est-elle toujours liée à un culte ? | ✅ **Non**, `service_id` nullable — quête libre possible |
| 8 | ~~Une présence est-elle toujours liée à un culte ?~~ **Révisé le 09/09/2026** : la présence sert d'abord le suivi pastoral (savoir qui visiter), pas la liturgie. `service_id` devient optionnel sur `Attendance`, `attendance_date` devient le champ pivot (pas besoin d'un culte pour consigner une présence). |
| 4 | Transition de statut (Probation → Pleine communion) | ✅ Historisée intégralement dans `StatusHistory`, jamais écrasée |
| 5 | Format du matricule | ✅ **`[CODE-ÉGLISE]-[ANNÉE]-[SÉQUENCE]`**, ex. `RTC-2026-0042` |
| 6 | Numérotation des reçus | ✅ Séquentielle par église, jamais réutilisée même si transaction annulée — annulation = reçu marqué "annulé", pas supprimé |
| 7 | Utilisateur système vs Membre | ✅ Deux entités distinctes liées en option — un compte technique (ex. secrétaire salarié non membre) peut exister sans fiche membre |

---

## 4. Matrice de permissions (proposition initiale)

| Rôle | Membres | Finances | Présences | Cultes | Secrétariat | Admin |
|---|---|---|---|---|---|---|
| Super Admin | CRUD | CRUD | CRUD | CRUD | CRUD | CRUD |
| Pasteur / Directeur | CRUD | Lecture | CRUD | CRUD | Lecture | Lecture |
| Trésorier | Lecture | CRUD | — | Lecture | — | — |
| Secrétaire | CRUD | Lecture | Lecture | CRUD | CRUD | — |
| Responsable de classe | Lecture (sa classe) | — | CRUD (sa classe) | Lecture | — | — |
| Membre (lecture) | Sa fiche | — | Sa présence | Lecture | — | — |

*(matrice ajustable après validation)*
