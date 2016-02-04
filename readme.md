# wms report transfer scripts

While OCLC is phasing out uploading periodic WMS reports to an SFTP in favor of ad-hoc
reports building, they do plan to continue uploading certain reports on a weekly basis.
After a little bit of setup, this bash script can be used to automate the transfer
from OCLC's SFTP to your own server.

## setup for password-free access

You'll want to either use a prexisting public/private keypair or generate one specifically
for gathering reports.

### A) Generate an SSH keypair

```
$ ssh-keygen
```

**Note:** when creating your keypair, be sure to leave the passphrase blank if you're planning
to automate the report-copying process.

### B) Copy the public file and move it to the SFTP

The SFTP server is quite stripped down as far as what commands can be run (I was only
able to run very basic `ls`, `mkdir`, `rm`, and `chmod` commands, most without the
extra flags needed to accomplish anything worthwhile). I found it easier to make the
changes on my end before placing them on the OCLC server.

```
$ cp ~/.ssh/id_rsa.pub ~/.ssh/oclc_authorized_keys
$ chmod 640 ~/.ssh/oclc_authorized_keys
$ scp ~/.ssh/oclc_authorized_keys lol@sftp.oclc.org:.ssh/authorized_keys
```

**Note:** if you created a separate key, use that name in place of `id_rsa`.

**Another note:** `lol` should be replaced with your library's OCLC symbol.
Unless that _is_ your symbol, in which case, you've officially won.

Enter `yes` to add the SFTP's IP to your list of authorized hosts, then enter your
password.

### C) Give it a whirl

Try running:

```
$ sftp lol@sftp.oclc.org
```

If it connects without prompting you for a password, you're all set to go!

## usage

```
$ git clone https://github.com/malantonio/wms-ftp-transfer-scripts
$ cd wms-report-scripts
```

With the exception of the titles of the files being copied, the two scripts are identical.
(Probably could do to combine them and add another variable / flag). Both accept the
following environment variables:

      var      |               description               | required? | default value
---------------|-----------------------------------------|-----------|---------------
`OCLC_SYMBOL`  | your institution's OCLC registry symbol |    yes    | -
`REPORT_NAME`  | the report filename (see below)         |    yes    | -
`OUT_PATH`     | where to store the reports              |    no     | current working directory
`DATE`         | date (formatted `YYYYMMDD`) of report   |    no     | today's date
`DEBUG`        | set to `1` to `echo` the command out    |    no     | 0

## Available Reports (as of 2/4/16)

Report name              | Publish time
-------------------------|----------------------------
`All_checked_out_items`  | daily @ 5:15a EST
`Circulation_add_delete` | weekly (Sunday @ 5:15a EST)
`Overdue_Report`         | daily @ 5:25a EST
`HoldListReport`         | daily @ 6:00a EST
`HoldsReadyForPickup`    | daily @ 5:10a EST
`Item_Inventories`       | weekly (Sunday @ 10p EST)
`Open_Holds`             | daily @ 6:00a EST
`Patron_Report_Full`     | weekly (Sunday @ 11p EST)
`Patron_Report_wk`       | weekly (Sunday @ 10p EST)

Source: [Reconciliation FTP Reports pdf][pdf]

[pdf]: https://www.oclc.org/support/worldshare-management-services/sites/www.oclc.org.support.worldshare-management-services/files/FTP_Reconciliation_Reports.pdf


## examples

```
$ OCLC_SYMBOL=lol REPORT_NAME=Item_Inventories OUT_PATH=/path/to/reports /path/to/get-wms-report.sh
```
