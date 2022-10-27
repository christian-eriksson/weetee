# weetee

Will send an email when the external IP of the machine where it's running
changes. The email will report the new and the old IP.

## Dependencies

- `sendmail` or at least a SMTP client with an alias to `sendmail`
  - if you can run `echo "Subject: Test" | sendmail <YOUR_EMAIL>` you should be
    set. See note below.
- `curl`
- `sed`

**NOTE:** The system should have a default email account configured so `sendmail`
can send the email, you might need to install `msmtp` and `msmtp-mta` and
configure the account in `/etc/msmtprc`. Verify that the following works, using
your own email:

```
echo "Subject: Test" | sendmail email@example.com
```

## Configuration

Weetee is configured in the `.env` file which should be placed in the script's
directory. It should look like:

```bash
EMAIL={{email}}
TEMPLATE={{template-path}}
WHAT_IS_MY_IP_ENDPOINT={{endpoint}}
[IGNORE_EMPTY_NEW_IP=true]
```

When run, weetee will ask `{{endpoint}}` for the external IP, a `GET` request,
eg. `curl -s {{endpoint}}` should result in an ip (only) eg. `1.2.3.4`. It will
then compare this, current, IP with the ip in `old.ip` (if it exists). If the
current IP is not the same as the old IP weetee sends an email to `{{email}}`
with the content's of the file at `{{template-path}}`. The template file should
look like:

```
Subject: {{subject}}

{{body}}
```

The `{{subject}}` and `{{body}}` should be defined by the user. To add the new
and/or old IP to the email add `{{old-ip}}` and/or `{{new-ip}}` somewhere in the
template. **Note the space between the subject and the body**.

If the new ip is empty this likely means that the script cannot reach the
`WHAT_IS_MY_IP_ENDPOINT`, this can have multiple causes, like the service being
down the router being turned off. If this happens regularly (for example
regular restarts of the network router) we can choose to ignore it by setting
`IGNORE_EMPTY_NEW_IP` (to anything, if it's there it will be regarded as true).
Omit the variable if you want the default behavior.

## Example

`.env`:

```bash
EMAIL=email@example.com
TEMPLATE=/some/path/weetee/template.mail
WHAT_IS_MY_IP_ENDPOINT=http://whatismyip.akamai.com/
```

`/some/path/weetee/template.mail`:

```
Subject: IP change detected!

my old ip: {{old-ip}}
my new ip: {{new-ip}}

/regards
```

## Installation

```bash
git clone https://github.com/christian-eriksson/weetee.git
cd weetee
mkdir /etc/weetee
cp weetee.sh /etc/weetee
cp launcher /usr/local/bin/weetee
```

create the `.env` file in `/etc/weetee` as well as the template file (place the
template file in `{{template-path}}`). Now weetee can be configured to run with
a cron job or systemd timer to monitor if the ip changes and send an email if
it does.

cron: `*/10 * * * * weetee` to run weetee every 10 minutes

timer:

```
cp weetee.service weetee.timer /usr/lib/systemd/system/
systemctl enable weetee.timer --now
```
