FreeRADIUS
==========


Docker container for FreeRADIUS configured with usage of Yubico OTP. Originally based
from code <https://github.com/bryce-gibson/docker-freeradius>.

Configured to run FreeRADIUS and expose the Radius port. Tested with OpenWRT Barrier Breaker 14.07.

Users are created locally inside the container by the Dockerfile.
By default there is `admin` with password `docAdmin`. To be able to login 
the ID of the Yubikey must be set on the admin user in the yubikey_mappings file.

To build and run the container you can use the Makefile.

	make build
	make run

When setting up a Wifi with WPA2 Enterprise that connects to this freeradius server
the client must connect with EAP-TTLS/PAP. That creates an TLS tunnel and within that 
tunnel the username and password are sent in clear text. That makes it possible for
the PAM module to handle the authentication. If CHAP is used a hash of the password
is sent and that does not work with PAM. The yubico_pam module splits the password
in two parts, user entered part and OTP part that is written by the Yubikey.

To use this login procedure you must alway write the password for the Wifi. A OTP
can not be reused. In this setup you enter the username, admin, and then the password,
docAdmin, after that insert your Yubikey and press the button. A OTP is written after the
password that you entered and Enter-key is also pressed. This will make a correct
authenitcation. 

Troubleshouting is done by looking in the logs. Debug logs are enabled. To view the logs
you can just run

	make logs-run

Users are created locally inside the container by the Dockerfile.
By default there is `admin` with password `docAdmin`. To be able to login 
the ID of the Yubikey must be set on the admin user in the yubikey_mappings file.

# Testing

To test the radius server you can use radtest. It test that the radius server works, 
but it does not test EAP access that is used from wifi.

	radtest admin userAdmin localhost 0 testing123

To test the EAP access you have to use `eapol_test` from the `wpa_supplicant` package.
You have to build it by your own. 
Download the latest package from <http://w1.fi/wpa_supplicant> and extract it.

	cd wpa_supplicant-<version>/wpa_supplicant
	cp defconfig .config
	sed -i 's/#CONFIG_EAPOL_TEST=y/CONFIG_EAPOL_TEST=y/'
	make eapol_test
	sudo cp eapol_test /usr/local/bin

To test with `eapol_test` go to testfile directory and edit the file `ttls-pap.conf`.
Replace the example OTP string after the password with your own by setting the cursor 
after the password and press the Yubikey button. The you run this command:

	eapol_test -c ttls-pap.conf -s testing123

Note that the OTP is only valid onetime and it is verified before the maunally entered
password. If you write an invalid password you have to change the OTP again.

# Turn off PAM and Yubikey

If the line

	RUN sed -i 's/\t\tpap/\t\tpam/' /etc/freeradius/sites-enabled/inner-tunnel

is removed from the Dockerfile the users file will be used instead.
Users are defined in the users file. By default there is `admin:userAdmin`.

## Only for the users file

The start.sh script will also take user details from env and add them as users.
Eg running this container with `-e RADIUS_USER_test=password` will add a user
with the username "test" and the password "password".

The FreeRADIUS config will allow anyone to access it with the secret
`testing123`.


The /etc/freeradius directory is exposed as a volume, and FreeRADIUS will
reload if it receives a SIGHUP. In combination this means you can modify files
in the volume, and then `pkill -HUP freeradius` (approximate, tweak as needed)
to make more enthusiastic modifications to the FreeRADIUS configuration.

_None of this is even fractionally secure, it's just meant for dev purposes._
