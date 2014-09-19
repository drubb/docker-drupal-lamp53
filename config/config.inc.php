<?php

// Configuration file for PhpMyAdmin

$cfg['ServerDefault'] = 1;
$cfg['UploadDir'] = '/tmp';
$cfg['SaveDir'] = '';
$cfg['blowfish_secret'] = 'this_does_not_matter_at_all';
$cfg['PmaNoRelation_DisableWarning'] = true;

$cfg['Servers'][1]['auth_type'] = 'config';
$cfg['Servers'][1]['host'] = 'localhost';
$cfg['Servers'][1]['connect_type'] = 'tcp';
$cfg['Servers'][1]['compress'] = false;
$cfg['Servers'][1]['user'] = 'root';
$cfg['Servers'][1]['password'] = 'root';