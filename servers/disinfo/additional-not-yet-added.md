# send mail from linux

install `apt-get install -y postfix mailutils libsasl2-modules`

set /etc/postfix/sasl_passwd `[smtp.gmail.com]:587 username@gmail.com:password`
=> I used sendinblue data

then launch

```
sudo postmap /etc/postfix/sasl_passwd
sudo chown root. /etc/postfix/sasl_passwd
sudo chmod 600 /etc/postfix/sasl_passwd
sudo chown root. /etc/postfix/sasl_passwd.db
sudo chmod 600 /etc/postfix/sasl_passwd.db
`
```

in `/etc/postfix/main.cf`
add

```
relayhost = [smtp.gmail.com]:587
smtp_tls_security_level = may
smtp_sasl_auth_enable = yes
smtp_sasl_security_options =
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
mydestination =
```

and then launch `sudo systemctl restart postfix`

you can now send en email with

```bash
mail -s 'Disk Space Alert' admin@disinfo.beta.gouv.fr << EOF
> This is a test email
> EOF
```

Just created a file called `alert-on-low-disk-availability.sh` and put it in a hourly cron `0 */1 * * * ~/alert-on-low-disk-availability.sh`

```bash
#!/bin/bash
CURRENT=$(df / | grep / | awk '{ print $5}' | sed 's/%//g')
THRESHOLD=70

echo $CURRENT

if [ "$CURRENT" -gt "$THRESHOLD" ] ; then
    mail -s 'Disk Space Alert' admin@disinfo.beta.gouv.fr << EOF
Your root partition remaining free space is critically low. Used: $CURRENT%
EOF
fi
```

```

```
