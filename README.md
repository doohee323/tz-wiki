# Run a wiki server on Vagrant or AWS

install a wiki server with ubuntu 16.04, MySQL, nginx, php 7.0. 

1. add host on your host
```
	vi /etc/hosts
	192.168.82.170	dev.tz.com
```

2. build a server
```
	- password: passwd123
	<for Vagrant>
		vagrant destroy -f && vagrant up
		vagrant ssh
		cf. all scripts
			/wiki-vagrant/scripts/wiki.sh
		
	<for AWS>
		# make ec2 instanace with Ubuntu Server 14.04 LTS
		# set your pem file and aws ec2 ip address 
		export PEM=topzone_ca1
		export AWS_EC2_IP_ADDRESS=54.153.115.68
		bash aws.sh
		cf. all scripts
			/wiki-vagrant/scripts/run_aws.sh
			/wiki-vagrant/scripts/wiki.sh
		cf. access to terminal after opening firewal for the ec2 instance
			cd ~/.ssh
			chmod 600 $PEM.pem
			ssh -i $PEM.pem ubuntu@$AWS_EC2_IP_ADDRESS
```

3. configure a wiki server
```
	<for Vagrant>
		- http://192.168.82.170 
	<for AWS>
		- http://$AWS_EC2_IP_ADDRESS
		
	- id / password = admin/admin123
	
	open site(http://192.168.82.170) and set up these,
		- Language: en, en
		- Mysql 
			- Database host: localhost
			- Database name: wikidb
			- id/passwd: root / passwd123
			- Storage engine: InnoDB
			- Database character set: UTF-8
		- Name
			- Name of wiki: Topzone-wiki
			- Project namespace: Same as the wiki name: Topzone-wiki
			- Your username: doohee323
			- Password: hdh123456
			- Email address: doohee323@gmail.com
		- copy downloaded LocalSettings.php to ~/wiki-vagrant
			- you can change the set-up configuration ~/wiki-vagrant/LocalSettings.php
				# for private wiki 
				$wgGroupPermissions['*']['read'] = false;
				$wgGroupPermissions['*']['edit'] = false;
				$wgGroupPermissions['*']['createaccount'] = false;
				$wgWhitelistRead = array ("Special:Userlogin");
			 
			- if you want to re-install, 
				rm /var/www/mediawiki/LocalSettings.php 
		- run config.sh
			cd ~/wiki-vagrant
			vagrant ssh
			cd /vagrant/scripts
			bash config.sh
		- open the site, http://dev.tz.com on your browser!
		- login with your account (doohee323 / hdh123456)
```

-. access to mysql
```
	<for Vagrant>
		mysql -h 192.168.82.170 -P 3306 -u root -p
	<for AWS>
		mysql -h $AWS_EC2_IP_ADDRESS -P 3306 -u root -p 
		
	- password: passwd123
```

-. upload directory
```
	
```

-. register AWS Access key
```
	export AWS_KEY=11111111111111111111:1111111111111111111111111111111111111111
	cf. on aws console, Your Security Credentials > Access Keys (Access Key ID and Secret Access Key)
```


