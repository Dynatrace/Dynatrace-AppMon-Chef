
# The Dynatrace Agents package will be installed into the directory
# node['dynatrace']['agents_package']['linux']['installer']['prefix_dir']/dynatrace-$major-$minor-$rev,
# where $major, $minor and $rev are given by the installer. A symbolic link to the actual installation directory will
# be created in node['dynatrace']['agents_package']['linux']['installer']['prefix_dir']/node['dynatrace']['one_agent']['linux']['package']['symlink_name'].
default['dynatrace']['one_agent']['linux']['package']['prefix_dir'] = '/opt'

# The file name of the Dynatrace One Agent package in the cookbook's files directory.
default['dynatrace']['one_agent']['linux']['package']['file_name'] = 'dynatrace-oneagent.zip'

# A HTTP, HTTPS or FTP URL to the Dynatrace Agents installer in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path.
# Additionally it is possible to refer to objects stored in S3 e.g. 's3://bucket_name/path/to/filename'.
# TODO: define link to official repo as soon as it is available
default['dynatrace']['one_agent']['linux']['package']['file_url'] = nil

default['dynatrace']['one_agent']['linux']['package']['symlink_name'] = 'dynatrace-oneagent'
