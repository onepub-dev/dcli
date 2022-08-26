Example: drive_upload_download_console
This example demonstrates the usage of the Google Drive API. It shows how to upload files to Google Drive and how to download them again.


In order to run gdrive you need create an OAuth credentials via the
Google Developers Console in the same project as your google drive lives. 

When creating the OAuth credentials select:
* OAuth client ID
* ApplicationType: Desktop App

You will also need to enable the 'Google drive API'


Create a `settings.yaml` file in ~/.gdrive/settings.yaml.

The settings.yaml should contain:

# oauth client details form console.cloud.google.com (developer console)
name: <oauth credentials name>
clientID: <client id ending in.apps.googleusercontent.com>
clientSecret: <oauth secret>


More information about how to obtain a Client ID can be found on the googleapis_auth repository.

To see usage information run:

$ gdrive 


When you run gdrive you will be prompted to authenticate.

$ dart bin/main.dart upload /usr/bin/git usr-bin-git
Please go to the following URL and grant access:
  => https://accounts.google.com/o/oauth2/auth?...

Uploaded /usr/bin/git. Id: 0B_H2HNyMUSo3TEhSeHFCVktrRXc

$ dart bin/main.dart download 0B_H2HNyMUSo3TEhSeHFCVktrRXc usr-bin-git
Please go to the following URL and grant access:
  => https://accounts.google.com/o/oauth2/auth?...

You must navigate to the URL displayed after the prompt Please go to the following URL and grant access: and give the application access to it's data.

When you grant access using the browser the running program will pick that up and continue.