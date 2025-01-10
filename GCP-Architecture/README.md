# Mon Projet

## Objectifs
Ce projet a pour objectif de mettre en place une infrastructure DevOps complète, en utilisant des pipelines Cloud Build, Packer, Terraform, ainsi que divers services GCP pour gérer l'application et l'infrastructure.

---

## Projet OPS
Le projet OPS gère trois pipelines Cloud Build distincts :

1. **Application**
    - Upload de l'application dans **Artifact Registry**
    - Scan de sécurité des secrets
    - Scan de vulnérabilités

2. **Image**
    - Construction de l'image système avec **Packer** et **Ansible**
    - Installation de l'application et de l'**OpsAgent**

3. **Infrastructure**
    - Création du bucket **GCS** pour les états **Terraform**

---

## Projet App
Le projet App déploie l'infrastructure suivante :

- **VPC dédié**
- **Sous-réseaux** pour l'application et le load balancer
- **Bucket GCS public** pour les fichiers statiques
- **Managed Instance Group (MIG)** avec auto-scaling
- **Load Balancer régional**
- **Zone DNS dédiée**
- **Dashboard de monitoring avec métriques** :
    - Trafic du load balancer
    - Utilisation **CPU/RAM** du MIG

---

# Structure du Projet

### Nom du 1er Projet : `devops-ops`
### Nom du 2ème Projet : `devops-prod`
Voici la structure du répertoire pour les deux projets :
/devops │ ├── ops/ # Configuration et gestion des opérations │ ├── img-packer/ # Configuration pour la création d'image │ │ ├── ansible.yml # Playbook Ansible pour la configuration │ │ ├── packerfile.pkr.hcl # Configuration Packer pour l'image │ ├── binaire-app/ # Configuration pour la création de l'Artifact Registry │ │ ├── src # Code source pour la création de l'artefact │ │ └── cloudbuild.yaml # Fichier de configuration Cloud Build │ └── GCS-Bucket/ # Gestion de bucket GCS pour Terraform states │ └── gcs/ # Configuration Terraform pour GCS │ ├── main.tf # Configuration principale de Terraform │ └── variables.tf # Variables pour Terraform │ └── prod/ # Configuration et déploiement en environnement de production └── main.tf # Fichier Terraform pour le déploiement en production
