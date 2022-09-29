#!/bin/sh -ex

# Set up ident details for cluster
ceph config set mgr mgr/telemetry/contact 'ceph-org'
ceph config set mgr mgr/telemetry/description 'upgrade test cluster'
ceph config set mgr mgr/telemetry/channel_ident true

# Check the warning:
ceph -s

# Enable perf channel
ceph telemetry enable channel perf

#Run preview commands
ceph telemetry preview
ceph telemetry preview-device
ceph telemetry preview

# Assert that new collections are available
ceph telemetry collection ls | grep 'perf_perf\|basic_mds_metadata\|basic_pool_usage\|basic_rook_v01\|perf_memory_metrics'

# Opt-in
ceph telemetry on --license sharing-1-0

# For quincy, the last_opt_revision remains at 1 since last_opt_revision
# was phased out for fresh installs of quincy.
LAST_OPT_REVISION=$(ceph config get mgr mgr/telemetry/last_opt_revision)
if [ $LAST_OPT_REVISION -ne 1 ]; then
    echo "last_opt_revision is incorrect"
    exit 1
fi

# Check warning again:
ceph -s

# Run show commands
ceph telemetry show
ceph telemetry show-device
ceph telemetry show perf ident

echo OK
