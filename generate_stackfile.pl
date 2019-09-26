#!/usr/bin/perl
#


my $configs_service;
my $configs_raw = `docker config ls`;
foreach my $line (split /\n/, $configs_raw) {
    if($line =~ /^.{28}(\S+)\s/) {
        next if $1 eq "NAME";

        $configs_service .= "      - source: $1\n";
        $configs_service .= "        target: /run/configs/$1\n";

        $configs_global .= "  $1\n";
        $configs_global .= "    external: true\n";
    }
}


my $secrets_raw = `docker secret ls`;
foreach my $line (split /\n/, $secrets_raw) {
    if($line =~ /^.{28}(\S+)\s/) {
        next if $1 eq "NAME";

        $secrets_service .= "      - $1\n";

        $secrets_global .= "  $1:\n";
        $secrets_global .= "    exernal: true\n";
    }
}


print <<'GROUP_END';
version: '3.7'
services:
  gatherer:
    image: gatherer
    deploy:
      replicas: 1
    configs:
GROUP_END


print "$configs_service";

print "    secrets:\n";
print "$secrets_service\n\n";

print "configs:\n";
print "$configs_global\n\n";

print "secrets:\n";
print "$secrets_global\n\n";



