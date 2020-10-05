# Mettre en place l'identification via clefs ssh.

### Prérequis. 

**Client**

**Génération d'une clé au standard de chiffrement ed25519.**
````
# ssh-keygen -t ed25519 -C votre@email.com
````

**Envoie de la clef public sur le serveur.**
````
# ssh-copy-id -i ˜/.ssh/id_ed25519.pub root@0.0.0.0
````

**Serveur**
````
// Installation des paquets requis.
# yum -y install openssh-server rsyslog
````

#### La configuration du serveur ssh.

**Créer ou éditer le fichier de configuration.**
````
# vi /etc/ssh/sshd_config
````

**Ajouter ou mofifier les lignes suivantes.**

````
...
PasswordAuthentication no
ChallengeResponseAuthentication no
PermitUserEnvironment yes
UsePAM no
````

**Redémarrer ssh**
````
# systemctl restart sshd
````

#### La configuration.

**Editer le fichier**
````
# vi /etc/profile
// Ajouter en fin de fichier
...
SSH_IP_CLIENT=$(printf "$SSH_CONNECTION" | awk '{print $1}')
readonly PROMPT_COMMAND='history -a >(logger -i -p local5.info -t "[via: $SSH_IP_CLIENT] $USER ($REALUSER):$PWD"); history -w;'
````

**Lorsqu'on envoie notre clé au serveur distant, celle-ci est ajoutée au fichier ~/.ssh/authorized_keys. Donc pour ce faire, on va donc modifier ce fichier pour y ajouter une variable d'environnement.**
````
environment="REALUSER=prenom.nom" ssh-ed25519 AAAA[...] mon@email.com
````

**Modification  de la configuration syslog**
````
# echo "local5.*   /var/log/shell.log" > /etc/rsyslog.d/shell.conf
````

**Puis**
````
*.*;auth,authpriv.none,local5.none     -/var/log/syslog`
````

**Redémarrer syslog**
````
# systemctl restart rsyslog
````

**Activer la journalisation des logs pour notre identification**
````
# vi /etc/logrorate.conf
// Ajouter à la fin du fichier.
...
/var/log/shell.log {
    rotate 30
    daily
    missingok
    notifempty
    delaycompress
    compress
    postrotate
    invoke-rc.d rsyslog rotate > /dev/null
    endscript
    create 644 root adm
}
````

**Pour finir vérifier si la configuration fonctionne**
````
# tail -f /var/log/shell.log
````

---

Titre :  Fliquer ses collègues avec SSH

Date : 30/08/2020

Auteur : JBRIAULT

Url : https://blog.jbriault.fr/fliquer-collegue-ssh/

## New Tips

**Journalisation des logs sudo**
````
sudo visudo

# Ajouter
Defaults        logfile=/var/log/sudo/sudo.log
````

**Lister les clés disponible pour notre utilisateur courant**
````
for key in ~/.ssh/id_*; do ssh-keygen -l -f "${key}"; done | uniq
````