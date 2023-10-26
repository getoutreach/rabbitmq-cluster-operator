local kubecfg = import 'kubecfg.libsonnet';
local cluster = import 'kubernetes/cluster.libsonnet';
local ok = import 'kubernetes/outreach.libsonnet';

// Helm Chart
local chartData = importbin 'charts/rabbitmq-cluster-operator-3.4.2.tgz';
local bento = std.extVar('bento');

local sharedLabels = {
  repo: 'rabbitmq-cluster-operator',
  bento: bento,
  reporting_team: 'fnd-qss',
  'app.kubernetes.io/component': 'rabbitmq-cluster-operator',
  'app.kubernetes.io/name': 'rabbitmq-system',
  'app.kubernetes.io/part-of': 'rabbitmq',
};

{
  namespace: ok.Namespace('rabbitmq-cluster-operator') {
    metadata+: {
      labels+: sharedLabels,
    },
  },
} + kubecfg.parseHelmChart(
  chartData, 'rabbitmq-cluster-operator', 'rabbitmq-cluster-operator', {}
)
