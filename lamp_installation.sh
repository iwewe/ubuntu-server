#!/bin/bash

# LAMP Stack Installation and Configuration Script for Ubuntu

# Function to display messages in green color
green_message() {
    echo -e "\e[32m$1\e[0m"
}

# Function to display messages in red color
red_message() {
    echo -e "\e[31m$1\e[0m"
}

# Update and upgrade the system
sudo apt update
sudo apt upgrade -y

# Install Apache
sudo apt install apache2 -y
green_message "Apache installed successfully."

# Install MySQL and set a root password
sudo apt install mysql-server -y
sudo mysql_secure_installation
green_message "MySQL installed and secured."

# Install PHP and necessary modules
sudo apt install php libapache2-mod-php php-mysql -y
green_message "PHP installed successfully."

# Restart Apache for changes to take effect
sudo systemctl restart apache2

# Testing the LAMP setup
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/test.php
green_message "Testing PHP... You can check the test page at http://your-server-ip/test.php"

# Virtual Host Configuration
read -p "Enter your domain or virtual host name (e.g., example.com): " domain_name

# Create a directory for the virtual host
sudo mkdir -p /var/www/$domain_name/public_html

# Set permissions for the directory
sudo chown -R $USER:$USER /var/www/$domain_name/public_html
sudo chmod -R 755 /var/www/$domain_name

# Create a basic HTML file for testing
echo "<html>
<head>
    <title>Welcome to $domain_name</title>
</head>
<body>
    <h1>Success! $domain_name is working.</h1>
</body>
</html>" | sudo tee /var/www/$domain_name/public_html/index.html

# Create a virtual host configuration file
sudo tee /etc/apache2/sites-available/$domain_name.conf > /dev/null <<EOL
<VirtualHost *:80>
    ServerAdmin webmaster@$domain_name
    ServerName $domain_name
    DocumentRoot /var/www/$domain_name/public_html

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/$domain_name/public_html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOL

# Enable the virtual host
sudo a2ensite $domain_name.conf

# Reload Apache to apply changes
sudo systemctl reload apache2
green_message "Virtual host created successfully. You can access your site at http://$domain_name"

# Display LAMP installation completion message
green_message "LAMP stack installation and virtual host setup complete. You can now start deploying your web applications!"
