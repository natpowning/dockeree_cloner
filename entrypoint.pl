#!/usr/bin/perl
#

my $cb_extracted_rootdir = "/clientbundles_extracted";
mkdir "$cb_extracted_rootdir";

opendir(my $clientbundles, "/clientbundles");
while(readdir $clientbundles) {
  next if $_ =~ /^\./;

  my $cb_zip = $_;
  my $extracted_dir = "$cb_extracted_rootdir/$cb_zip";

  mkdir $extracted_dir;
  system("unzip /clientbundles/$cb_zip -d $extracted_dir");

  open(my $cbscript, "<$extracted_dir/env.sh");
  while(my $line = <$cbscript>) {
      if($line =~ /^export\s(.*)=(.+)$/) {
          my $key = $1;
          my $val = $2;

          ($val = $extracted_dir)if($1 eq "DOCKER_CERT_PATH");

          $ENV{$key} = $val;

          # Get the destination CA and add to trusted certs
          if($key eq "DOCKER_HOST") {
              $val =~ s/^tcp:\/\///;
              system("curl -k https://$val/ca -o /etc/pki/ca-trust/source/anchors/$val.crt");
              system("update-ca-trust");
          }
      }
  }
  close $cbscript;

  print "Replicating configs for $cb_zip...\n";
  opendir(my $configs_dir, "/run/configs");
  while(readdir $configs_dir) {
    next if $_ =~ /^\./;

    my $name = $_;

    my $cmd = "docker config create $name /run/configs/$name";
    print "executing $cmd\n";
    system($cmd);
  }
  closedir($configs_dir);



  print "Replicating secrets for $cb_zip...\n";
  opendir(my $secrets_dir, "/run/secrets");
  while(readdir $secrets_dir) {
    next if $_ =~ /^\./;

    my $name = $_;

    my $cmd = "docker secret create $name /run/secrets/$name";
    print "executing $cmd\n";
    system($cmd);
  }
  closedir($secrets_dir);

  print "done with $cb_zip\n";
}

closedir($clientbundles);

print "done with all client bundles\n";


while(1) {
    print "\n\n===Clone Complete===\n\n";
    sleep 10;
}


