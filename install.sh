#!/bin/bash

# Mise à jour
apt-get update && apt-get upgrade -y

# Installation de MariaDB
apt-get install -y mariadb-server

echo -e "\033[31m Vous allez devoir répondre à des questions pour l'installation sécurisé de MariaDB :"
echo -e "\033[0m"
sleep 2
mysql_secure_install

# Création de la BDD et de l'Utilisateur :
echo -e "\033[31m Veuillez entrer le nom de la base de données :"
echo -e "\033[0m"
read databaseName
echo -e "\033[31m Veuillez entrer le nom de l'utilisateur :"
echo -e "\033[0m"
read username
echo -e "\033[31m Veuillez entrer le mot de passe de l'utilisateur :"
echo -e "\033[0m"
read password
mysql -u root -p <<EOF
CREATE DATABASE ${databaseName};
CREATE USER '${username}'@'%' IDENTIFIED BY '${password}';
GRANT ALL PRIVILEGES ON ${databaseName}.* TO '${username}'@'%';
FLUSH PRIVILEGES;
EOF

# Installation de PHP et des modules :
apt install -y php libapache2-mod-php php-mbstring php-gd php-curl php-xml php-intl php-imap php-zip php-mysql

# Téléchargement de Dolibarr et installation du serveur apache :
cd /opt
git clone https://github.com/dolibarr/dolibarr -b 19.0

# Installation du serveur apache :
apt install -y apache2

# Création du répertoire :
mkdir /var/www/dolibarr/

# Déplacement des données :
mv dolibarr/* /var/www/dolibarr

# Modifications des droits :
chown -R www-data:www-data /var/www/dolibarr
chmod -R 755 /var/www/dolibarr

echo -e "\033[31m Quelle est le nom du serveur ? (Nom de domaine ou adresse IP) :"
echo -e "\033[0m"
read servername
echo -e "\033[31m Quelle est l'adresse email de l'administrateur du serveur ?"
echo -e "\033[0m"
read serveradmin

cat > /etc/apache2/sites-available/dolibarr.conf <<EOF
<VirtualHost *:80>
ServerName ${servername}
ServerAdmin ${serveradmin}
DocumentRoot /var/www/dolibarr
ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Activation du site :
a2ensite dolibarr

# Redémarrage du serveur apache :
systemctl restart apache2

# Mise en place des éléments supplémentaire :
cd /var/www/dolibarr ; touch htdocs/conf/conf.php ; chown www-data htdocs/conf/conf.php
mkdir -p /var/lib/dolibarr/documents ; chown www-data /var/lib/dolibarr/documents

echo -e "\033[31m Téléchargement et configuration du serveur web terminé."
echo -e "\033[36m Rendez vous dans votre navigateur et accédez à Dolibarr en renseignant l'URL suivant :"
echo -e "\033[33m http://<ip>/htdocs/install"
echo -e "\033[36m OU"
echo -e "\033[33m http://<nom de domaine>/htdocs/install"
echo -e "\033[0m"