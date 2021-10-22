## Zabbix smartmonitor storage
- https://github.com/nikimaxim/zbx-smartmonitor.git

### Installing for windows
#### Requirements:
- OS: Windows 7, 2008R2 and later
- PowerShell: 5.1 and later
- Zabbix-agent: 4.0 and later
- Smartmontools: 7.1 and later

#### Get utils smartmontools
- https://builds.smartmontools.org/

#### Check correct versions PowerShell: (Execute in PowerShell!) (Requirements!)
- ```Get-Host|Select-Object Version```

#### Copy powershell script:
- **github**/smartctl-storage-discovery.ps1 in C:\service\smartctl-storage-discovery.ps1

#### Check powershell script(Out json): (CMD!)
- ```powershell -NoProfile -NoLogo -ExecutionPolicy Bypass -File "C:\service\smartctl-storage-discovery.ps1"```

#### Add from zabbix_agentd.conf "UserParameter" in zabbix_agentd.conf:
- **github**/zabbix_agentd.conf

#### Import zabbix template:
- **github**/Template smartmonitor.xml

<br/>

### Installing for linux 
#### Requirements:
- OS: Linux
- Zabbix-agent: 4.0 and later
- Smartmontools: 7.1 and later

#### Get utils smartmontools
- https://builds.smartmontools.org/
- Installing from package: Ubuntu(sudo apt install smartmontools), CentOS(yum install smartmontools)

#### Copy bash script:
- **github**/smartctl-storage-discovery.sh in /opt/zabbix/smartctl-storage-discovery.sh

#### Chmod and Chown
- ```chmod -R 750 /opt/zabbix/```
- ```chown -R root:zabbix /opt/zabbix/```

#### Check bash script(Out json):
- ```/opt/zabbix/smartctl-storage-discovery.sh```

#### Add from zabbix_agentd.conf "UserParameter" in zabbix_agentd.conf:
- **github**/zabbix_agentd.conf

#### Set up sudoers

Copy over the _etc_sudoers.d_zabbix_smartmonitor to /etc/sudoers.d/zabbix_smartmonitor, e.g.
```
scp -p _etc_sudoers.d_zabbix_smartmonitor 1.2.3.4:
ssh 1.2.3.4 "sudo mv _etc_sudoers.d_zabbix_smartmonitor /etc/sudoers.d/zabbix_smartmonitor && sudo chown root: /etc/sudoers.d/zabbix_smartmonitor"
```


#### Import zabbix template:
- **github**/Template smartmonitor.xml

<br/>

### Installing for MacOS(In developing!!!)
#### Requirements:
- OS: MacOS
- Zabbix-agent: 4.0 and later
- Smartmontools: 7.1 and later

#### Get utils smartmontools
- https://builds.smartmontools.org/

#### Copy bash script:
- **github**/smartctl-storage-discovery.sh in /usr/local/etc/zabbix/smartctl-storage-discovery.sh

#### Chmod and Chown
- ```chmod 755 /usr/local/etc/zabbix/smartctl-storage-discovery.sh```

#### Check bash script(Out json):
- ```/usr/local/etc/zabbix/smartctl-storage-discovery.sh```

#### Set UnsafeUserParameters=1
(In developing!!!)

#### Add from zabbix_agentd.conf "UserParameter" in zabbix_agentd.conf:
- **github**/zabbix_agentd.conf

#### Add in /etc/sudoers OR visudo
- Defaults:zabbix !requiretty
- zabbix  ALL=(root) NOPASSWD: /usr/local/sbin/smartctl
- zabbix  ALL=(root) NOPASSWD: /usr/local/etc/zabbix/smartctl-storage-discovery.sh

#### Import zabbix template:
- **github**/Template smartmonitor.xml

<br/>

#### Examples images:
- Graph: Temperature smartmonitor
![Image alt](https://github.com/nikimaxim/zbx-smartmonitor/blob/master/img/1.png)

<br/>

- Discovery rules

<br/>

![Image alt](https://github.com/nikimaxim/zbx-smartmonitor/blob/master/img/2.png)

<br/>

- Items prototypes

<br/>

![Image alt](https://github.com/nikimaxim/zbx-smartmonitor/blob/master/img/3.png)

<br/>

- Latest data

<br/>

![Image alt](https://github.com/nikimaxim/zbx-smartmonitor/blob/master/img/4.png)

<br/>

#### License
- GPL v3
