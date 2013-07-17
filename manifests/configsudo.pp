define ipa::configsudo (
  $host       = $name,
  $sudopw     = {},
  $adminpw    = {},
  $domain     = {},
  $masterfqdn = {}
) {

  Augeas["nsswitch-sudoers-${host}"] -> File["sudo-ldap-${host}"] ~> Exec["set-sudopw-${host}"]

  $dc = prefix([regsubst($domain,'(\.)',',dc=','G')],'dc=')

  augeas { "nsswitch-sudoers-${host}":
    context => '/files/etc/nsswitch.conf',
    changes => [
      "set database[. = ''] sudoers",
      "set database[. = 'sudoers']/service[1] files",
      "set database[. = 'sudoers']/service[2] ldap"
    ]
  }

  file { "sudo-ldap-${host}":
    path    => "/etc/sudo-ldap.conf",
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('ipa/sudo-ldap.conf.erb')
  }

  exec { "set-sudopw-${host}":
    command     => "/bin/bash -c \"LDAPTLS_REQCERT=never /usr/bin/ldappasswd -x -H ldaps://${masterfqdn} -D uid=admin,cn=users,cn=accounts,${dc} -w ${adminpw} -s ${sudopw} uid=sudo,cn=sysaccounts,cn=etc,${dc}\"",
    unless      => "/bin/bash -c \"LDAPTLS_REQCERT=never /usr/bin/ldapsearch -x -H ldaps://${masterfqdn} -D uid=sudo,cn=sysaccounts,cn=etc,${dc} -w ${sudopw} -b cn=sysaccounts,cn=etc,${dc} uid=sudo\"",
    logoutput   => "on_failure",
    refreshonly => true
  }
}