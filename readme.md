# wms report transfer scripts

While OCLC is phasing out uploading periodic WMS reports to an SFTP in favor of ad-hoc
reports building, they do plan to continue uploading certain reports on a weekly basis.
After a little bit of setup, these bash scripts can be used to automate the transfer
from OCLC's SFTP to your own server (currently only `Item_Inventories` and
`Circulation-add-delete` reports).

## setup

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
$ git clone https://github.com/malantonio/wms-report-scripts
$ cd wms-report-scripts
```

With the exception of the titles of the files being copied, the two scripts are identical.
(Probably could do to combine them and add another variable / flag). Both accept the
following environment variables:

      var      |               description               | required? | default value
---------------|-----------------------------------------|-----------|---------------
`OCLC_SYMBOL`  | your institution's OCLC registry symbol |    yes    |
`REPORTS_PATH` | where to store the reports              |    no     | current working directory
`DATE`         | date (formatted `YYYYMMDD`) of report   |    no     | today's date
`DEBUG`        | set to `1` to `echo` the command out    |    no     | 0

## examples

```
$ OCLC_SYMBOL=lol REPORTS_PATH=/path/to/reports /path/to/scripts/inventory
```

The circulation add/delete and inventory reports are posted every Sunday (at 8am and 10pm,
respectively), so setting up a `cron` task (on an EST-based server) would look like:

```
0 8 * * 0 OCLC_SYMBOL=lol REPORTS_PATH=/path/to/reports /path/to/scripts/circ-add-delete
0 22 * * 0 OCLC_SYMBOL=lol REPORTS_PATH=/path/to/reports /path/to/scripts/inventory
```

