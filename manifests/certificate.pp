define ssl_cert::certificate(
    $ensure,
) {
    include ssl_cert

    $base_dir = $ssl_cert::base_dir
    $certs = $ssl_cert::certs

    if ! has_key($certs, $name) {
        fail("Could not find definition for ssl certificate $name")
    }

    $defaults =  {
        owner => 'root',
        group => 'root',
        ensure => 'present',
        mode => '0640',
        requirements => [],
    }

    $options = merge(
        $defaults,
        $certs[$name],
        { ensure => $ensure },
        has_key($certs[$name], 'concat') ? {
            true => { content => join($certs[$name]['concat'].map |$cname| { $certs[$cname]['content'] }, "\n") },
            default => {}
        }
    )

    if $ensure == 'present' {
        $options['requirements'].each|$requirement| {
            ensure_resource('ssl_cert::certificate', $requirement, { ensure => $ensure })
        }
    }

    $file_options = delete($options, ['requirements', 'concat'])
    ensure_resource('file', "${base_dir}/${title}", $file_options)
}
