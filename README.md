# DUSTY 
*Combination of tools for DAST Scanning*

[![](https://dockerbuildbadges.quelltext.eu/status.svg?organization=getcarrier&repository=dast)](https://hub.docker.com/r/getcarrier/dast/builds/)

### Quick and easy start
These simple steps will run blind DAST scan against your application and generate html and xml report with some low hanging fruits

##### 1. Install docker
 
##### 2. Start container and pass 5 config options to container and mount reports folder:

`host` - your application host (e.g. security.events.epam.com)

`port` - port your application is running at (e.g. 443)

`protocol` - http or https you are using

`project_name` - the name of your project will be displayed in reports

`environment` - name of environment you will be doing testing

`your_local_path_to_reports` - path on your local filesystem where you want to store reports from this execution

For example:

``` 
docker run -t -e host=localhost  -e port=443 -e protocol=https \
       -e project_name=MY_PET_PROJECT -e environment=stag \
       -v <your_local_path_to_reports>:/tmp/reports \
       --name=dusty --rm \
       getcarrier/dast:latest -s basic
```

##### 3. Open scan report
Report is located in your `your_local_path_to_reports` folder

### Configuration
Scans can be configured using `scan-config.yaml` file.

##### scan-config.yaml structure
```
basic: # Name of the scan
  # General configuration section
  target_host: $host          # host to scan (e.g. my.domain.com)
  target_port: $port          # port where it is hosted (e.g. 443)
  protocol: $protocol         # http or https
  project_name: $project_name # the name of the project used in reports
  environment: $environment   # literal name of environment (e.g. prod/stage/etc.)
  
  # Reporting configuration section (all report types are optional)
  html_report: true           # do you need an html report (true/false)
  junit_report: true          # do you need an xml report (true/false)
  reportportal:               # ReportPortal.io specific section
    rp_host: https://rp.com   # url to ReportPortal.io deployment 
    rp_token: XXXXXXXXXXXXX   # ReportPortal authentication token
    rp_project_name: XXXXXX   # Name of a Project in ReportPortal to send results to
    rp_launch_name: XXXXXXX   # Name of a Launch in ReportPortal to send results to
  jira:
    url: https://jira.com     # Url to Jira
    username: some.dude       # User to create tickets
    password: password        # password to user in Jira
    jira_project: XYZC        # Jira project ID
    assignee: some.dude       # Jira id of default assignee
    issue_type: Bug           # Jira issue type (Default: Bug)
    labels: some,label        # Comaseparated list of lables for ticket
    watchers: another.dude    # Comaseparated list of Jira IDs for watchers
  emails:
    smtp_server: smtp.office.com    # smtp server address
    port: 587                       # smtp server port
    login: some_user@epam.com       # smtp user autentification
    password: password              # smtp user password
    receivers_email_list:           # string with list receivers, separated ', '
      'user1@epam.com, user2epam.com' 
    subject: some text              # email subject
    body: some text                 # email body (text or html)
    attach_html_report: True        # add report to attachments
    attachments: '1.txt, 2.pdf'     # mounted to /attachments folder (optional)
                                    # string attachments file names, separated ', '
      
  # Scanners configurtion section (you can use only what you need)
  sslyze: true                # set to `true` in order to scan for ssl errors
  nmap:                       # nmap configuration
    inclusions: T:0-1000      # ports to scan
    exclusions: T:80,443      # ports expected to be discovered 
    nse_scripts: ssl-date     # additional NSE scripts 
    params: -v -A             # additional NMAP params
  zap:                        # OWASP zap confutation
    scan_types: xss           # types of vulnerabilities to scan
  masscan:                    # masscan configuration
    inclusions: 0-65535       # ports to scan
    exclusions: 80,443        # ports expected to be discovered
  nikto:                      # Nikto configuration
    # parameters for nikto to run with
    param: -Plugins @@ALL;-@@EXTRAS;-sitefiles;tests(report:500) -T 123x
  w3af:                       # w3af configuration
    # path to w3af configuraion within container
    config_file: /tmp/w3af_full_audit.w3af
  # Qualys WAS integration in tricky and 
  # require couple of secrets to be prebuilt into container
  # you will need to set QUALYS_LOGIN, QUALYS_PASSWORD and
  # QUALYS_API_SERVER to environment variables in order to make it work  
  qualys:
    # Qualys scan profile
    qualys_profile_id: SCAN_PROFILE_ID 
    # Qualys report temaple, probably we need to store example somewhere
    qualys_template_id: ID_OF_QUALYS_TEMPLATE 
    # Type of a scanner to use in Qualys
    qualys_scanner_type: INTERNAL | EXTERNAL 
    # In case you use INTERNAL you will need:
    qualys_scanner: NAME_OF_SCANNER
    
    
```
configuration can be mounted to container like 
```
-v <path_to_local_folder>/scan-config.yaml:/tmp/scan-config.yaml
```

##### False positive filtering configuration
User need to fill `false_positive.config` file with titles of false-positive issues and mount it to container
```
-v <path_to_local_folder>/false_positive.config:/tmp/false_positive.config
```

##### Please note that `scan-config.yaml` and `false_positive.config` included for demo purposes
