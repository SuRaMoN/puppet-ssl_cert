class ssl_cert(
    $enable = [],
    $disable = [],
    $dirs = ['/etc/ssl/ca', '/etc/ssl/keys'],
    $base_dir = '/etc/ssl',
    $notify_services = ['httpd', 'haproxy']
) {
    $certs = hiera_hash('ssl_cert::certs', {})
    $append_enable = hiera_array('ssl_cert::append_enable', [])
    $append_disable = hiera_array('ssl_cert::append_disable', [])

    $all = {
        present => union($enable, $append_enable),
        absent => union($disable, $append_disable),
    }

    file { $dirs:
        ensure => directory,
        owner => root,
        group => root,
    }

    $all.each|$ensure, $cert_names| {
        $cert_names.each|$name| {
            ensure_resource('ssl_cert::certificate', $name,  { ensure => $ensure })
        }
    }

    File[$dirs] -> Certificate<| |>
    $notify_services.each|$service| {
        Certificate<| |> ~> Service<| title == $service |>
    }
}
