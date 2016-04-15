#!/bin/bash
_LETS_ENCRYPT_DIR="/home/letsencrypt"
_ACME_TINY="/home/letsencrypt/acme-tiny/acme_tiny.py"
_EXPIRY=$((60*60*24*2))

returnValue=0
replaced=false
for crt in `ls -1 "$_LETS_ENCRYPT_DIR/crt/"*".chained.crt"`; do

	restTime=$(($(\
		date -d "`openssl x509 -noout -text -in \"$crt\" | \
		grep 'Not After' | \
		cut -d: -f2-4`" +%s) - \
		`date +%s`));

	baseName="`basename \"$crt\" | cut -d. -f1`"
	if [ "$restTime" -lt "$_EXPIRY" ]; then

		[ ! -r "$_LETS_ENCRYPT_DIR/csr/$baseName.csr" ] && \
			echo "ERROR: $crt has no accordant CSR in $_LETS_ENCRYPT_DIR/csr/${baseName}" &&
			returnValue=1 && continue
		
		if $_ACME_TINY \
			--account-key "$_LETS_ENCRYPT_DIR/letsencrypt.key" \
			--csr "$_LETS_ENCRYPT_DIR/csr/$baseName.csr" \
			--acme-dir "$_LETS_ENCRYPT_DIR/acme" > \
			"$_LETS_ENCRYPT_DIR/crt/${baseName}.crt"; then

			chmod 600 "$_LETS_ENCRYPT_DIR/crt/${baseName}.crt"

			cat "$_LETS_ENCRYPT_DIR/crt/${baseName}.crt" \
			"$_LETS_ENCRYPT_DIR/intermediate.pem" > \
			"$_LETS_ENCRYPT_DIR/crt/${baseName}.chained.crt" && \
			chmod 640 "$_LETS_ENCRYPT_DIR/crt/${baseName}.crt" ||
			returnValue=1 && continue
			replaced=true
		else
			returnValue=1
		fi
	else
		echo "$crt will not be renewed."
	fi
done
$replaced && /bin/systemctl reload nginx
exit $returnValue