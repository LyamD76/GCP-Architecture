# Mon Projet
## Objectifs 
## Projet OPS
Projet Ops
Le projet Ops gère trois pipelines Cloud Build distinctes :

Application

Upload de l'application dans Artifact Registry
Scan de sécurité des secrets
Scan de vulnérabilités

Image

Construction de l'image système avec Packer et Ansible
Installation de l'application et de l'OpsAgent

Création du bucket GCS pour les états Terraform
## Projet App
Le projet App déploie l'infrastructure suivante :

VPC dédié
Sous-réseaux pour l'application et le load balancer
Bucket GCS public pour les fichiers statiques
Managed Instance Group (MIG) avec auto-scaling
Load Balancer régional
Zone DNS dédiée
Dashboard de monitoring avec métriques :
Trafic du load balancer
Utilisation CPU/RAM du MIG

# Structure du Projet

Nom du 1er Projet : devops-ops
Nom du 2ème Projet : devops-prod
.
├── ops/
│   ├── img-packer/              # Configuration de l'image
│   │   ├── ansible.yml      
│   │   ├── packerfile.pkr.hcl   
│   ├── binaire-app/             # Création de l'Artifact Registry
│   │   ├── src           
│   │   └── cloudbuild.yaml       
│   └── GCS-Bucket/
│       └── gcs/                 # Configuration Terraform pour le bucket des *terraformstates*
│           ├── main.tf
│           └── variables.tf
└── prod/                        # Configuration et déploiement du projet devops-prod
    └── main.tf
