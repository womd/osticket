# create test database
CREATE DATABASE IF NOT EXISTS `osticket`;

# grant rights
GRANT ALL PRIVILEGES ON `osticket`.* TO 'osticket'@'%';