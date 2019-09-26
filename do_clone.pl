#!/usr/bin/perl
#



my $configs_service;
my $configs_raw = `docker config ls`;
foreach my $line (split /\n/, $configs_raw) {
    if($line =~ /^.{28}(\S+)\s/) {
        next if $1 eq "NAME";

        $configs_service .= "      - source: $1\n";
        $configs_service .= "        target: /run/configs/$1\n";

        $configs_global .= "  $1:\n";
        $configs_global .= "    external: true\n";
    }
}


my $secrets_raw = `docker secret ls`;
foreach my $line (split /\n/, $secrets_raw) {
    if($line =~ /^.{28}(\S+)\s/) {
        next if $1 eq "NAME";

        $secrets_service .= "      - $1\n";

        $secrets_global .= "  $1:\n";
        $secrets_global .= "    external: true\n";
    }
}


open STACKFILE, ">cloner-stack.yml";

print STACKFILE <<'GROUP_END';
version: '3.7'
services:
  cloner: 
    image: cloner
    deploy:
      replicas: 1
    configs:
GROUP_END


print STACKFILE "$configs_service";

print STACKFILE "    secrets:\n";
print STACKFILE "$secrets_service\n\n";

print STACKFILE "configs:\n";
print STACKFILE "$configs_global\n\n";

print STACKFILE "secrets:\n";
print STACKFILE "$secrets_global\n\n";

system("docker build -t cloner .");

system("docker stack deploy --compose-file cloner-stack.yml cloner");


# TODO: Have this script remove the cloner stack once it sees a string
#       in the docker service logs output that indicates the process is done.
#
while(1) {
    my $log_output = `docker service logs cloner_cloner`;

    print "$log_output\n";
    sleep 10;
}


