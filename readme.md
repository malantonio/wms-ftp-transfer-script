# wms report transfer script

While OCLC is phasing out uploading periodic WMS reports to an SFTP in favor of ad-hoc
reports building, they do plan to continue uploading certain reports on a weekly basis.
After a little bit of setup, this bash script can be used to automate the transfer
from OCLC's SFTP to your own server.

## setup for password-free access

You'll want to either use a prexisting public/private keypair or generate one specifically
for gathering reports.

### A) Log into the OCLC server and set up the environment

Before you can copy a key to the server, there needs to be a `.ssh` folder in
your OCLC server home directory. I found that the server will not display a
prompt if you use ssh to log into the server, so I use sftp to (very limitedly)
navigate.

```
$ sftp lol@scp.oclc.org
```

In your home directory, create a `.ssh` directory and set the permissions to be
`rwx------`:

```
$ mkdir .ssh
$ chmod 700 .ssh
```

While you're here, take note of the permissions of the root directory. By default,
[ssh wants only the user to have write permissions on the $HOME folder][ssh-perms].
If it looks like `rwxrw----`, you'll want to chmod it to remove group write
permissions (otherwise ssh won't work and you'll be prompted for a password every
time).

### B) Generate an SSH keypair

```
$ ssh-keygen
```

**Note:** when creating your keypair, be sure to leave the passphrase blank if you're planning
to automate the report-copying process.

### C) Copy the public file and move it to the SFTP

The SFTP server is quite stripped down as far as what commands can be run (I was only
able to run very basic `ls`, `mkdir`, `rm`, and `chmod` commands, most without the
extra flags needed to accomplish anything worthwhile). I found it easier to make the
changes on my end before placing them on the OCLC server.

```
$ cp ~/.ssh/id_rsa.pub ~/.ssh/oclc_authorized_keys
$ chmod 640 ~/.ssh/oclc_authorized_keys
$ scp ~/.ssh/oclc_authorized_keys lol@scp.oclc.org:.ssh/authorized_keys
```

**Note:** if you created a separate key, use that name in place of `id_rsa`.

**Another note:** `lol` should be replaced with your library's OCLC symbol.
Unless that _is_ your symbol, in which case, you've officially won.

Enter `yes` to add the SFTP's IP to your list of authorized hosts, then enter your
password.

### D) Give it a whirl

Try running:

```
$ sftp lol@scp.oclc.org
```

If it connects without prompting you for a password, you're all set to go!

## usage

```
$ git clone https://github.com/malantonio/wms-ftp-transfer-script
$ cd wms-ftp-transfer-script
$ OCLC_SYMBOL=lol REPORT_NAME=Overdue_Report OUT_PATH=/path/to/reports/overdue /path/to/get-wms-report.sh
```

As of now, you'll have to pass values as environment variables (though if you're good with
writing bash scripts that use flags instead a PR would brighten my day!). Passing `*` for
both `REPORT_NAME` and `DATE` _should_ get you every report, if that's your thing.
We're currently running a cron task for each publish time (see the [cron example][ce] below).

      var      |               description               | required? | default value
---------------|-----------------------------------------|-----------|---------------
`OCLC_SYMBOL`  | your institution's OCLC registry symbol |    yes    | -
`REPORT_NAME`  | the report filename (see below)         |    yes    | -
`OUT_PATH`     | where to store the reports              |    no     | current working directory
`DATE`         | date (formatted `YYYYMMDD`) of report   |    no     | today's date
`DEBUG`        | set to `1` to `echo` the command out    |    no     | 0

**Note:** `REPORT_NAME` can contain multiple comma-delimited reports

## Available Reports (as of 2/4/16)

Report name              | Publish time
-------------------------|----------------------------
`All_Checked_out_items`  | daily @ 5:15a EST
`Circulation_add_delete` | weekly (Sunday @ 5:15a EST)
`Overdue_Report`         | daily @ 5:25a EST
`HoldListReport`         | daily @ 6:00a EST
`HoldsReadyForPickup`    | daily @ 5:10a EST
`Item_Inventories`       | weekly (Sunday @ 10p EST)
`Open_Holds`             | daily @ 6:00a EST
`Patron_Report_Full`     | weekly (Sunday @ 11p EST)
`Patron_Report_wk`       | weekly (Sunday @ 10p EST)

Source: [Reconciliation FTP Reports pdf][pdf] + a visual tally of our FTP

## cron example

```
# WMS Reconciliation FTP Reports
# 10 minutes are added to each time to allow for delays

# daily reports
20 5 * * * OCLC_SYMBOL=lol REPORT_NAME=HoldsReadyForPickup OUT_PATH=/path/to/reports/holds-pickup /path/to/get-wms-report.sh
25 5 * * * OCLC_SYMBOL=lol REPORT_NAME=All_Checked_out_items OUT_PATH=/path/to/reports/checked-out /path/to/get-wms-report.sh
35 5 * * * OCLC_SYMBOL=lol REPORT_NAME=Overdue_Report OUT_PATH=/path/to/reports/overdue /path/to/get-wms-report.sh
10 6 * * * OCLC_SYMBOL=lol REPORT_NAME=HoldListReport OUT_PATH=/path/to/reports/hold-list /path/to/get-wms-report.sh
10 6 * * * OCLC_SYMBOL=lol REPORT_NAME=Open_Holds OUT_PATH=/path/to/reports/open-holds /path/to/get-wms-report.sh

# weekly reports
25 5 * * 0 OCLC_SYMBOL=lol REPORT_NAME=Circulation_add_delete OUT_PATH=/path/to/reports/add-delete /path/to/get-wms-report.sh
10 22 * * 0 OCLC_SYMBOL=lol REPORT_NAME=Item_Inventories OUT_PATH=/path/to/reports/inventory /path/to/get-wms-report.sh
10 22 * * 0 OCLC_SYMBOL=lol REPORT_NAME=Patron_Report_wk OUT_PATH=/path/to/reports/patron-wk /path/to/get-wms-report.sh
10 23 * * 0 OCLC_SYMBOL=lol REPORT_NAME=Patron_Report_Full OUT_PATH=/path/to/reports/patron-full /path/to/get-wms-report.sh
```


[ssh-perms]: http://unix.stackexchange.com/a/37166
[pdf]: https://www.oclc.org/support/worldshare-management-services/sites/www.oclc.org.support.worldshare-management-services/files/FTP_Reconciliation_Reports.pdf
[ce]: #cron-example
