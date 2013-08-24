#
#
#
define jenkins::plugin($version=0,
                       $plugin_dir='/var/lib/jenkins/plugins'
) {
  $plugin    = "${name}.jpi"
  $plugin_dl = "${name}.hpi"

  if ($version != 0) {
    $base_url = "http://updates.jenkins-ci.org/download/plugins/${name}/${version}/"
  }
  else {
    $base_url = 'http://updates.jenkins-ci.org/latest/'
  }

  if (!defined(File[$plugin_dir])) {
    file {
      $plugin_dir:
        ensure  => directory,
        owner   => 'jenkins',
        group   => 'jenkins',
        mode    => '0755',
        require => Class['jenkins::package'];
    }
  }

  exec {
    "download-${name}" :
      command    => "wget --no-check-certificate ${base_url}${plugin_dl} -O ${plugin}",
      cwd        => $plugin_dir,
      require    => File[$plugin_dir],
      path       => ['/usr/bin', '/usr/sbin',],
      unless     => "test -f ${plugin_dir}/${plugin}",
  }

  file {
    "${plugin_dir}/${plugin}" :
      ensure  => present,
      owner   => 'jenkins',
      group   => 'jenkins',
      mode    => '0644',
      require => [Class['jenkins::package'], Exec["download-${name}"],],
      notify  => Class['jenkins::service']
  }
}
