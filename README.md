# TestCluster

This is a module to run integration test suites across multiple test hosts to
test cluster deployment code.

## EXAMPLE

File: t/01.t

```perl
# vim: set syn=perl:

use Rex -base;
use TestCluster;

# mock rex logging functions so that they don't output anything
sub Rex::Logger::info {}
sub Rex::Logger::debug {}

task "test", sub {
  # run task code
};

my $test_cluster = TestCluster->new(cluster_def => "t/01.yml");
$test_cluster->initialize;
my $t01 = $test_cluster->vm("test01");
my $t02 = $test_cluster->vm("test02");

$t01->run_task("test");
$t02->run_task("test");

$t01->has_output_matching("id", qr/uid=0\(root\) gid=0\((root|wheel)\)/);
$t02->has_output_matching("id", qr/uid=0\(root\) gid=0\((root|wheel)\)/);

$test_cluster->finish;

1;
```

t/01.yml
```yaml
type: VBox
vms:
  test01:
    url: http://box.rexify.org/box/ubuntu-server-12.10-amd64.ova
    forward_port:
      ssh:
        - 2222
        - 22
    auth:
      user: root
      password: box
      auth_type: pass

  test02:
    url: http://box.rexify.org/box/ubuntu-server-12.10-amd64.ova
    forward_port:
      ssh:
        - 2223
        - 22
    auth:
      user: root
      password: box
      auth_type: pass
```