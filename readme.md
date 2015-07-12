# wms report scripts

While OCLC is phasing out uploading periodic WMS reports to an SFTP server in favor of 
ad-hoc reports building, they do plan to continue uploading circulation add/delete and 
item inventory reports on a weekly basis. After a little bit of setup, these bash 
scripts can be used to automate the transfer from OCLC's SFTP to your own server.

## usage

```
git clone https://github.com/malantonio/wms-report-scripts
cd wms-report-scripts
```

With the exception of the titles of the files being copied, the two scripts are identical.
(Probably could do to combine them and add another variable / flag). Both accept the 
following environment variables:

     var     |               description               | required? | default value
-------------|-----------------------------------------|-----------|---------------
OCLC_SYMBOL  | your institution's OCLC registry symbol |    yes    |
REPORTS_PATH | where to store the reports              |    no     | current working directory
DATE         | date (formatted `YYYYMMDD`) of report   |    no     | today's date
DEBUG        | set to `1` to `echo` the command out    |    no     | 0
