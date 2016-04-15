# acme-tiny-renew.sh #

Script to automatically renew TLS certificates with acme-tiny (https://github.com/diafygi/acme-tiny).
It expects the certificates to be checked at `$_LETS_ENCRYPT_DIR/crt/*.chained.crt` and will submit the CSR located at `$_LETS_ENCRYPT_DIR/csr/*.csr` if the certificate is valid for less than `$_EXPIRY` seconds.

The new certificate is automatically chained with `$_LETS_ENCRYPT_DIR/intermediate.pem`. The Let's Encrypt key is expected in `$_LETS_ENCRYPT_DIR/letsencrypt.key` and the ACME challenge is placed in `$_LETS_ENCRYPT_DIR/acme`.

The ACME challenge directory must be served by HTTP. This is an example NGINX configuration:

	location /.well-known/acme-challenge/ {
	        alias /home/letsencrypt/acme/;
	        try_files $uri =404;
	}